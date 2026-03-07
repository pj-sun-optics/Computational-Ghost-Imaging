function img_out = enhance_reconstruction(img_in, sigma, amount, enable_adaptive_equalization)
%ENHANCE_RECONSTRUCTION Apply mild edge-preserving enhancement.

sigma = max(sigma, 0.05);
amount = max(amount, 0);

if nargin < 4
    enable_adaptive_equalization = false;
end

radius = max(1, ceil(3 * sigma));
[x, y] = meshgrid(-radius:radius, -radius:radius);
kernel = exp(-(x.^2 + y.^2) / (2 * sigma^2));
kernel = kernel / sum(kernel(:));

smooth_img = conv2(img_in, kernel, 'same');
sharpened = img_in + amount * (img_in - smooth_img);
sharpened = normalize01(sharpened);

if enable_adaptive_equalization && exist('adapthisteq', 'file') == 2
    sharpened = adapthisteq(sharpened, 'ClipLimit', 0.015, 'NumTiles', [8, 8]);
end

img_out = stretch_percentile(sharpened, 0.005, 0.995);
img_out = normalize01(img_out);
end

function img = stretch_percentile(img, low_pct, high_pct)
values = sort(img(:));
n = numel(values);

low_idx = max(1, min(n, floor(low_pct * n)));
high_idx = max(1, min(n, ceil(high_pct * n)));

low_value = values(low_idx);
high_value = values(high_idx);

if high_value <= low_value
    return;
end

img = (img - low_value) / (high_value - low_value);
img = min(max(img, 0), 1);
end
