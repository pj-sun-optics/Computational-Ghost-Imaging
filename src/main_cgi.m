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
fprintf('Resolution        : %d x %d\n', result.resolution, result.resolution);
fprintf('Sampling ratio    : %.2f\n', result.sampling_ratio);
fprintf('Measurements      : %d\n', result.measurements);
fprintf('PSNR              : %.2f dB\n', result.metrics.psnr_db);
fprintf('MAE               : %.4f\n', result.metrics.mae);
fprintf('NCC               : %.4f\n', result.metrics.ncc);
fprintf('Saved figure      : %s\n', result.paths.figure_path);
fprintf('Saved recon image : %s\n', result.paths.reconstruction_path);
