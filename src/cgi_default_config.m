function cfg = cgi_default_config()
%CGI_DEFAULT_CONFIG Default configuration for CGI simulation.

cfg.random_seed = 20260305;

% Imaging setup
cfg.image_name = 'cameraman.tif';
cfg.image_size = [1080, 1920]; % [height, width]
cfg.acquisition_mode = 'tiled'; % 'single' or 'tiled'
cfg.M_ratio = 10;       % Measurements per pixel inside each reconstruction unit
cfg.min_measurements_per_tile = 12000;

% Tiled large-scale reconstruction
cfg.tile_size = [48, 48];
cfg.tile_overlap = [8, 8];
cfg.tile_blend_floor = 0.20;

% Numerical setup
cfg.batch_size = 128;   % Batch size for streaming computation
cfg.pattern_probability = 0.5; % Bernoulli random pattern probability

% Reconstruction refinement
cfg.enable_enhancement = true;
cfg.enable_adaptive_equalization = true;
cfg.enhance_sigma = 0.9;
cfg.enhance_amount = 0.9;

% Output
cfg.output_dir_name = 'results';
cfg.output_figure_name = 'cgi_result.png';
cfg.output_reconstruction_name = 'cgi_reconstruction.png';
cfg.output_data_name = 'cgi_result.mat';

% Logging
cfg.verbose = true;
cfg.progress_print_interval = 5;
end
