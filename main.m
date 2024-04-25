text = 'qehvkfggfghfghfhgfhfhgfhjfggft';
alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .';
bitLength =  6;

encodedMessage = encodeMessage(text, alphabet, bitLength);
disp(encodedMessage);           

message = svertka(encodedMessage);
disp(message);

disp("lab3");
[dir_mes, ind] = direct_interleaving(message);
disp(dir_mes);
dec_dir_mes = decode_interleaving(dir_mes, ind);
disp(dec_dir_mes);


disp("lab4");
qpsk_code = qpsk(dir_mes);
qpsk_dcode = qpsk_decode(qpsk_code);
%disp(qpsk_dcode);

decodedMessage = decodeMessage(encodedMessage, alphabet, bitLength);
disp(decodedMessage);

disp("lab5");
ofdm = ofdm_modulation(qpsk_code);
disp(ofdm);

function encodedMessage = encodeMessage(text, alphabet, bitLength)
    symbolToBin = containers.Map('KeyType', 'char', 'ValueType', 'char');
    for idx =  1:numel(alphabet)
        symbolToBin(alphabet(idx)) = decToBinary(idx -  1, bitLength);
    end

    encodedMessage = '';
    for i =  1:length(text)
        charToEncode = char(text(i));
        if isKey(symbolToBin, charToEncode)
            encodedMessage = [encodedMessage symbolToBin(charToEncode)];
        else
            disp(['Предупреждение: Символ ''', charToEncode, ''' не найден в алфавите.']);
        end
    end
end

function decodedMessage = decodeMessage(encodedMessage, alphabet, bitLength)
    binToSymbol = containers.Map('KeyType', 'char', 'ValueType', 'char');
    for idx =  1:numel(alphabet)
        binToSymbol(decToBinary(idx -  1, bitLength)) = alphabet(idx);
    end

    decodedMessage = '';
    for i =  1:length(encodedMessage)/bitLength
        binaryCode = encodedMessage((i-1)*bitLength+1:i*bitLength);
        if isKey(binToSymbol, binaryCode)
            decodedMessage = [decodedMessage binToSymbol(binaryCode)];
        else
            disp(['Предупреждение: Двоичный код ''', binaryCode, ''' не найден в алфавите.']);
        end
    end
end

function binaryStr = decToBinary(decNum, numBits)
    binaryStr = '';
    for bitPos = numBits:-1:1
        remainder = mod(decNum,  2);
        binaryStr = [binaryStr num2str(remainder)];
        decNum = floor(decNum /  2);
    end
    
    while length(binaryStr) < numBits
        binaryStr = ['0' binaryStr];
    end
end

function message = svertka(mes)
    len = length(mes);
    mesDouble = [];
    for i = 1:len
        mesDouble(i) = double(mes(i)) - 48;
    end
    disp(mesDouble);
    message = []; 
    for i = 1:len
        x = xor(mesDouble(1), mesDouble(2));
        x = xor(x, mesDouble(4));
        x = xor(x, mesDouble(3)); 
        x = xor(x, mesDouble(5));
        y = xor(mesDouble(1), mesDouble(3));
        y = xor(y, mesDouble(4));
        y = xor(y, mesDouble(6));
        y = xor(y, mesDouble(7));
        message = [message, x, y];
    end
end

function [directed_message, ind_mas] = direct_interleaving(mes)
    directed_message = [];
    len = length(mes);
    ind_mas = randperm(len);    
    for i = 1:len
        directed_message(i) = mes(ind_mas(i));
    end
end


function decode_message = decode_interleaving(mes, ind_mas)
    len = length(mes);
    decode_message =  mes;
    for i = 1:len
        decode_message(ind_mas(i)) = mes(i);
    end
end

function qpsk_mas=qpsk(mes)
    len = length(mes);
    x = 0.707 + 0.707i; 
    y = 0.707 - 0.707i;
    z = -0.707 + 0.707i;
    w = -0.707 - 0.707i;
    qpsk_mas = [];
    for i = 1:2:len
        if mes(i) == 0 && mes(i+1)== 0
            qpsk_mas = [qpsk_mas x];
        end
        if mes(i) == 0 && mes(i+1)== 1
            qpsk_mas = [qpsk_mas y];
        end
        if mes(i) == 1 && mes(i+1)== 0
            qpsk_mas = [qpsk_mas z];
        end
        if mes(i) == 1 && mes(i+1)== 1
            qpsk_mas = [qpsk_mas w];
        end
    end
    %plot(qpsk_mas, 'o');
end


function qpsk_dec = qpsk_decode(mes)
    len = length(mes);
    qpsk_dec = [];
    x = 0.707 + 0.707i; 
    y = 0.707 - 0.707i;
    z = -0.707 + 0.707i;
    w = -0.707 - 0.707i;
    for i = 1:len
        if mes(i) == x%00
            qpsk_dec = [qpsk_dec 0];
            qpsk_dec = [qpsk_dec 0];
        end
        if mes(i) == y%01
            qpsk_dec = [qpsk_dec 0];
            qpsk_dec = [qpsk_dec 1];
        end
        if mes(i) == z%10
            qpsk_dec = [qpsk_dec 1];
            qpsk_dec = [qpsk_dec 0];
        end
        if mes(i) == w%11
            qpsk_dec = [qpsk_dec 1];
            qpsk_dec = [qpsk_dec 1];
        end
    end
    disp(qpsk_dec);
end
   
function ofdm_mes = ofdm_modulation(mes)
    len = length(mes);
    x = 0.707 + 0.707i; 
    ofdm_mes = [];
    rs = input("Введите период размещения опорных поднесущих ");
    nrs = len/rs;
    
    for i = 1:len
        if mod(i, rs) == 0 || i == 1
            ofdm_mes = [ofdm_mes x];
        end
        ofdm_mes = [ofdm_mes mes(i)];
    end

    c = 3;
    nz = c*length(ofdm_mes);
    
    for i = 1:nz
        ofdm_mes = [0 ofdm_mes];
        ofdm_mes = [ofdm_mes 0];
    end

    ofdm_mes = ifft(ofdm_mes);
    
    pref_num = 2;
    ofdm_mes = circshift(ofdm_mes, pref_num);
    %plot(ofdm_mes, 'o');
    x = linspace(1, length(ofdm_mes), length(ofdm_mes));
    %plot(x, ofdm_mes);
    plot(abs(fft(ofdm_mes)))
end