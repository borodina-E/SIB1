% function mapping PDSCH
function resource_grid = fun_mapping_pdsch(sib1_config, symbols, NCellId, dmrsTypeAPosition, LRbs, RBstart)
arguments
    sib1_config % config sib1 message
    symbols     % qpsk PDSCH
    NCellId     % NCellId
    dmrsTypeAPosition
    LRbs        % length allocated resource blocks
    RBstart     % Start RB for SIB1
end
    
    % 1. Paramets from sib1_config
    % K0 - sib1 is in the same slot as dci.
    % S - start symbol OFDM = 2.
    % L - number symbols OFDM = 12.
    % dmrsTypeAPosition = 2 
    % PDSCH_mapping_type = 1; % A
    % 2. RIV
    % size_rbs = 48 rbs
    % LRbs - length allocated resource blocks = 10 rbs
    % RBstart - Start RB for SIB1 = 30 rbs

    %%
    % dmrs_pos = 2 (для Type A pos2)
    % rb_range = [start_rb, end_rb]
            NGridSize = 100;
            mu =1;
            resource_grid = ResourceMapper(NGridSize,nrCom.Nsymb_slot*nrCom.Nslot_frame(mu));
    
    % 1. Параметры из RIV
    rb_end = RBstart + LRbs - 1;
    slot_num = 0;
    
    % 2. Генерация DM-RS (Type 1, pos2)
    dmrs_symbol = dmrsTypeAPosition; % pos2 = символ 2 (0-based)
    dmrs_seq = generate_pdsch_dmrs(NCellId, slot_num, dmrs_symbol, LRbs);
    
    % 3. Маппинг DM-RS (весь символ)
    dmrs_idx = 1;
    for rb = RBstart:rb_end
        for sc = 1:2:12 % Type 1: нечётные поднесущие map_type = 1
            re_pos = rb * 12 + sc;
            resource_grid.resource_grid(re_pos, dmrs_symbol) = dmrs_seq(dmrs_idx);
            dmrs_idx = dmrs_idx + 1;
        end
    end
    
    % 4. Маппинг данных SIB1 (символы 3-13)
    data_idx = 1;
    for sym = 3:13 % Символы 3-13 (1-based)
        for rb = RBstart:rb_end
            for sc = 1:12
                % Пропускаем DM-RS позиции (если есть доп. DM-RS)
                if ismember(sym, dmrs_symbol) && mod(sc-1, 2) == 0
                    continue;
                end
                
                if data_idx <= length(symbols)
                    re_pos = rb * 12 + sc;
                    resource_grid.resource_grid(re_pos, sym) = symbols(data_idx);
                    data_idx = data_idx + 1;
                end
            end
        end
    end
end

function dmrs_seq = generate_pdsch_dmrs(NCellId, slot_num, symbol_num, num_rb)
    % Параметры DM-RS для PDSCH (Type 1)
    c_init = mod(2^17 * (14 * slot_num + symbol_num + 1) * (2 * NCellId + 1) + 2 * NCellId, 2^31);
    num_dmrs_per_rb = 6; % Type 1: 6 RE на символ
    
    % Генерация последовательности
    c = get_sequence(zeros(1, 2 * num_rb * num_dmrs_per_rb), c_init);
    dmrs_seq = (1/sqrt(2)) * ((1 - 2 * c(1:2:end)) + 1i * (1 - 2 * c(2:2:end)));
end

