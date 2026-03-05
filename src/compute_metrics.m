function metrics = compute_metrics(img_gt, img_recon)
%COMPUTE_METRICS Compute objective reconstruction quality indicators.

err = img_gt - img_recon;
mse = mean(err(:).^2);

metrics = struct();
metrics.psnr_db = 10 * log10(1 / max(mse, eps));
metrics.mae = mean(abs(err(:)));

gt_centered = img_gt(:) - mean(img_gt(:));
recon_centered = img_recon(:) - mean(img_recon(:));
metrics.ncc = sum(gt_centered .* recon_centered) / ...
    (sqrt(sum(gt_centered.^2)) * sqrt(sum(recon_centered.^2)) + eps);
end
