% =========================================================================
% Project: Computational Ghost Imaging (CGI) Simulation
% Algorithm: Differential Ghost Imaging (DGI)
% Author: sun optica
% Date: 2026-01-07
% =========================================================================

clc; clear; close all;

%% 1. Parameter Setup
N = 64;                 % Image resolution (64x64 pixels to save time)
M_ratio = 5;            % Sampling ratio (Measurements = M_ratio * Total Pixels)
M = round(N * N * M_ratio); % Total number of measurements (patterns)

disp(['Resolution: ', num2str(N), 'x', num2str(N)]);
disp(['Measurements: ', num2str(M), ' (Ratio: ', num2str(M_ratio), ')']);

%% 2. Load & Process Object (Ground Truth)
% We use the standard 'cameraman' image built into MATLAB
img_orig = imread('cameraman.tif');
img_obj = imresize(double(img_orig), [N, N]); % Resize to N x N
img_obj = (img_obj - min(img_obj(:))) / (max(img_obj(:)) - min(img_obj(:))); % Normalize to [0,1]

% Visualization
figure(1);
subplot(1, 2, 1);
imagesc(img_obj); colormap('gray'); axis square; axis off;
title('Ground Truth (Object)');

%% 3. Simulation Process (Data Acquisition)
disp('Simulating data acquisition...');

% Pre-allocate for speed

% Patterns: 3D array [N, N, M] storing M random binary patterns

Patterns = rand(N, N, M) > 0.5; 

% Bucket Signals (Single-pixel detector readings)
B = zeros(M, 1);

for i = 1:M
    % P_i is the i-th random pattern
    P_i = Patterns(:, :, i);
    
    % The bucket detector measures the total light intensity after modulation
    % B_i = sum( sum( P_i .* Object ) )
    B(i) = sum(sum(P_i .* img_obj));
    
    if mod(i, 500) == 0
        fprintf('Measurement %d / %d completed.\n', i, M);
    end
end

%% 4. Reconstruction (Differential Ghost Imaging Algorithm)
disp('Reconstructing image...');

% DGI Formula:  G = <(B - <B>) * (P - <P>)> / <P^2>
% Note: We use a simplified correlation for efficiency here.

B_mean = mean(B);       % Mean of bucket signals
Img_recon = zeros(N, N);

% Vectorized reconstruction (Faster than loop)
% Reshape Patterns to [N^2, M] for matrix multiplication
P_flat = reshape(Patterns, [N*N, M]); 

% Calculate weight for each measurement: (B_i - <B>)
Weights = B - B_mean;

% Weighted sum of patterns
Img_flat = P_flat * Weights;

% Reshape back to 2D image
Img_recon = reshape(Img_flat, [N, N]);

%% 5. Result Visualization
subplot(1, 2, 2);
imagesc(Img_recon); colormap('gray'); axis square; axis off;
title(['Reconstructed (DGI, M=', num2str(M), ')']);

% Save result
saveas(gcf, '../results/cgi_result.png');
disp('Done! Result saved to ../results/cgi_result.png');