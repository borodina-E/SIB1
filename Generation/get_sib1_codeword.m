% function for get sib1 codeword
function codeword = get_sib1_codeword(dci_config,coreset_config,dmrsTypeAPosition)
arguments 
    dci_config 
    coreset_config
    dmrsTypeAPosition
end
% Base paramets for sib1
rv = 0;              % recondury version 
nlayers = 1;         % кол во уровней передачи, на которых сопоставляется транспортный блок 
modulation = 'QPSK'; % for Qm - подярок модуляции
outlen = 2640;       % общее кол-во кодируемых бит. Gd*qm.*nlayers. Gd - кол во элементов ресурсов на уровень/порт
                     % Так как длина будет 1000 после ldpc, можно взять
                     % 2640. 79728 слишком много для sib1 message
                     % при данных TDRA 2640 - max заполнение
LBS = 25344;         % Это число - max размер кодового слова
% расчёт outlen исходя из TDRA и RIV 

riv_bits = num2str(dci_config.RIV_bits(3:length(dci_config.RIV_bits)));
riv_bits = riv_bits(riv_bits ~= ' '); % Удаляем пробелы
RIV = bin2dec(riv_bits);

% Decode RIV. Используем лишь часть условия декодирования RIV, так как для
% sib1 много RE не выделяется, соответственно, второе условие не нужно
if RIV < (coreset_config.size_rbs* (coreset_config.size_rbs +1))
    LRbs = floor(RIV/coreset_config.size_rbs) + 1; % length allocated resource blocks
end

% For time domain check TDRA from dci_config. 38.214 table 5.1.2.1.1-2
% TDRA = 0001 -> Row index 1. dmrsTypeAPosition =2 -> K0 = 0; S = 2; L = 12; 
if dci_config.TDRA == 1 && dmrsTypeAPosition == 2
    L = 12;     % number of symbols OFDM
end
outlen = 2*12*LRbs*(L-1); % 2640. 11 ofdm тк 1-ый только под dmrs
                          % *2 для полного заполнения pdsch (qpsk мод)

% 1. здесь будет функция генерации полезной нагрузки.
% пока что зададим значение sib1 в виде 100х1 бит 
word = int8(randi([0, 1], 100, 1));

% 2. info for ldpc and crc
chinfo = dlsch_info(length(word));

% 3. crc use crc_type = 16 
word_for_crc = (word.');
crced = attachParityBits(word_for_crc, chinfo.CRC);

% 4. segmented - нет необходимости из-за малых размеров. Только добавляем
% -1 - filter bits
% Code block segmentation and code block CRC attachment
crced_for_ldpcCoding = (crced.');
segmented = [crced_for_ldpcCoding; -1*ones(chinfo.F, chinfo.C)];

% 5. encoding bits
encoded = ldpcCoding(segmented,chinfo.BGN);

% 6. Rate Mathing for ldpc code
codeword = RateMatchLDPC_my(encoded,outlen,rv,modulation,nlayers,LBS);
% rv = 0; LBS = 25344 in Matlab; nlayers = 1; modulation = 'QPSK'; 
% outlen = 79728
end