function tests=attachParityBits_test
    tests = functiontests(localfunctions);
end
function setupOnce(~)
     % Абсолютные пути к функциям
    addpath('...'); % путь к вашей функции
    addpath('...');        % путь к функции матлаба
end
function teardownOnce(~)
    rmpath('...'); % путь к вашей функции
    rmpath('...');        % путь к функции матлаба
end


function randTest(tc)
    for i=1:100
        word1 = int8(randi([0, 1], 100, 1));
        word2 = (word1.');
        crc2 = 'crc16';
        crc1 = '16';

        recovered=attachParityBits(word2,crc2);
        rec = nrCRCEncode(word1,crc1);
        rec2 = (rec.');
        verifyEqual(tc,recovered,rec2);
    end
end