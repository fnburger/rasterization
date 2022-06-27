%
% Copyright 2022 TU Wien.
% Institute of Computer Graphics and Algorithms.
%

% main file to start script

function[] = main(model, rasterization_mode)
%MAIN invokes the rasterization pipeline and finally shows the output image.
%       The output image is also saved as 'output.png'.
%     model                 ... name of the model file which should be
%                               rasterized. Must be a file name from the
%                               data folder, e.g. 'plane.ply'
%     rasterization_mode    ... either 'fill' or 'line' to select how the
%                               model is rasterized

clc;
clear workspace;
close all;

if (~exist('model', 'var'))
    disp('A path to a model must be provided.');
    return
end

if (~exist('rasterization_mode', 'var'))
    rasterization_mode = 'line';
end

if (~ischar(rasterization_mode) || ~ischar(model))
    disp('Both input parameters must be strings. Strings in Matlab are written with single quotes.');
    return
end

if ~strcmp(rasterization_mode, 'line') && ~strcmp(rasterization_mode, 'fill')
    disp('Wrong rasterization mode. Please use "line" or "fill".');
    return
end

if ~exist(model, 'file') || ~isfile(model)
    disp('The provided path is not a valid model.')
    return
end

framebuffer = Framebuffer(600, 600);
mesh = loadTransformedModel(model, 1);

try
    % rasterize
    rasterize(mesh, framebuffer, rasterization_mode);
catch ME
    figure;
    imshow(framebuffer.image);

    rethrow(ME);
end

figure;
imshow(framebuffer.image);
imwrite(framebuffer.image, 'output.png');
end
