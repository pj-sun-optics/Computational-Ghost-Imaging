# Computational Ghost Imaging (CGI) Simulation

MATLAB implementation of **Computational Ghost Imaging (CGI)** with a refactored, modular pipeline and a more robust **Differential Ghost Imaging (DGI)** reconstruction.

## Mathematical Principle

The object transmission is denoted as $T(x,y)$ and the $i$-th random illumination pattern is $P_i(x,y)$.

The bucket detector signal is:

$$
B_i = \iint P_i(x,y)\,T(x,y)\,dx\,dy
$$

For normalized DGI reconstruction:

$$
G(x,y)=\left\langle\left(B_i-\alpha R_i\right)\left(P_i(x,y)-\left\langle P(x,y)\right\rangle\right)\right\rangle,\quad
\alpha=\frac{\langle B\rangle}{\langle R\rangle},\quad
R_i=\sum_{x,y} P_i(x,y)
$$



## Simulation Result

![CGI Result](results/cgi_result.png)
*Left: Ground Truth, Middle: Raw DGI, Right: Refined Reconstruction*

## What Was Improved

- Code reorganized from one script into modular functions.
- Default reconstruction upgraded to **1080x1920** output with tiled CGI.
- Reconstruction upgraded to a normalized DGI form with reference-arm normalization.
- Acquisition and reconstruction now run in **streaming batches** (two-pass with fixed RNG seed), avoiding storage of large 3D pattern arrays.
- Large images are reconstructed tile by tile so the code can target megapixel-scale outputs without storing full-frame random pattern volumes.
- Added stronger post-processing enhancement for finer visual detail.
- Output now includes:
  - High-resolution comparison figure
  - Reconstruction-only image
  - `.mat` data file with configuration and metrics

## Project Structure

```text
src/
  main_cgi.m                    % Entry script
  cgi_default_config.m          % Central parameter configuration
  run_cgi.m                     % Pipeline orchestration
  load_object_image.m           % Image loading and normalization
  simulate_measurements.m       % Streaming measurement simulation
  reconstruct_dgi_streaming.m   % Streaming DGI reconstruction
  reconstruct_tiled_cgi.m       % Tiled megapixel reconstruction
  enhance_reconstruction.m      % Post-reconstruction enhancement
  normalize01.m                 % Utility normalization
  compute_metrics.m             % PSNR/MAE/NCC metrics
  save_results_and_figure.m     % Save figure/image/data

results/
  cgi_result.png
  cgi_reconstruction.png
  cgi_result.mat
```

## Usage

1. Open MATLAB in this repository root.
2. Run:
   ```matlab
   run('src/main_cgi.m')
   ```
3. Adjust parameters in `src/cgi_default_config.m`.

## Recommended Parameter Presets

- Fast preview:
  - `cfg.image_size = [256, 256];`
  - `cfg.acquisition_mode = 'single';`
  - `cfg.M_ratio = 6;`
  - `cfg.batch_size = 256;`

- High-quality square reconstruction:
  - `cfg.image_size = [512, 512];`
  - `cfg.acquisition_mode = 'tiled';`
  - `cfg.tile_size = [64, 64];`
  - `cfg.M_ratio = 8;`

- 1080p large-scale reconstruction:
  - `cfg.image_size = [1080, 1920];`
  - `cfg.acquisition_mode = 'tiled';`
  - `cfg.tile_size = [48, 48];`
  - `cfg.tile_overlap = [8, 8];`
  - `cfg.M_ratio = 10;`
  - `cfg.min_measurements_per_tile = 12000;`

## Notes

- Direct full-frame random-pattern DGI at 1080p is computationally prohibitive.
- The tiled mode trades global full-frame sampling for block-wise reconstruction, which is much more practical for megapixel outputs.
- Runtime still grows rapidly with image size, tile size, and `M_ratio`.

---
Keywords: Single-Pixel Imaging, Ghost Imaging, Differential GI, Inverse Problems, MATLAB
