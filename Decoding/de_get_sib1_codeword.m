% function for get sib1 codeword from bits
function word = de_get_sib1_codeword(received_codeword_pdsch,encoded,wordik,dci_config)

% encoded and wordik for tests.
% base parametrs for sib1
rv = 0;
nlayers = 1;
modulation = 'QPSK';
LBS = 25344;   % для справки
outlen = 2640; % для справки
TargetCodeRate = 0.5137;

% get info
% Из стандарта 38.214 3GPP раздела 5.1.3.2 и таблицы 5.1.3.2-1 получим
% ПРИМЕРНОЕ количество TBS по index из MCS из DCI. MCS сообщает какое кол
% во бит примерно ожидать
% Прогоним это кол-во бит через те же этапы кодирования (внутри самой же RR) и получим
% выходную последовательность для RR, а так же Zc, bgn, N

mcs = dci_config.macs;  % 11 - 104 бит. Не меньше имеющихся
if mcs == 11
    tbs = 104;
end

info = dlsch_info(tbs,TargetCodeRate); 

% 1. Rate Recovery for ldpc code: in LLR
rxLLR = 1 - 2 * received_codeword_pdsch; % 0 -> +1, 1 -> -1
codeword = RateRecoverLDPC(rxLLR, tbs, TargetCodeRate, rv, modulation, nlayers, info.C);

% Decode with a maximum of 25 iterations
% 2. LDPC Decoding
uncoded = LDPCDecode(codeword,info.BGN,25);  

% 3. Out Segmented. Kick filter bits
% Удаляем filler биты (последние F строк в каждом блоке)
% info.F. Формально, у нас просто останется лишних 4 бита, которые не несут ничего - filler bits
% При декодировании они останутся сами по себе (нулями) и буду отброшены,
% тк под все необходимые поля уже будут использованы биты
uncoded = uncoded(1:end-info.F, :);

% Объединяем блоки в один вектор
desegmented = uncoded(:);

% 4. crc use crc_type = 16 
word_for_uncrc = (desegmented.');

word = verifyParity(word_for_uncrc, info.CRC); % CRC Decode

wordik_2 = wordik.'; % исходная

isequal(word,wordik_2); %1
end

% Debugging code

% Code for TBS and N_info
%{
N_prb =10;
N_OFDM =11;
N_dmrs = 60;
Qm = 2;
R = 0.5137;
R = 0.03906; % TBS = 96; mcs index = 1
R = 0.04882; % TBS = 120; mcs index = 2 
N_RE = N_prb * N_OFDM * 12 - N_dmrs;
N_info = N_RE * Qm * R * nlayers;
if N_info < 3824
    n = max(3, ceil(log2(N_info))-6);
    N_info_2 = max(24, 2^n*round(N_info/(2^n)));
    TBS = N_info_2;
end
%}


% Мало актуально, тк функция RR_my ушла в небытие. Сейчас используется
% другая.
%Code for RR and encode (возможно, ошибка алгоритма RR, так как в одном месте меняются блоки по 40 элементов)
%                       (но благодаря LLR битам код даже так работает исправно)
%   Для работы с данным кодом необходимо будет воспользоваться вызовом
%   encode (биты после LDPC кодирования)
%{

            % encoded - сразу после LPDCCod, перед RM 
            rx = double(1-2*encoded);           % Convert to soft bits. 
            % rx = 1 -> LLR = -1 (уверенность в 1)
            % rx = 0 -> LLR = +1 (уверенность в 0)
            % rx = -1 (fiiler) -> LLR = 0 (неизвестно)
            F_i = find(encoded(:,1) == -1);     %filler bits
            rx(F_i,:) = 0; % Fillers have no LLR information
            % filler bits dont carry information


% Преобразуйте исходный encoded в эталонный LLR вектор
ref_LLR = zeros(1000, 1);
ref_LLR(encoded == 0) = +1;   % где был 0, ставим LLR +1
ref_LLR(encoded == 1) = -1;   % где был 1, ставим LLR -1
ref_LLR(encoded == -1) = 0;   % где был -1, ставим LLR 0

% Найти места, где восстановленный LLR не совпадает с эталонным
difference_index = find(codeword ~= ref_LLR);

% Посмотреть на значения в этих точках
comparison = [codeword(difference_index), ref_LLR(difference_index)];
disp('Расхождения: [Восстановленный LLR, Эталонный LLR]');
disp(comparison);
codeword_cop = codeword(difference_index(1):difference_index(40));
codeword(difference_index(1):difference_index(80)) = 0;
codeword(difference_index(41):difference_index(80)) = codeword_cop;

isequal(codeword, rx);  % 1  
%}
