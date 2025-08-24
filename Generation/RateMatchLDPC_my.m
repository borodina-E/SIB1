% function for Rate Match LDPC 
function out = RateMatchLDPC_my(in,outlen,rv,modulation,nlayers,varargin)
% in - входная последовательность
% outlen - 79728 - Gd*qm.*nlayers - G - общее колво кодируемых бит,
% доступных для передачи транспортного блока/разрядность PDSCH. Это должно
% быть значение длины кодового слова в процентах от транспортного канала
% DL-SCH
%Gd - кол во элементов ресурсов на уровень/порт
% rv - recondary version = 0
% modulation - QPSK - base. Qm - подярок модуляции
% nlayers - кол во уровней передачи, на которых сопоставляется транспортный
% блок - 1 - base
% LimitedBufferSize - 25344 - размер внутренного буфера, используемого для
% согласования скорости. Это число - max размер кодового слова

% Получим из стандарта Nref. Он определён в 38.214 5.1.3.2. Пока не use.

% Validate input data length
[N,C] = size(in);
ZcVec = [2:16 18:2:32 36:4:64 72:8:128 144:16:256 288:32:384];

 % Determine base graph number from N
    if any(N==(ZcVec.*66))
        bgn = 1;
        ncwnodes = 66;
    else % must be one of ZcVec.*50
        bgn = 2;
        ncwnodes = 50;
    end
    Zc = N/ncwnodes;

     % Get modulation order
    switch modulation
        case {'pi/2-BPSK', 'BPSK'}
            Qm = 1;
        case 'QPSK'
            Qm = 2;
        case '16QAM'
            Qm = 4;
        case '64QAM'
            Qm = 6;
        case '256QAM'
            Qm = 8;
        otherwise   % '1024QAM'
            Qm = 10;
    end

    %%
    % Nref - параметр, который определит Ncb. В матлабе в него вкладывается
    % значение LimitedBufferSize = 25344 - то есть максимальный размер. 
    % Снизу приводится расчёт этого параметра исходя из стандарта. 
    % Из 38.212 нужно его высчитать. Нужен TBS - он из 38.214
    % Вопросы: Откуда взять nprb в 212 - как его определить если prb мы
    % получаем уже после RM? Взять из тго, что есть? 

    % get to Ncb in from Nref 38.212 5.4.2.1
    Rlbrm = 2/3;  % base
                  % TBS 38.214 5.1.3.2
    Nrbsc = 12;   % rb
    Nohrb = 0;    % тк PDSCH запланирован PDCCH шифрованием CRC Si-RNTI
    Nsymbsh = 12; % кол во символов распределения в слоте. L из таблицы у нас 12
    Ndmrsprb = 0; % кол во Res для dmrs. Для типа dmrs mapping type A: Ue dmrs-AdditionalPosition = pos2 и 
                  % до двух односимвольных dmrs 
                  % 5.6.1.2. Тк один символ на dmrs, то prb 12? 
    nprb = 122;   % общее число выделенных prbs для ue. Можно попробовать сейчас высчитать руками. 
                  % Пока 12*12 - 12 = 144 - 12 = 122
    R = 0.5137;   % target coderate 0.5137
    CC  = 1;      % кол во заплонированных блоков = 1; 38.212 5.2.2 - 
                  % то есть из ldpc кодирования - у нас только 1 блок тк малая длина

    Nre = Nrbsc * Nsymbsh - Ndmrsprb - Nohrb;
    Nre = min(156,Nre)*nprb;

    v = 1 ;       % nlayers 

    Ninf = Nre * R * Qm * v;

    if Ninf <= 3824
        n = max(3, (log(Ninf,2) - 6 ));
        Ninf = max(24,2^n*(Ninf/(2)^n));
    end

    TBS = Ninf; % условно. Чек таблицу 38.214 5.1.3.2-1
    
    Nref_my = TBS/(Rlbrm*CC); % использовать Nref_my вместо Nref (Matlab)
    %%
    % Всё же идём по матлабу. Nref = varargin{1}
    Nref = varargin{1};

    % Get code block soft buffer size
    if ~isempty(Nref)
        fcnName = 'nrRateMatchLDPC';
        validateattributes(Nref, {'numeric'}, ...
            {'scalar','integer','positive'},fcnName,'NREF');

        Ncb = min(N,Nref);
    else    % No limit on buffer size
        Ncb = N;
    end

    % Get starting position in circular buffer
    if bgn == 1
        if rv == 0
            k0 = 0;
        elseif rv == 1
            k0 = floor(17*Ncb/N)*Zc;
        elseif rv == 2
            k0 = floor(33*Ncb/N)*Zc;
        else % rv is equal to 3
            k0 = floor(56*Ncb/N)*Zc;
        end
    else
        if rv == 0
            k0 = 0;
        elseif rv == 1
            k0 = floor(13*Ncb/N)*Zc;
        elseif rv == 2
            k0 = floor(25*Ncb/N)*Zc;
        else % rv is equal to 3
            k0 = floor(43*Ncb/N)*Zc;
        end
    end


    % Get rate matching output for all scheduled code blocks and perform
    % code block concatenation according to Section 5.4.2 and 5.5
    out = [];
    for r = 0:C-1
        if r <= C-mod(outlen/(nlayers*Qm),C)-1
            E = nlayers*Qm*floor(outlen/(nlayers*Qm*C));
        else
            E = nlayers*Qm*ceil(outlen/(nlayers*Qm*C));
        end
        out = [out; cbsRateMatch(in(:,r+1),E,k0,Ncb,Qm)]; 
    end

end

% function for out 
function e = cbsRateMatch(d,E,k0,Ncb,Qm)
% Rate match a single code block segment as per TS 38.212 Section 5.4.2

    % Bit selection, Section 5.4.2.1 
    % Get number of filler bits inside the circular buffer
    NFillerBits = sum(d(1:Ncb) == -1); 

    % Duplicate data if more than one iteration around the circular
    % buffer is required to obtain a total of E bits
    d = repmat(d(1:Ncb),ceil(E/(length(d(1:Ncb))-NFillerBits)),1);

    % Shift data to start from selected redundancy version
    d = circshift(d,-k0);

    % Avoid filler bits and provide an empty vector if E is 0
    e = zeros(E,1,class(d));
    e(:) = d(find(d ~= -1,E + (E==0)));        
    
    % Bit interleaving, Section 5.4.2.2
    e = reshape(e,E/Qm,Qm);
    e = e.';
    e = e(:); 

end
