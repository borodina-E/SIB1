function tests=ldpcCoding_test
    tests = functiontests(localfunctions);
end
function setupOnce(~)
     % Абсолютные пути к функциям
    addpath('...');   % путь к вашей функции
    addpath('...');        % путь к функции матлаба
end
function teardownOnce(~)
    rmpath('...');     % путь к вашей функции
    rmpath('...');          % путь к функции матлаба
end


function randTest(tc)
    for i=1:100
        word = int8(randi([0, 1], 116, 1));
        %word_for_ldpcCoding = int8(word.');
        F = 84;
        C = 1;
        segmented = [word; -1*ones(F, C)];
        bgn = 2;

        recovered=ldpcCoding(segmented,bgn);
        rec = nrLDPCEncode(segmented,bgn);
        verifyEqual(tc,recovered,rec);
    end
end