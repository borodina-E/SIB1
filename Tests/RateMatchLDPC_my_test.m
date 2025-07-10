function tests=RateMatchLDPC_my_test
    tests = functiontests(localfunctions);
end
function setupOnce(~)
     % Абсолютные пути к функциям
    addpath('...');            % путь к вашей функции
    addpath('...');         % путь к функции матлаба
end
function teardownOnce(~)
    rmpath('...');              % путь к вашей функции
    rmpath('...');          % путь к функции матлаба
end


function randTest(tc)
    for i=1:100
        word = int8(randi([0, 1], 100, 1));
        outlen = 79728;
        rv = 0;
        modulation = 'QPSK';
        nlayers = 1;
        LBS = 25344;

        recovered=RateMatchLDPC_my(word,outlen,rv,modulation,nlayers,LBS);
        rec = nrRateMatchLDPC(word,outlen,rv,modulation,nlayers,LBS);
        verifyEqual(tc,recovered,rec);
    end
end