% function for DLSCH info: 
function info = dlsch_info(tbs,R)
arguments 
    tbs
    R
end

% Get base graph number and CRC information
bginfo = getBgnInfo(tbs,R);

% Get code block segment information
cbinfo = getCBSinfo(bginfo.B, bginfo.BGN);

% Get number of bits (including filler bits) to be encoded by LDPC
    % encoder
    if bginfo.BGN == 1
        N = 66*cbinfo.Zc;
    else
        N = 50*cbinfo.Zc;
    end

    % Combine information into the output structure
    info.CRC      = bginfo.CRC;             % CRC polynomial
    info.L        = bginfo.L;               % Number of CRC bits
    info.BGN      = bginfo.BGN;             % Base graph number
    info.C        = cbinfo.C;               % Number of code block segments
    info.Lcb      = cbinfo.Lcb;             % Number of parity bits per code block
    info.F        = cbinfo.F;               % Number of <NULL> filler bits per code block
    info.Zc       = cbinfo.Zc;              % Selected lifting size
    info.K        = cbinfo.K;               % Number of bits per code block after CBS
    info.N        = N;                      % Number of bits per code block after LDPC coding

end


% function 1 for: L, bgn, B
function info = getBgnInfo(A,R)
    % Cast A to double, to make all the output fields have same data type
    A = double(A);

    % LDPC base graph selection
    if A <= 292 || (A <= 3824 && R <= 0.67) || R <= 0.25
      bgn = 2;
    else
      bgn = 1;
    end

    % Get transport block size after CRC attachment according to 38.212
    % 6.2.1 and 7.2.1, and assign CRC polynomial to CRC field of output
    % structure info
    if A > 3824
      L        = 24;
      info.CRC = '24A';
    else
      L        = 16;
      info.CRC = 'crc16';
    end

    % Get the length of transport block after CRC attachment
    B = A + L;

    % Get the remaining fields of output structure info
    info.L   = L;
    info.BGN = bgn;
    info.B   = B;

end

% function 2 for: C, cbz, L, K - Kd, K, Zc, Zlist
function info = getCBSinfo(B, bgn)
% Cast B to double, to make all the output fields have same data type
    B = cast(B,'double');

    % Get the maximum code block size
    if bgn == 1
      Kcb = 8448;
    else
      Kcb = 3840;
    end

    % Get number of code blocks and length of CB-CRC coded block
    if B <= Kcb
      L = 0;
      C = 1;
      Bd = B;
    else
      L = 24; % Length of the CRC bits attached to each code block
      C = ceil(B/(Kcb-L));
      Bd = B+C*L;
    end

    % Obtain the number of bits per code block (excluding CB-CRC bits)
    cbz = ceil(B/C);

    % Get number of bits in each code block (excluding filler bits)
    Kd = ceil(Bd/C);

    % Find the minimum value of Z in all sets of lifting sizes in 38.212
    % Table 5.3.2-1, denoted as Zc, such that Kb*Zc>=Kd
    if bgn == 1
      Kb = 22;
    else
      if B > 640
        Kb = 10;
      elseif B > 560
        Kb = 9;
      elseif B > 192
        Kb = 8;
      else
        Kb = 6;
      end
    end
    Zlist = [2:16 18:2:32 36:4:64 72:8:128 144:16:256 288:32:384];
    Zc =  min(Zlist(Kb*Zlist >= Kd));

    % Get number of bits (including <NULL> filler bits) to be input to the LDPC
    % encoder
    if bgn == 1
      K = 22*Zc;
    else
      K = 10*Zc;
    end

    info.C   = C;       % Number of code block segments
    info.CBZ = cbz;     % Number of bits in each code block (excluding CB-CRC bits and filler bits)
    info.Lcb = L;       % Number of parity bits in each code block
    info.F   = K-Kd;    % Number of filler bits in each code block
    info.K   = K;       % Number of bits in each code block (including CB-CRC bits and filler bits)
    info.Zc  = Zc;      % Selected lifting size
    info.Z   = Zlist;   % Full lifting size set
end
