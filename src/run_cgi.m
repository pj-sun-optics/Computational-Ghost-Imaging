function result = run_cgi(cfg)
%RUN_CGI Run computational ghost imaging simulation and reconstruction.

image_size = cfg.image_size(:).';
num_pixels = prod(image_size);

if cfg.verbose
    fprintf('Resolution: %d x %d\n', image_size(1), image_size(2));
    fprintf('Acquisition mode: %s\n', cfg.acquisition_mode);
end

img_obj = load_object_image(cfg.image_name, image_size);

switch lower(cfg.acquisition_mode)
    case 'single'
        M = round(num_pixels * cfg.M_ratio);
        obj_vec = single(img_obj(:));

        if cfg.verbose
            fprintf('Measurements: %d (ratio = %.2f)\n', M, cfg.M_ratio);
            fprintf('Simulating acquisition...\n');
        end
        [B, R] = simulate_measurements(obj_vec, M, cfg);

        if cfg.verbose
            fprintf('Reconstructing with DGI...\n');
        end
        img_raw = reconstruct_dgi_streaming(B, R, image_size, cfg);
        tile_info = struct('num_tiles', 1, 'tile_size', image_size, 'tile_overlap', [0, 0]);

    case 'tiled'
        if cfg.verbose
            fprintf('Per-tile ratio: %.2f\n', cfg.M_ratio);
            fprintf('Tile size: %d x %d\n', cfg.tile_size(1), cfg.tile_size(2));
            fprintf('Tile overlap: %d x %d\n', cfg.tile_overlap(1), cfg.tile_overlap(2));
        end
        [img_raw, M, tile_info] = reconstruct_tiled_cgi(img_obj, cfg);

    otherwise
        error('Unknown acquisition mode: %s', cfg.acquisition_mode);
end

img_raw = normalize01(img_raw);

if cfg.enable_enhancement
    img_refined = enhance_reconstruction( ...
        img_raw, ...
        cfg.enhance_sigma, ...
        cfg.enhance_amount, ...
        cfg.enable_adaptive_equalization);
else
    img_refined = img_raw;
end

metrics = compute_metrics(img_obj, img_refined);
paths = save_results_and_figure(img_obj, img_raw, img_refined, cfg, M, metrics);

result = struct();
result.image_size = image_size;
result.sampling_ratio = cfg.M_ratio;
result.measurements = M;
result.tile_info = tile_info;
result.metrics = metrics;
result.paths = paths;
end
