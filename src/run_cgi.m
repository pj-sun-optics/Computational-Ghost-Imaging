function result = run_cgi(cfg)
%RUN_CGI Run computational ghost imaging simulation and reconstruction.

N = cfg.N;
M = round(N * N * cfg.M_ratio);

if cfg.verbose
    fprintf('Resolution: %d x %d\n', N, N);
    fprintf('Measurements: %d (ratio = %.2f)\n', M, cfg.M_ratio);
end

img_obj = load_object_image(cfg.image_name, N);
obj_vec = single(img_obj(:));

if cfg.verbose
    fprintf('Simulating acquisition...\n');
end
[B, R] = simulate_measurements(obj_vec, M, cfg);

if cfg.verbose
    fprintf('Reconstructing with DGI...\n');
end
img_raw = reconstruct_dgi_streaming(B, R, N, cfg);
img_raw = normalize01(img_raw);

if cfg.enable_enhancement
    img_refined = enhance_reconstruction(img_raw, cfg.enhance_sigma, cfg.enhance_amount);
else
    img_refined = img_raw;
end

metrics = compute_metrics(img_obj, img_refined);
paths = save_results_and_figure(img_obj, img_raw, img_refined, cfg, M, metrics);

result = struct();
result.resolution = N;
result.sampling_ratio = cfg.M_ratio;
result.measurements = M;
result.metrics = metrics;
result.paths = paths;
end
