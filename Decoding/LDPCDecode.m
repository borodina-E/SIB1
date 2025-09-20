% function for LDPC Decoding 
function [out,actNumIter] = LDPCDecode(in,bgn,maxNumIter)
 %Упрощённый LDPC декодер на основе nrLDPCDecode
% Входы:
%   in - входные LLR значения (N x C)
%   bgn - номер базового графа (1 или 2)
%   maxNumIter - максимальное число итераций
% Выходы:
%   out - декодированные биты (K x C)
%   actNumIter - фактическое число итераций для каждого блока
%  bp - belief propagation

    % Проверка входных параметров
    if nargin < 3
        maxNumIter = 25;
    end
    
    % Получаем размеры входных данных
    [N, C] = size(in);
    typeIn = class(in);
    
    % Параметры LDPC в зависимости от базового графа
    if bgn == 1
        ncwnodes = 66;  % Полная длина кодового слова в Zc-битах - колво узлов
        nsys = 22;      % Число систематических столбцов 
    else
        ncwnodes = 50;
        nsys = 10;
    end
    
    % Вычисляем размер подъёма Zc
    Zc = N / ncwnodes;
    
    % Проверка корректности длины входных данных
   % if mod(Zc, 1) ~= 0
    %   error('Некорректная длина входных данных для выбранного базового графа');
    %end
    
    % Получаем параметры LDPC
    cfg = getLdpcConfig(bgn, Zc); 
    
    % Добавляем проколотые биты (2*Zc нулевых LLR)
    fullInput = [zeros(2*Zc, C, typeIn); in];
    
    % Инициализация выходных переменных
    out = zeros(nsys*Zc, C, 'int8');
    actNumIter = zeros(1, C);
    
    % Декодируем каждый блок отдельно
    for c = 1:C
        [decBits, iter] = ldpcDecodeCore(fullInput(:,c), cfg, maxNumIter);
        out(:,c) = decBits;
        actNumIter(c) = iter;
    end
end

% function for config
function cfg = getLdpcConfig(bgn, Zc)
% Возвращает конфигурацию LDPC для заданных параметров
    
    cfg = struct();
    cfg.BGN = bgn;
    cfg.Zc = Zc;
    cfg.Algorithm = 'bp'; % Belief propagation

    % Get the same parity check matrix as used in encoding
    persistent bgs
    if isempty(bgs)
        bgs = coder.load('baseGraph');
    end
    
    % Get lifting set number (same as in encode)
    ZSets = {[2  4  8  16  32  64 128 256],... % Set 1
             [3  6 12  24  48  96 192 384],... % Set 2
             [5 10 20  40  80 160 320],...     % Set 3
             [7 14 28  56 112 224],...         % Set 4
             [9 18 36  72 144 288],...         % Set 5
             [11 22 44  88 176 352],...        % Set 6
             [13 26 52 104 208],...            % Set 7
             [15 30 60 120 240]};              % Set 8
    
    for setIdx = 1:8
        if any(Zc==ZSets{setIdx})
            break;
        end
    end

    % Get shift values matrix (same as in encode)
    switch bgn
        case 1
            switch setIdx
                case 1; V = bgs.BG1S1;
                case 2; V = bgs.BG1S2;
                case 3; V = bgs.BG1S3;
                case 4; V = bgs.BG1S4;
                case 5; V = bgs.BG1S5;
                case 6; V = bgs.BG1S6;
                case 7; V = bgs.BG1S7;
                otherwise; V = bgs.BG1S8;
            end
        otherwise
            switch setIdx
                case 1; V = bgs.BG2S1;
                case 2; V = bgs.BG2S2;
                case 3; V = bgs.BG2S3;
                case 4; V = bgs.BG2S4;
                case 5; V = bgs.BG2S5;
                case 6; V = bgs.BG2S6;
                case 7; V = bgs.BG2S7;
                otherwise; V = bgs.BG2S8;
            end
    end
    
    P = calcShiftValues(V,Zc);
    cfg.H = ldpcQuasiCyclicMatrix(Zc, P);
end

% function for alroritm ldcp decoding. Belief Proparation или же
% Sum-Product
function [decBits, iter] = ldpcDecodeCore(llrIn, cfg, maxIter)
% Ядро декодера LDPC
% maxIter - макс число итераций
% llrIn - входные LLR (Log-Likehood Ratios)
    
    H = cfg.H;
    [M, N] = size(H);
    K = N - M;
