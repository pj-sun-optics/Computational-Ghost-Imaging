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

Plain-text fallback:
`G(x,y)=<(B_i-alpha*R_i)*(P_i(x,y)-<P(x,y)>)>, alpha=<B>/<R>, R_i=sum(P_i)`

## Simulation Result

![CGI Result](results/cgi_result.png)
*Left: Ground Truth, Middle: Raw DGI, Right: Refined Reconstruction*

## What Was Improved

- Code reorganized from one script into modular functions.
- Default resolution upgraded from **64x64** to **128x128**.
- Reconstruction upgraded to a normalized DGI form with reference-arm normalization.
- Acquisition and reconstruction now run in **streaming batches** (two-pass with fixed RNG seed), avoiding storage of large 3D pattern arrays.
- Added mild enhancement (sharpen + percentile stretch) for finer visual detail.
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
  - `cfg.N = 96;`
  - `cfg.M_ratio = 3;`
  - `cfg.batch_size = 512;`

- Higher-quality reconstruction:
  - `cfg.N = 128;`
  - `cfg.M_ratio = 6;`
  - `cfg.batch_size = 512;`

- Even finer details (slower):
  - `cfg.N = 160;`
  - `cfg.M_ratio = 8;`
  - `cfg.batch_size = 256;`

## Notes

- Runtime and memory both grow rapidly with `N` and `M_ratio`.
- Streaming mode keeps memory usage stable compared with storing `N x N x M` patterns.

---
Keywords: Single-Pixel Imaging, Ghost Imaging, Differential GI, Inverse Problems, MATLAB
