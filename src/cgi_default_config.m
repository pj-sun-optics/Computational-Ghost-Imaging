function cfg = cgi_default_config()
%CGI_DEFAULT_CONFIG Default configuration for CGI simulation.

cfg.random_seed = 20260305;

% Imaging setup
cfg.image_name = 'cameraman.tif';
cfg.N = 128;            % Spatial resolution: N x N
cfg.M_ratio = 6;        % Measurements = M_ratio * N^2

% Numerical setup
cfg.batch_size = 512;   % Batch size for streaming computation
cfg.pattern_probability = 0.5; % Bernoulli random pattern probability

% Reconstruction refinement
cfg.enable_enhancement = true;
cfg.enhance_sigma = 0.8;
cfg.enhance_amount = 0.7;

% Output
cfg.output_dir_name = 'results';
cfg.output_figure_name = 'cgi_result.png';
cfg.output_reconstruction_name = 'cgi_reconstruction.png';
cfg.output_data_name = 'cgi_result.mat';

% Logging
cfg.verbose = true;
cfg.progress_print_interval = 5;
end
