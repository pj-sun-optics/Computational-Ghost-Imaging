function paths = save_results_and_figure(img_gt, img_raw, img_refined, cfg, M, metrics)
%SAVE_RESULTS_AND_FIGURE Save figure, reconstruction image, and MAT results.

src_dir = fileparts(mfilename('fullpath'));
project_root = fileparts(src_dir);
output_dir = fullfile(project_root, cfg.output_dir_name);

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

figure_path = fullfile(output_dir, cfg.output_figure_name);
recon_path = fullfile(output_dir, cfg.output_reconstruction_name);
data_path = fullfile(output_dir, cfg.output_data_name);

fig = figure('Color', 'w', 'Position', [100, 100, 1320, 430]);

subplot(1, 3, 1);
imagesc(img_gt);
colormap('gray');
axis image off;
title(sprintf('Ground Truth (%d x %d)', size(img_gt, 1), size(img_gt, 2)));

subplot(1, 3, 2);
imagesc(img_raw);
colormap('gray');
axis image off;
title(sprintf('Raw DGI (M = %d)', M));

subplot(1, 3, 3);
imagesc(img_refined);
colormap('gray');
axis image off;
title(sprintf('Refined (PSNR %.2f dB)', metrics.psnr_db));

if exist('sgtitle', 'file') == 2
    sgtitle(sprintf('Computational Ghost Imaging, Sampling Ratio = %.2f', cfg.M_ratio));
end

if exist('exportgraphics', 'file') == 2
    exportgraphics(fig, figure_path, 'Resolution', 260);
else
    set(fig, 'PaperPositionMode', 'auto');
    print(fig, figure_path, '-dpng', '-r260');
end

imwrite(img_refined, recon_path);
save(data_path, 'cfg', 'img_gt', 'img_raw', 'img_refined', 'M', 'metrics', '-v7');

paths = struct();
paths.output_dir = output_dir;
paths.figure_path = figure_path;
paths.reconstruction_path = recon_path;
paths.data_path = data_path;
end
