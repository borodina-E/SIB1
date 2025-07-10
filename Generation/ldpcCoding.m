% function for ldpc coding 
function out = ldpcCoding(in,bgn)

 % Obtain input/output size
    [K,C] = size(in);
    if bgn==1
        nsys = 22;
        ncwnodes = 66;
    else
        nsys = 10;
        ncwnodes = 50;
    end
    Zc = K/nsys;
    % Empty in, empty out
    typeIn = class(in);
    
% Check against all supported lifting sizes
%ZcVec = [2:16 18:2:32 36:4:64 72:8:128 144:16:256 288:32:384];
% количество бит после кодирования
N = Zc*ncwnodes; 

 % Find filler bits (shortening bits) and replace them with 0 bits
locs = find(in(:,1)==-1);
in(locs,:) = 0;

% Encode all code blocks
outCBall = encode(double(in),bgn,Zc);

% Put filler bits back
outCBall(locs,:) = -1;

% Puncture first 2*Zc systematic bits and output
out = zeros(N,C,typeIn);
out(:,:) = cast(outCBall(2*Zc+1:end,:),typeIn);

end


function codewords = encode(infoBits,bgn,Zc)

    % LDPC Encode using the base graph structure
    persistent bgs
    if isempty(bgs)
        bgs = coder.load('baseGraph');
    end

    %persistent encoderCfg
    %if isempty(encoderCfg)
    %    encoderCfg = coder.nullcopy(cell(2,8,384)); % bgn, setIdx, Zc
    %end
    
    %persistent doInit
    %if isempty(doInit)
    %    doInit = true(2,8,384); % bgn, setIdx, Zc
    %end

     % Get lifting set number
    ZSets = {[2  4  8  16  32  64 128 256],... % Set 1
             [3  6 12  24  48  96 192 384],... % Set 2
             [5 10 20  40  80 160 320],...     % Set 3
             [7 14 28  56 112 224],...         % Set 4
             [9 18 36  72 144 288],...         % Set 5
             [11 22 44  88 176 352],...        % Set 6
             [13 26 52 104 208],...            % Set 7
             [15 30 60 120 240]};              % Set 8
    
    coder.unroll();
    for setIdx = 1:8    % LDPC lifting size set index
        if any(Zc==ZSets{setIdx})
            break;
        end
    end

    % Get the matrix with base graph number 'bgn' and set number 'setIdx'.
    % The element of matrix V in the following is H_BG(i,j)*V(i,j), where
    % H_BG(i,j) and V(i,j) are defined in TS 38.212 5.3.2; if V(i,j) is not
    % defined in Table 5.3.2-2 or Table 5.3.2-3, the elements are -1.
    switch bgn
        case 1
            switch setIdx
                case 1
                    V = bgs.BG1S1;
                case 2
                    V = bgs.BG1S2;
                case 3
                    V = bgs.BG1S3;
                case 4
                    V = bgs.BG1S4;
                case 5
                    V = bgs.BG1S5;
                case 6
                    V = bgs.BG1S6;
                case 7
                    V = bgs.BG1S7;
                otherwise % 8
                    V = bgs.BG1S8;
            end
        otherwise % bgn = 2
            switch setIdx
                case 1
                    V = bgs.BG2S1;
                case 2
                    V = bgs.BG2S2;
                case 3
                    V = bgs.BG2S3;
                case 4
                    V = bgs.BG2S4;
                case 5
                    V = bgs.BG2S5;
                case 6
                    V = bgs.BG2S6;
                case 7
                    V = bgs.BG2S7;
                otherwise % 8
                    V = bgs.BG2S8;
            end
    end

    %if doInit(bgn,setIdx,Zc)
    %    % Get shift values matrix
    P = calcShiftValues(V,Zc);
        %encoderCfg{bgn,setIdx,Zc} = ldpcEncoderConfig(sparse(logical(ldpcQuasiCyclicMatrix(Zc,P))));
        %doInit(bgn,setIdx,Zc) = true;
    %end
    H = ldpcQuasiCyclicMatrix(Zc, P);
   % codewords = ldcp_coding(infoBits,encoderCfg{bgn,setIdx,Zc});
    % function 
    codewords = ldpc_encode_simple(infoBits, P, Zc, H);

