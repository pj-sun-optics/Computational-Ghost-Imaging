% =========================================================================
% Computational Ghost Imaging (CGI) Simulation
% Single-file MATLAB script with a clear physical pipeline
% =========================================================================

clc; clear; close all;

%% 0. Parameters
% For a first successful run, keep N at 256.
% If your machine is strong enough, you can try N = 384 or N = 512 later.
image_name = 'cameraman.tif';
N = 256;                    % Object resolution: N x N
M_ratio = 8;                % Number of measurements per pixel
M = round(M_ratio * N * N); % Total measurements
batch_size = 64;            % Number of patterns generated each batch
pattern_probability = 0.5;  % Binary random pattern: 0 or 1
random_seed = 20260307;

% Mild post-processing for a cleaner reconstruction
gaussian_sigma = 0.9;
sharpen_amount = 0.8;

fprintf('Resolution   : %d x %d\n', N, N);
fprintf('Measurements : %d\n', M);
fprintf('Batch size   : %d\n', batch_size);

%% 1. Load the object
% T(x,y) is the transmission or reflection map of the target object.
img_obj = imread(image_name);
if ndims(img_obj) == 3
    img_obj = rgb2gray(img_obj);
end
img_obj = im2double(img_obj);
img_obj = imresize(img_obj, [N, N], 'bicubic');
img_obj = img_obj - min(img_obj(:));
img_obj = img_obj / max(img_obj(:) + eps);

%% 2. Data acquisition
% Each random pattern P_i(x,y) illuminates the object once.
% The bucket detector records only the total transmitted intensity:
%   B_i = sum(sum(P_i .* T))
% We also record R_i = sum(sum(P_i)) for DGI normalization.
fprintf('\n[1/3] Simulating data acquisition...\n');

num_pixels = N * N;
obj_vec = single(img_obj(:));
B = zeros(M, 1);
R = zeros(M, 1);

rng(random_seed, 'twister');
num_batches = ceil(M / batch_size);

