function sib1 = Decoder(bits)
    %if bits(1)...end проверка необязательных полей
    %зная правила кодирования можно рассчитать номера битов ответственных
    %за передачу каждого поля
    
    bit_string = num2str(bits);
    bit_string = bit_string(bit_string ~= ' '); % Удаляем пробелы
    sib1 = SIB1;
    
    offset = 0;
    if bits(1)
        %декодирование cellSelectionInfo
        %offset =... %число битов занимаемых полем
    end

        %FieldsOffset - длина первого декодированного поля (cellSelectionInfo) + 15 битов
        %от проверок наличия необязательных полей cellSelectionInfo - snpn-AccessInfoList-r17
        FieldsOffset = offset + 15;
        %определение числа массивов plmn_IdentityInfo
        MassN_II = bit_string(FieldsOffset+1:FieldsOffset+4);
        MassN_II = bin2dec(MassN_II);
        if MassN_II > 12
        disp('ошибка при декодировании числа массивов plmn_IdentityInfo\n');
        else
        fprintf('sib1 содержит %d массивов  plmn_IdentityInfo\n', MassN_II);
        end
        FieldsOffset = FieldsOffset + 4;
        %декодирование plmn_IdentityInfoList
         for i = 1:MassN_II
            FieldsOffset = FieldsOffset + 5; %опциональные поля trackingAreaCode - gNB_ID_Length_r17
    
            %декодирование plmn_IdentityList
            %определение числа массивов PLMN_Identity
            MassN_I = bit_string(FieldsOffset+1:FieldsOffset+4);
            MassN_I = bin2dec(MassN_I);
            if MassN_I > 12
            disp('ошибка при декодировании числа массивов plmn_Identity\n');
            else
            fprintf('plmn_IdentityInfo  №%i sib1 содержит %d массивов  plmn_Identity\n', i,MassN_I);
            end
            FieldsOffset = FieldsOffset + 4;
    
            info = PLMN_IdentityInfo();
                for j = 1:MassN_I
                    result = [];
                        for n = 1:3
                        MCC = bit_string(FieldsOffset+1:FieldsOffset+4);
                        MCC = bin2dec(MCC);
                        result = [result, MCC];
                        FieldsOffset = FieldsOffset+4;
                        end
                    plmn = PLMN_Identity();
                    plmn.mcc.mcc = result; 
    
                    result = [];
                    %определение размера mnc
                    mncSize = bit_string(FieldsOffset+1:FieldsOffset+3);
                    mncSize = bin2dec(mncSize);
                    FieldsOffset = FieldsOffset+3;
                    if mncSize == 2
                       for n = 1:2
                        MNC = bit_string(FieldsOffset+1:FieldsOffset+4);
                        MNC = bin2dec(MNC);
                        result = [result, MNC];
                        FieldsOffset = FieldsOffset+4;
                       end
                    else
                       for n = 1:3
                        MNC = bit_string(FieldsOffset+1:FieldsOffset+4);
                        MNC = bin2dec(MNC);
                        result = [result, MNC];
                        FieldsOffset = FieldsOffset+4;
                       end
                    end
                   plmn.mnc.mnc = result;   
                   info = info.addElements(plmn);
                end
    
          CId = bit_string(FieldsOffset+1:FieldsOffset+36);
          CIdarray = zeros(1, length(CId));
          for m = 1:length(CId)
            CIdarray(m) = str2double(CId(m)); % Конвертирует каждый символ
          end
          info.cellIdentity = CellIdentity();  
          info.cellIdentity.cellIdentity = CIdarray;
          FieldsOffset = FieldsOffset+36;
          CRFOU = bit_string(FieldsOffset+1);
    
          if CRFOU == '1'
              CRFOU = 'reserved';
          else 
              CRFOU = 'notReserved';
          end
          info.cellReservedForOperatorUse = CellReservedForOperatorUse(CRFOU);
    
        FieldsOffset = FieldsOffset+1;
        sib1.cellAccessRelatedInfo = sib1.cellAccessRelatedInfo.addElements(info);
    
        %if bits(20)...end декодирование 'trackingAreaCode
        %...
        %if bits(24)...end декодирование gNB_ID_Length_r17
        end
     
    %if bits(12)...end декодирование cellReservedForOtherUse
    %...
    %if bits(15)...end декодирование snpn-AccessInfoList-r17

    %if bits(2)...end декодирование поля cellSelectionInfo
    %...
    %if bits(11)...end декодирование поля nonCriticalExtension
    
end