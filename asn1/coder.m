
per_data = encoded_sib1();

% Преобразование в битовый поток
bit_stream = hex_to_bits(per_data);

% Преобразование битового потока обратно в байты
per_data = bits_to_hex(bit_stream);
decoded_sib1(per_data);

%перед запуском MATLAB в терминале указать export LD_LIBRARY_PATH=/путь/к/библиотеке/SIB1/asn1/lib:$LD_LIBRARY_PATH
%для перекомпиляции mex-функции и инициализатора в commamdwindow выполнить mex -g -output bin/encoded_sib1 -I/путь/к/заголовочным/файлам/SIB1/asn1/include -L/путь/к/библиотеке/SIB1/asn1/lib -lsib1.so /путь/к/мех/функции/SIB1/asn1/mex/sib1_encoder_mex.c /путь/к/инициализатору/SIB1/asn1/mex/cellinfo_init.c -outdir /путь/для/сохранения/SIB1/asn1/mex -v
%если не работает libsib1.so положить рядом с мех, в матлаб выполнить setenv('LD_LIBRARY_PATH', ['/путь/к/библиотеке:', getenv('LD_LIBRARY_PATH')]);
%mex -g -output bin/decoded_sib1 -I/home/alice/MATLAB/R2024a/bin/SIB1/asn1/include -L/home/alice/MATLAB/R2024a/bin/SIB1/asn1/lib -lsib1.so /home/alice/MATLAB/R2024a/bin/SIB1/asn1/mex/sib1_decoder_mex.c -outdir /home/alice/MATLAB/R2024a/bin/SIB1/asn1/mex -v
%mex -g -output bin/encoded_sib1 -I/home/alice/MATLAB/R2024a/bin/SIB1/asn1/include -L/home/alice/MATLAB/R2024a/bin/SIB1/asn1/lib -lsib1.so /home/alice/MATLAB/R2024a/bin/SIB1/asn1/mex/sib1_encoder_mex.c /home/alice/MATLAB/R2024a/bin/SIB1/asn1/mex/cellinfo_init.c -outdir /home/alice/MATLAB/R2024a/bin/SIB1/asn1/mex -v