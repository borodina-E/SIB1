% function for create RG PDCSH and generate SIB1
function [resource_grid_pdsch,sib1_config] = createPdschFrame(coreset_config,dci_config,sib1_config,codeword_sib1,nID,n_RNTI,...
    dmrsTypeAPosition)
arguments
    coreset_config  % size_rbs - size crst0
    dci_config      % FDRA the number in which the RIV is encoded
    sib1_config     % sib1 config
    codeword_sib1   % codeword sib1     
    nID             % NCellId
    n_RNTI          % n_RNTI
    dmrsTypeAPosition% 
end
riv_bits = num2str(dci_config.RIV_bits(3:length(dci_config.RIV_bits)));
riv_bits = riv_bits(riv_bits ~= ' '); % Удаляем пробелы
RIV = bin2dec(riv_bits);

% Decode RIV. Используем лишь часть условия декодирования RIV, так как для
% sib1 много RE не выделяется, соответственно, второе условие не нужно
if RIV < (coreset_config.size_rbs* (coreset_config.size_rbs +1))
    LRbs = floor(RIV/coreset_config.size_rbs) + 1; % length allocated resource blocks
    RBstart = mod(RIV,coreset_config.size_rbs);    % Start RB for SIB1
end

% For time domain check TDRA from dci_config. 38.214 table 5.1.2.1.1-2
% TDRA = 0001 -> Row index 1. dmrsTypeAPosition =2 -> K0 = 0; S = 2; L = 12; 
if dci_config.TDRA == 1 && dmrsTypeAPosition == 2
    K0 = 0;     % the delay between DCI and PDSCH
    S = 2;      % start symbol OFDM
    L = 12;     % number of symbols OFDM
end

sib1_config.K0 = K0;
sib1_config.S = S;
sib1_config.L = L;

% Create RG PDSCH. Need function fun_mapping for PDSCH (новая или исправить её для того, чтобы работала для обоих каналов?)
symbols = get_pdsch_symbols(codeword_sib1,nID,n_RNTI);

%Get the resource grid for pdsch. На основе RIV bits, sib1_config (K0, S, L)
%[resource_grid,coreset_config] = fun_mapping(coreset_config, symbols, AL, nID);
resource_grid_pdsch = fun_mapping_pdsch(sib1_config, symbols, nID,dmrsTypeAPosition,...
    LRbs,RBstart);

end


% Полное условие декодирования RIV
%{
    if RIV < (coreset_config.size_rbs* (coreset_config.size_rbs - LRbs +1))
    new_LRbs = floor(RIV/coreset_config.size_rbs) + 1;
    new_RBstart = mod(RIV,coreset_config.size_rbs);
else
    new_LRbs = coreset_config.size_rbs - floor(RIV/coreset_config.size_rbs);
    new_RBstart = coreset_config.size_rbs - 1 - mod(RIV,coreset_config.size_rbs); 
end
%}
