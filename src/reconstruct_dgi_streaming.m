function img_recon = reconstruct_dgi_streaming(B, R, image_size, cfg)
%RECONSTRUCT_DGI_STREAMING Streaming two-pass DGI reconstruction.
%
% Formula (discrete form):
%   G(x,y) = < (B_i - alpha * R_i) * (P_i(x,y) - <P(x,y)>) >
% where alpha = <B>/<R>.

if isscalar(image_size)
    image_size = [image_size, image_size];
else
    image_size = image_size(:).';
end

M = numel(B);
N2 = prod(image_size);
batch_size = max(1, round(cfg.batch_size));
num_batches = ceil(M / batch_size);

alpha = mean(B) / (mean(R) + eps);
weights = B - alpha * R;
sum_weights = sum(weights);

acc = zeros(N2, 1, 'double');
pattern_sum = zeros(N2, 1, 'double');

rng(cfg.random_seed, 'twister');

for batch_idx = 1:num_batches
    start_idx = (batch_idx - 1) * batch_size + 1;
    end_idx = min(batch_idx * batch_size, M);
    idx = start_idx:end_idx;
    k = numel(idx);

    patterns = double(rand(N2, k) < cfg.pattern_probability);
    w = weights(idx);

    acc = acc + patterns * w;
    pattern_sum = pattern_sum + sum(patterns, 2);

    if should_print_progress(cfg, batch_idx, num_batches)
        fprintf('[Reconstruction] batch %d / %d (%d / %d)\n', ...
            batch_idx, num_batches, end_idx, M);
    end
end

img_flat = (acc - pattern_sum * (sum_weights / M)) / M;
img_recon = reshape(img_flat, image_size);
end

function tf = should_print_progress(cfg, batch_idx, num_batches)
if ~cfg.verbose
    tf = false;
    return;
end

interval = max(1, round(cfg.progress_print_interval));
tf = (batch_idx == 1) || (batch_idx == num_batches) || (mod(batch_idx, interval) == 0);
end
