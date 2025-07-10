% function for pdsch symbols qpsk
function symbols = get_pdsch_symbols(...
    codeword, ...
    nID, ...
    n_RNTI ...
    )
arguments
    codeword (1,:) % encoded payload
    nID (1,1)      % cell identificator (0...1007)
    n_RNTI (1,1)   % CRC mask required to decode the SIB1 message
end
% use function scrambling_pdcch. Get scrambled_bits
% Воспльзуемся функцией scrambling_pdcch, так как она реализуется с помощью
% Si-RNTI, который нам нужен и для скремблирования pdsch
scrambled_bits = scrambling_pdcch(codeword, n_RNTI, nID);

% modulation QPSK. qpskModulation - взято у Валентина
symbols = qpskModulation(scrambled_bits);

end
