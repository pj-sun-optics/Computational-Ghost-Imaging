function img_obj = load_object_image(image_name, target_size)
%LOAD_OBJECT_IMAGE Read, resize, and normalize the target object.

img = imread(image_name);
if ndims(img) == 3
    img = rgb2gray(img);
end

img = im2double(img);
if isscalar(target_size)
    resize_shape = [target_size, target_size];
else
    resize_shape = target_size(:).';
end

img = imresize(img, resize_shape, 'bicubic');
img_obj = normalize01(img);
end