% M - число проверочных уравнений 
% N - длина кодового слова
% K - длина ифнормационного блока
    
    % Инициализация массивов сообщений
    msgVtoC = zeros(M, N); % Матрица сообщений от переменных узлов (V) к проверочным узлам (С).
                           % msgVtoC(i, j) - это сообщение от j-го переменного узла к i-му проверочному узлу.
    msgCtoV = zeros(M, N); % Матрица сообщений от проверочных узлов (C) к переменным узлам (V).
                           % msgCtoV(i, j) - это сообщение от i-го проверочного узла к j-му переменному узлу.
    
    % Находим соединения в графе Таннера - это визуализация проверочной
    % матрицы H. - получим индексы всех ненулевых элементов. 

    % rowIdx и colIdx - это векторы, которые попарно определяют, какие проверочные узлы 
    % (i = rowIdx(e)) соединены с какими переменными узлами (j = colIdx(e)). 
    % Этот список ребер (edges) оптимизирует последующие вычисления, позволяя перебирать только существующие связи, 
    % а не всю огромную (но разреженную) матрицу.
    [rowIdx, colIdx] = find(H); 

    
    % Основной цикл декодирования
    for iter = 1:maxIter
        % 1. Обновление сообщений(LLR бит) от переменных к проверкам (V -> C)
        for e = 1:length(rowIdx)
            i = rowIdx(e); % номер проверочного узла (строка в H).
            j = colIdx(e); % номер переменного узла (столбец в H).
            
            sumMsg = llrIn(j);   % собственный LLR - информация из канала связи
            neighbors = find(H(:,j))'; % нахождение всех соседей переменного узла j. 
                                       % find находит все проверочные
                                       % узлы(номера строк), которые
                                       % связанны с переменным узлом
            neighbors = neighbors(neighbors ~= i); % При подсчёте уверенности переменного узла j, мы не учитываем то сообщение
                                                   % которое ранее нам
                                                   % прислала сама проверка
            
            for k = neighbors % суммирование всех входящий сообщений от других узлов
                sumMsg = sumMsg + msgCtoV(k,j); % сообщение от других проверочных узлов 
            end
            % msgCtoV(k, j) - это сообщение, которое проверочный узел k ранее отправил переменному узлу j. 
            % Это "мнение" проверки k о том, каким должен быть бит j, основанное на всех остальных битах, 
            % входящих в уравнение проверки k.
            
            msgVtoC(i,j) = sumMsg; % Итоговая сумма записывается как исходящее сообщение от переменного узла j 
                                   % к проверочному узлу i
        end
        
        % 2. Обновление сообщений от проверок к переменным
        for e = 1:length(rowIdx)
            i = rowIdx(e);
            j = colIdx(e);
            
            product = 1; % для произведения тангенсов 
            neighbors = find(H(i,:)); % находим соседей
            neighbors = neighbors(neighbors ~= j); % исключаем мнение соседа, с которым говорим
            
            for k = neighbors
                product = product * tanh(msgVtoC(i,k)/2); % вычисление произвеления гиперболических тангенсов
                % msgVtoC(i, k) - это сообщение, которое переменный узел k отправил проверочному узлу i на текущей итерации. 
                % Это уверенность бита k в своем значении.
                % tanh(msgVtoC(i,k)/2) – это преобразование. Гиперболический тангенс используется для перевода
                % из логарифмической вероятности (LLR) в область, удобную для представления вероятности знака бита.
                % Результат лежит в интервале (-1, 1).

                %Значение, близкое к +1: бит k очень уверен, что он '0'.

                %Значение, близкое к -1: бит k очень уверен, что он '1'.

                %Значение, близкое к 0: бит k совершенно неуверен.

                % Произведение так как: 
                % Уравнение проверки на чётность выполняется (равно 0), если сумма всех битов по модулю 2 равна 0. 
                % В вероятностной трактовке это эквивалентно тому, что произведение их знаков (с учетом операции XOR) равно +1. 
                % Формула product * tanh(...) – это компактный способ учета всех этих вероятностных соотношений.
            end
            
            msgCtoV(i,j) = 2 * atanh(product); % проверочный узел вычисляет сообщение как произведение гиперболических тангенсов
            % atanh(product)это обратная функция. Она переводит результат произведения обратно в пространство LLR.
            % 2* – масштабирующий множитель, являющийся частью канонической формулы.

            % product близок к 1 - msgCtoV будет большим положительным числом: проверка i "настаивает", что бит j – это '0'.
            % product близко к -1. Сообщение будет большим отрицательным числом: проверка i "настаивает", что бит j – это '1'.
            % Если product близко к 0, значит, проверочный узел получает противоречивые сигналы от соседей и сам неуверен в своем "мнении". 
            % Сообщение будет близко к 0.

            % Итог Шага 2: 
            % Проверочные узлы на основе частичной информации вычисляют, 
            % какими должны быть биты, и рассылают эти "требования" или "рекомендации" обратно переменным узлам.
        end
        % На следующей итерации Шага 1 переменные узлы учтут эти новые рекомендации от всех проверок, 
        % и процесс уточнения повторится. 
        % Таким образом, на каждой итерации уверенность в значениях битов растет, и алгоритм сходится 
        % к правильному кодовому слову.
        
        % 3. Проверка на раннюю остановку
        decisions = llrIn + sum(msgCtoV, 1)'; % итоговые LLR: исходные LLR + все поправки от проверочных узлов
        hardDecisions = decisions < 0;        % если LLR < 0 , то 1, иначе 0
        syndrome = mod(H * hardDecisions, 2); % Если hardDecisions исходное кодовое слово, то syndrome нулевой вектор
        
        if ~any(syndrome) % декодирование прекращается при выполнении всех проверок на чётность 
            break;
        end
    end
    
    % Возвращаем только информационные биты
    decBits = int8(hardDecisions(1:K));
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

