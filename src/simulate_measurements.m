function [B, R] = simulate_measurements(obj_vec, M, cfg)
%SIMULATE_MEASUREMENTS Simulate bucket detector data using random patterns.

N2 = numel(obj_vec);
batch_size = max(1, round(cfg.batch_size));
num_batches = ceil(M / batch_size);

B = zeros(M, 1, 'single');
R = zeros(M, 1, 'single');

rng(cfg.random_seed, 'twister');

for batch_idx = 1:num_batches
    start_idx = (batch_idx - 1) * batch_size + 1;
    end_idx = min(batch_idx * batch_size, M);
    idx = start_idx:end_idx;
    k = numel(idx);

    patterns = single(rand(N2, k) < cfg.pattern_probability);

    B(idx) = (obj_vec.' * patterns).';
    R(idx) = sum(patterns, 1).';

    if should_print_progress(cfg, batch_idx, num_batches)
        fprintf('[Acquisition] batch %d / %d (%d / %d)\n', ...
            batch_idx, num_batches, end_idx, M);
    end
end

B = double(B);
R = double(R);
end

function tf = should_print_progress(cfg, batch_idx, num_batches)
if ~cfg.verbose
    tf = false;
    return;
end

interval = max(1, round(cfg.progress_print_interval));
tf = (batch_idx == 1) || (batch_idx == num_batches) || (mod(batch_idx, interval) == 0);
end