for batch_idx = 1:num_batches
    start_idx = (batch_idx - 1) * batch_size + 1;
    end_idx = min(batch_idx * batch_size, M);
    idx = start_idx:end_idx;
    k = numel(idx);

    patterns = single(rand(num_pixels, k) < pattern_probability);
    B(idx) = double((obj_vec.' * patterns).');
    R(idx) = double(sum(patterns, 1).');

    if batch_idx == 1 || batch_idx == num_batches || mod(batch_idx, 20) == 0
        fprintf('  Acquisition batch %d / %d\n', batch_idx, num_batches);
    end
end

%% 3. DGI reconstruction
% Differential Ghost Imaging:
%   G(x,y) = <(B_i - alpha*R_i) * (P_i(x,y) - <P(x,y)>)>
% where alpha = <B>/<R>.
% Because patterns are random, we regenerate the same pattern sequence
% using the same random seed and accumulate the correlation in a second pass.
fprintf('[2/3] Reconstructing the image with DGI...\n');

alpha = mean(B) / (mean(R) + eps);
weights = B - alpha * R;
sum_weights = sum(weights);

accumulator = zeros(num_pixels, 1);
pattern_sum = zeros(num_pixels, 1);

rng(random_seed, 'twister');

for batch_idx = 1:num_batches
    start_idx = (batch_idx - 1) * batch_size + 1;
    end_idx = min(batch_idx * batch_size, M);
    idx = start_idx:end_idx;
    k = numel(idx);

    patterns = double(rand(num_pixels, k) < pattern_probability);
    accumulator = accumulator + patterns * weights(idx);
    pattern_sum = pattern_sum + sum(patterns, 2);

    if batch_idx == 1 || batch_idx == num_batches || mod(batch_idx, 20) == 0
        fprintf('  Reconstruction batch %d / %d\n', batch_idx, num_batches);
    end
end

img_raw = reshape((accumulator - pattern_sum * (sum_weights / M)) / M, [N, N]);
img_raw = img_raw - min(img_raw(:));
img_raw = img_raw / max(img_raw(:) + eps);

%% 4. Simple image enhancement
% The physical reconstruction result is kept as img_raw.
% The refined image only improves visibility for display.
fprintf('[3/3] Enhancing and saving results...\n');

radius = max(1, ceil(3 * gaussian_sigma));
[x, y] = meshgrid(-radius:radius, -radius:radius);
gaussian_kernel = exp(-(x.^2 + y.^2) / (2 * gaussian_sigma^2));
gaussian_kernel = gaussian_kernel / sum(gaussian_kernel(:));

img_smooth = conv2(img_raw, gaussian_kernel, 'same');
img_refined = img_raw + sharpen_amount * (img_raw - img_smooth);
img_refined = img_refined - min(img_refined(:));
img_refined = img_refined / max(img_refined(:) + eps);

sorted_values = sort(img_refined(:));
low_value = sorted_values(max(1, floor(0.01 * numel(sorted_values))));
high_value = sorted_values(min(numel(sorted_values), ceil(0.99 * numel(sorted_values))));
img_refined = (img_refined - low_value) / max(high_value - low_value, eps);
img_refined = min(max(img_refined, 0), 1);

%% 5. Quality metrics
err = img_obj - img_refined;
mse_value = mean(err(:).^2);
psnr_db = 10 * log10(1 / max(mse_value, eps));
mae_value = mean(abs(err(:)));

obj_centered = img_obj(:) - mean(img_obj(:));
recon_centered = img_refined(:) - mean(img_refined(:));
ncc_value = sum(obj_centered .* recon_centered) / ...
    (sqrt(sum(obj_centered.^2)) * sqrt(sum(recon_centered.^2)) + eps);

%% 6. Save results
script_dir = fileparts(mfilename('fullpath'));
project_root = fileparts(script_dir);
output_dir = fullfile(project_root, 'results');

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

figure_path = fullfile(output_dir, 'cgi_result.png');
reconstruction_path = fullfile(output_dir, 'cgi_reconstruction.png');
data_path = fullfile(output_dir, 'cgi_result.mat');

fig = figure('Color', 'w', 'Position', [100, 100, 1320, 430]);

subplot(1, 3, 1);
imagesc(img_obj);
colormap('gray');
axis image off;
title(sprintf('Ground Truth (%d x %d)', N, N));

subplot(1, 3, 2);
imagesc(img_raw);
colormap('gray');
axis image off;
title(sprintf('Raw DGI (M = %d)', M));

subplot(1, 3, 3);
imagesc(img_refined);
colormap('gray');
axis image off;
title(sprintf('Refined (PSNR %.2f dB)', psnr_db));

if exist('sgtitle', 'file') == 2
    sgtitle(sprintf('Computational Ghost Imaging, Sampling Ratio = %.2f', M_ratio));
end

if exist('exportgraphics', 'file') == 2
    exportgraphics(fig, figure_path, 'Resolution', 260);
else
    set(fig, 'PaperPositionMode', 'auto');
    print(fig, figure_path, '-dpng', '-r260');
end

imwrite(img_refined, reconstruction_path);
save(data_path, 'N', 'M_ratio', 'M', 'B', 'R', 'img_obj', 'img_raw', ...
    'img_refined', 'psnr_db', 'mae_value', 'ncc_value', '-v7');

%% 7. Summary
fprintf('\n=== Summary ===\n');
fprintf('Resolution        : %d x %d\n', N, N);
fprintf('Sampling ratio    : %.2f\n', M_ratio);
fprintf('Measurements      : %d\n', M);
fprintf('PSNR              : %.2f dB\n', psnr_db);
fprintf('MAE               : %.4f\n', mae_value);
fprintf('NCC               : %.4f\n', ncc_value);
fprintf('Saved figure      : %s\n', figure_path);
fprintf('Saved recon image : %s\n', reconstruction_path);
