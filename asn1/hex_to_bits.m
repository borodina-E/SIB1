function bit_stream = hex_to_bits(hex_data)
bit_stream = zeros(1, numel(hex_data)*8, 'uint8');
for i = 1:length(hex_data)
    byte_dec = hex_data(i);
    byte_str = dec2bin(byte_dec,8); 
    bits = double(byte_str)-48;
    for j = 0:7
    bit_stream(i*8-(7-j)) = bits(1+j); 
    end
end
end