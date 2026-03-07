% =========================================================================
% Project: Computational Ghost Imaging (CGI) Simulation
% Algorithm: Differential Ghost Imaging (DGI)
% Author: sun optica
% Refactor Date: 2026-03-05
% =========================================================================

clc; clear; close all;

cfg = cgi_default_config();
result = run_cgi(cfg);

fprintf('\n=== Summary ===\n');
fprintf('Resolution        : %d x %d\n', result.image_size(1), result.image_size(2));
fprintf('Acquisition mode  : %s\n', cfg.acquisition_mode);
fprintf('Sampling ratio    : %.2f\n', result.sampling_ratio);
fprintf('Measurements      : %d\n', result.measurements);
if isfield(result, 'tile_info') && result.tile_info.num_tiles > 1
    fprintf('Tile grid         : %d x %d\n', ...
        result.tile_info.num_tile_rows, result.tile_info.num_tile_cols);
end
fprintf('PSNR              : %.2f dB\n', result.metrics.psnr_db);
fprintf('MAE               : %.4f\n', result.metrics.mae);
fprintf('NCC               : %.4f\n', result.metrics.ncc);
fprintf('Saved figure      : %s\n', result.paths.figure_path);
fprintf('Saved recon image : %s\n', result.paths.reconstruction_path);
