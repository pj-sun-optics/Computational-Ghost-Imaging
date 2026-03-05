function img_norm = normalize01(img)
%NORMALIZE01 Normalize image values into [0, 1].

min_v = min(img(:));
max_v = max(img(:));

if max_v <= min_v
    img_norm = zeros(size(img), 'like', img);
    return;
end

img_norm = (img - min_v) / (max_v - min_v);
end
