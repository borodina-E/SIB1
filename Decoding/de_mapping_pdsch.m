% function for de_mapping pdsch
function [symbols_pdsch,symbols_dmrs] = de_mapping_pdsch(resource_grid, coreset_config, sib1_config,dci_config,dmrsTypeAPosition)

    reg_count = 0;
    symbols_pdsch = [];
    symbols_dmrs = [];

    RIV_bits = num2str(sib1_config.RIV_bits(3:length(sib1_config.RIV_bits)));
    RIV_bits = RIV_bits(RIV_bits ~= ' '); % Удаляем пробелы
    RIV = bin2dec(RIV_bits);
    
% Decode RIV. Используем лишь часть условия декодирования RIV, так как для
% sib1 много RE не выделяется, соответственно, второе условие не нужно
    if RIV < (coreset_config.size_rbs* (coreset_config.size_rbs +1))
     LRbs = floor(RIV/coreset_config.size_rbs) + 1; % length allocated resource blocks
     RBstart = mod(RIV,coreset_config.size_rbs);
    end

% For time domain check TDRA from dci_config. 38.214 table 5.1.2.1.1-2
% TDRA = 0001 -> Row index 1. dmrsTypeAPosition =2 -> K0 = 0; S = 2; L = 12; 
    if dci_config.TDRA == 1 && sib1_config.map_type == 1
      K0 = 0;     % the delay between DCI and PDSCH
      S = 2;      % start symbol OFDM
      L = 12;     % number of symbols OFDM
      dmrsTypeAPosition = 2; % if = 2, DMRS in 2 ofdm symbol
    end

dmrs_symbol = dmrsTypeAPosition; %pos2
sib1_config.K0 = K0;
sib1_config.S = S;
sib1_config.L = L;

    % 1. Параметры из RIV
    rb_end = RBstart + LRbs - 1;
    %slot_num = 0;

    % 2. ДеМаппинг DM-RS (весь символ)
   
    for rb = RBstart:rb_end
        for sc = 1:2:12 % Type 1: нечётные поднесущие map_type = 1 + dmrsTypeAPosition = 2 -> на втором ofmd символе
            re_pos = rb * 12 + sc;
            symbols_dmrs = [symbols_dmrs;resource_grid(re_pos, dmrs_symbol)];
            reg_count = reg_count + 1;
        end
    end

    % 3. Де Маппинг данных SIB1 (символы 3-13)
   
    for sym = 3:13 % Символы 3-13 (1-based)
        for rb = RBstart:rb_end
            for sc = 1:12
                % Пропускаем DM-RS позиции (если есть доп. DM-RS)
                if ismember(sym, dmrs_symbol) && mod(sc-1, 2) == 0
                    continue;
                end
                
                if (length(symbols_pdsch) - length(symbols_dmrs)) <= reg_count
                    re_pos = rb * 12 + sc;
                    symbols_pdsch = [symbols_pdsch;resource_grid(re_pos, sym)];
                    reg_count = reg_count + 1;
                end
            end
        end
    end

end