function [img_recon, total_measurements, tile_info] = reconstruct_tiled_cgi(img_obj, cfg)
%RECONSTRUCT_TILED_CGI Reconstruct a large image using tiled DGI.

[height, width] = size(img_obj);
tile_size = sanitize_pair(cfg.tile_size, [height, width]);
tile_overlap = sanitize_overlap(cfg.tile_overlap, tile_size);

row_starts = compute_tile_starts(height, tile_size(1), tile_overlap(1));
col_starts = compute_tile_starts(width, tile_size(2), tile_overlap(2));

num_tiles = numel(row_starts) * numel(col_starts);
accumulator = zeros(height, width, 'double');
weight_map = zeros(height, width, 'double');
total_measurements = 0;
tile_counter = 0;

if cfg.verbose
    fprintf('Tiled reconstruction grid: %d x %d (%d tiles)\n', ...
        numel(row_starts), numel(col_starts), num_tiles);
end

for row_idx = 1:numel(row_starts)
    for col_idx = 1:numel(col_starts)
        tile_counter = tile_counter + 1;

        row_start = row_starts(row_idx);
        col_start = col_starts(col_idx);
        row_end = min(height, row_start + tile_size(1) - 1);
        col_end = min(width, col_start + tile_size(2) - 1);

        tile = img_obj(row_start:row_end, col_start:col_end);
        tile_measurements = max(round(numel(tile) * cfg.M_ratio), cfg.min_measurements_per_tile);

        tile_cfg = cfg;
        tile_cfg.image_size = size(tile);
        tile_cfg.random_seed = cfg.random_seed + tile_counter - 1;
        tile_cfg.verbose = false;

        [B, R] = simulate_measurements(single(tile(:)), tile_measurements, tile_cfg);
        tile_recon = reconstruct_dgi_streaming(B, R, size(tile), tile_cfg);
        tile_recon = normalize01(tile_recon);

        window = make_tile_window(size(tile), tile_overlap, cfg.tile_blend_floor);
        accumulator(row_start:row_end, col_start:col_end) = ...
            accumulator(row_start:row_end, col_start:col_end) + tile_recon .* window;
        weight_map(row_start:row_end, col_start:col_end) = ...
            weight_map(row_start:row_end, col_start:col_end) + window;

        total_measurements = total_measurements + tile_measurements;

        if should_print_progress(cfg, tile_counter, num_tiles)
            fprintf('[Tiled CGI] tile %d / %d, size = %d x %d, measurements = %d\n', ...
                tile_counter, num_tiles, size(tile, 1), size(tile, 2), tile_measurements);
        end
    end
end

img_recon = accumulator ./ max(weight_map, eps);
img_recon = normalize01(img_recon);

tile_info = struct();
tile_info.num_tiles = num_tiles;
tile_info.num_tile_rows = numel(row_starts);
tile_info.num_tile_cols = numel(col_starts);
tile_info.tile_size = tile_size;
tile_info.tile_overlap = tile_overlap;
end

function starts = compute_tile_starts(axis_length, tile_length, overlap)
tile_length = max(1, round(tile_length));
overlap = max(0, min(round(overlap), tile_length - 1));

if axis_length <= tile_length
    starts = 1;
    return;
end

stride = max(1, tile_length - overlap);
starts = 1:stride:axis_length;
last_start = axis_length - tile_length + 1;

starts = starts(starts <= last_start);
if isempty(starts) || starts(end) ~= last_start
    starts = [starts, last_start];
end
end

function pair = sanitize_pair(value, max_pair)
if isscalar(value)
    pair = [value, value];
else
    pair = value(:).';
end

pair = max(1, round(pair));
pair = min(pair, max_pair);
end

function overlap = sanitize_overlap(value, tile_size)
if isscalar(value)
    overlap = [value, value];
else
    overlap = value(:).';
end

overlap = max(0, round(overlap));
overlap = min(overlap, tile_size - 1);
end

function window = make_tile_window(tile_shape, tile_overlap, floor_value)
floor_value = min(max(floor_value, 0), 0.95);

if all(tile_overlap <= 0)
    window = ones(tile_shape, 'double');
    return;
end

row_window = make_axis_window(tile_shape(1), tile_overlap(1), floor_value);
col_window = make_axis_window(tile_shape(2), tile_overlap(2), floor_value);
window = row_window * col_window.';
end

function axis_window = make_axis_window(axis_length, overlap, floor_value)
axis_window = ones(axis_length, 1, 'double');

if axis_length <= 1 || overlap <= 0
    return;
end

taper = min(overlap, floor(axis_length / 2));
if taper <= 0
    return;
end

angles = linspace(0, pi / 2, taper + 2);
ramp = sin(angles(2:end-1)).^2;
ramp = floor_value + (1 - floor_value) * ramp(:);

axis_window(1:taper) = ramp;
axis_window(end-taper+1:end) = flipud(ramp);
end

function tf = should_print_progress(cfg, tile_counter, num_tiles)
if ~cfg.verbose
    tf = false;
    return;
end

interval = max(1, round(cfg.progress_print_interval));
tf = (tile_counter == 1) || (tile_counter == num_tiles) || (mod(tile_counter, interval) == 0);
end
