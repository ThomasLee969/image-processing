%% preprocess_every_dct_coeff: Block splitting, DCT & quantization
function out = preprocess_every_dct_coeff(img, bits, QTAB)
    img = double(img) - 128;  % Convert to double for matrix ops later.

    % Ensure row/col is a multiple of 8.
    origin_size = size(img);
    new_size = ceil(origin_size / 8) * 8;
    left = new_size - origin_size;
    img = padarray(img, left, 'replicate', 'post');

    out = zeros(64, numel(img) / 64);  % Placeholder for the answer.

    % Scanning blocks.
    k = 1;
    for row = 1:8:new_size(1)
        for col = 1:8:new_size(2)
            c = dct2(img(row:row+7, col:col+7));  % DCT.
            c = round(c ./ QTAB);                 % Quantize.

            % Insert bits here.
            insert_range = (1:min(length(bits), 64))';
            c(insert_range) = bitset(c(insert_range), 1, bits(insert_range), ...
                                     'int8');
            bits(insert_range) = [];

            out(:, k) = c(zigzag(8));             % Zig-Zag.
            k = k + 1;
        end
    end
