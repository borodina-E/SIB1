function hex_data = bits_to_hex(bit_stream)
hex_data = zeros(1, ceil(length(bit_stream)/8), 'uint8');
for i = 1:8:length(bit_stream)
    byte = bit_stream(1,i:i+7);
    byte_str = sprintf('%d', byte);
    per_dec = bin2dec(byte_str);  
    hex_data(ceil(i/8)) =  per_dec;
end
end