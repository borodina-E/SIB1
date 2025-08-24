% Rate Recovery number two 
function out = RateRecoverLDPC(in,trblklen,R,rv,modulation,nlayers,varargin)

    narginchk(6,8);
    % Get scheduled code blocks and limited buffers for HARQ combining
    if nargin==6
        numCB = [];
        Nref = [];
    elseif nargin==7
        numCB = varargin{1};
        Nref = [];
    else
       numCB = varargin{1};
       Nref = varargin{2};
    end
   
    %modulation = validateInputs(in,trblklen,R,rv,modulation,nlayers);
    typeIn = class(in);

    % Output empty if the input is empty or trblklen is 0
    if isempty(in) || ~trblklen
        out = zeros(0,1,typeIn);
        return;
    end

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
        otherwise % '1024QAM'
            Qm = 10;
    end

    % Get base graph and code block segmentation parameters
    %cbsinfo = nrDLSCHInfo(trblklen,R);
    cbsinfo = dlsch_info(trblklen,R);
    bgn = cbsinfo.BGN; % 2
    Zc = cbsinfo.Zc;   % 20
    N = cbsinfo.N;     % 1000
  

    % Get number of scheduled code block segments
    if ~isempty(numCB)
        fcnName = 'nrRateRecoverLDPC';
        validateattributes(numCB, {'numeric'}, ...
            {'scalar','integer','positive','<=',cbsinfo.C},fcnName,'NUMCB');  

        C = numCB;      % scheduled code blocks
    else
        C = cbsinfo.C;  % all code blocks
    end

    % Get code block soft buffer size
    if ~isempty(Nref)
        fcnName = 'nrRateRecoverLDPC';
        validateattributes(Nref, {'numeric'}, ...
            {'scalar','integer','positive'},fcnName,'Nref');

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
        else % rv == 3
            k0 = floor(56*Ncb/N)*Zc;
        end
    else
        if rv == 0
            k0 = 0;
        elseif rv == 1
            k0 = floor(13*Ncb/N)*Zc;
        elseif rv == 2
            k0 = floor(25*Ncb/N)*Zc;
        else % rv == 3
            k0 = floor(43*Ncb/N)*Zc;
        end
    end

    G = length(in);
    gIdx = 1;
    out = zeros(N,C,typeIn);
    in = in.';
    for r = 0:C-1
        if r <= C-mod(G/(nlayers*Qm),C)-1
            E = nlayers*Qm*floor(G/(nlayers*Qm*C));
        else
            E = nlayers*Qm*ceil(G/(nlayers*Qm*C));
        end
        if G < E
            % Pad "unknown" bits to support insufficient input
            zeroPad = zeros(E-G,1,class(in));
            deconcatenated = [in; zeroPad];
        else
            deconcatenated = in(gIdx:gIdx+E-1,1);
        end
        gIdx = gIdx + E;
        out(:,r+1) = cbsRateRecover(deconcatenated,cbsinfo,k0,Ncb,Qm);
    end
    
end

function out = cbsRateRecover(in,cbsinfo,k0,Ncb,Qm)
% Rate recovery for a single code block segment

    % Perform bit de-interleaving according to TS 38.212 5.4.2.2
    E = length(in);
    in = reshape(in,Qm,E/Qm);
    in = in.';
    in = in(:);

    % Calculate soft buffer size according to TS 38.212 5.4.2
    [NBuffer,K,Kd] = nr5g.internal.ldpc.softBufferSize(cbsinfo,Ncb);

    % Perform reverse of bit selection according to TS 38.212 5.4.2.1
    
    % Duplicate data if more than one iteration around the circular
    % buffer is required to obtain a total of E bits
    idx = repmat(1:Ncb,1,ceil(E/NBuffer));

    % Shit data to start from selected redundancy version
    idx = circshift(idx,-k0);

    % Avoid filler bits indices
    indicesFillerBits = idx(find(idx > Kd & idx <= K,E));  
    indices = idx(~ismember(idx,indicesFillerBits));
    indices = indices(1:E); 

    % Initialize output
    out = zeros(cbsinfo.N,1,class(in));

    % Fill in circular buffer
    if E > NBuffer
        % Stack block repetitions in columns and soft combine by adding
        % columns together
        out = zeros(cbsinfo.N,1,class(in));
        inRep = zeros(NBuffer,ceil(E/NBuffer),class(in));
        inRep(1:E) = in;
        out(indices(1:NBuffer)) = sum(inRep,2);
    else
        out(indices) = in;
    end
    
    % Filler bits are treated as 0 bits when encoding, 0 bits correspond to
    % Inf in received soft bits, this step improves error-correction
    % performance in the LDPC decoder
    out(Kd+1:K) = Inf;
    
end