end

% 1. function for encode
function P = calcShiftValues(V,Z)
%calcShiftValues Calculate shift values from V for a lifting size Z

% The element of matrix P in the following is P(i,j) in TS 38.212 5.3.2
% when V(i,j) are defined in Table 5.3.2-2 or Table 5.3.2-3. If not
% defined, the elements are -1.

    P = zeros(size(V));
    for i = 1:size(V,1)
        for j = 1:size(V,2)
            if V(i,j) == -1
                P(i,j) = -1;
            else
                P(i,j) = mod(V(i,j),Z);
            end
        end
    end
    
end

% 2. function for encode 
function H = ldpcQuasiCyclicMatrix(blockSize, P)
%LDPCQUASICYCLICMATRIX Parity-check matrix of a quasi-cyclic LDPC code
%36625555555555555555555555555555555555
% Each number in P not equal to -1 will produce blockSize ones in H

n = numel(find(P~=-1))*blockSize;
rowIndex = coder.nullcopy(zeros(n,1));
columnIndex = coder.nullcopy(zeros(n,1));

% Expand each number in P into a sub-matrix (blockSize by blockSize)
ind = 0;
[numRows, numCols] = size(P);
for j = 1:numCols
    for i = 1:numRows
        if P(i,j) ~= -1
            % Right-shift a blockSize-by-blockSize diagonal matrix
            % cyclically by P(i,j) columns 
            columnIndex(ind+(1:blockSize)) = (j-1)*blockSize + (1:blockSize);
            rowIndex(ind+(1:blockSize)) = (i-1)*blockSize + [(blockSize-P(i,j)+1):blockSize, 1:(blockSize-P(i,j))];
            ind = ind + blockSize;
        end
    end
end
H = sparse(rowIndex,columnIndex,true,numRows*blockSize,numCols*blockSize);
end

% 3. function for encode 
function codeword = ldpc_encode_simple(info_bits, P, Zc, H)
    % P - матрица сдвигов (prototype matrix)
    % Zc - размер подъёма (lifting size)
    % info_bits - информационные биты (K x 1)
    
    [m, n] = size(P);
    K = n*Zc - m*Zc; % Кодовая скорость R = K/(n*Zc)
    
    % Проверка размеров
    assert(length(info_bits) == K, 'Неверный размер входных данных');
    
    % Построение матрицы (MATLAB-совместимое)
    %H = ldpcQuasiCyclicMatrix(P, Zc);
    
    % Разделение на [A | B] (проверьте порядок столбцов!)
    A = H(:, 1:K);
    B = H(:, K+1:end);
    
    % Вычисление синдрома (MATLAB использует mod 2)
    syndrome = mod(A * double(info_bits), 2);
    
    % Решение системы B*p = syndrome (бинарный вариант)
    parity = solve_binary_system(B, syndrome);
    
    % Формирование кодового слова (порядок как в MATLAB)
    codeword = [info_bits; parity];
end

% 4. function for ldpc_encode_simple
function x  = solve_binary_system(A, b)
    % Решение системы уравнений для треугольной матрицы B
    % Гауссово исключение по модулю 2
    n = size(A,2);
    Ab = [A, b];
    
    % Прямой ход
    for i = 1:n
        % Поиск ведущего элемента
        pivot = find(Ab(i:end,i), 1) + i - 1;
        if isempty(pivot)
            error('Матрица вырождена');
        end
        
        % Перестановка строк
        Ab([i pivot],:) = Ab([pivot i],:);
        
        % Исключение
        for j = i+1:n
            if Ab(j,i)
                Ab(j,:) = mod(Ab(j,:) + Ab(i,:), 2);
            end
        end
    end
    
    % Обратный ход
    x = zeros(n,1);
    for i = n:-1:1
        x(i) = Ab(i,end);
        for j = i+1:n
            if Ab(i,j)
                x(i) = mod(x(i) + x(j), 2);
            end
        end
    end
end