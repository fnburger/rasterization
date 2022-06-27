%
% Copyright 2022 TU Wien.
% Institute of Computer Graphics and Algorithms.
%

classdef Framebuffer < handle
    %FRAMEBUFFER stores necessary information to display a rendered image.
    %            The framebuffer consists of a 3 channel image and a z-buffer.

    properties (GetAccess = public, SetAccess = private)
        image
        zbuffer
        height
        width
        channels
    end

    methods
        function obj = Framebuffer(width, height)
            % Constructor for the class Framebuffer.
            % width      ... width of the framebuffer
            % height     ... height of the framebuffer

            obj.width = width;
            obj.height = height;
            obj.channels = 3;
            obj.image = zeros(height, width, obj.channels);
            obj.zbuffer = ones(height, width);
        end

        function fb = copy(obj)
            % Copy Constructor for the class Framebuffer.
            % width      ... width of the framebuffer

            fb = Framebuffer(obj.width, obj.height);
            fb.image = obj.image;
            fb.zbuffer = obj.zbuffer;
        end

        function setPixel(obj, x, y, depth, color)
            % Sets the pixel with the position (x, y) to a given color. The
            % pixel is only set if it lies "in front" of the current z-buffer
            % value.
            % x         ... x position of pixel
            % y         ... y position of pixel
            % depth     ... depth of new pixel (x, y)
            % color     ... color to set for pixel (x, y)

            if any(x < 1) || any(y < 1) || any(x > obj.width) || any(y > obj.height)
                x_idx = find(x < 1 | x > obj.width);
                y_idx = find(y < 1 | y > obj.width);
                oob_idx = union(x_idx, y_idx);
                oob_coords = [x(oob_idx), y(oob_idx)];

                msg = sprintf('Index (%i, %i) out of bounds!\n', oob_coords');
                error(msg);
            elseif ~isnumeric(depth)
                error('Depth must be a scalar!');
            elseif ~isequal(size(depth), size(x)) || ~isequal(size(y), size(x))
                error('Dimensions of x, y and depth are not uniform!');
            elseif ~any(size(color) == 3)
                error('Color must have 3 components!');
            end

            % Get index of depth at point (x,y)
            indices = sub2ind(size(obj.zbuffer), y, x);

            % Get index of depth value fulfilling new_depth < old_depth
            newDepth = find(depth < obj.zbuffer(indices));

            % Replace old_depth with new_depth
            obj.zbuffer(indices(newDepth)) = depth(newDepth);

            % Convert color to row vector
            if size(color, 2) ~= 3
                color = color';
            end

            % Replace old_color with new_color
            windowSize = obj.height * obj.width;
            obj.image(indices(newDepth)) = color(newDepth, 1); % R
            obj.image(indices(newDepth)+windowSize) = color(newDepth, 2); % G
            obj.image(indices(newDepth)+windowSize*2) = color(newDepth, 3); % B
        end

        function ret = getPixel(obj, x, y)
            % Gets the color of a specific pixel (x, y).
            % x         ... x position of pixel
            % y         ... y position of pixel
            % ret       ... color of pixel (x, y) with 3 components

            if x < 1 || y < 1 || x > obj.width || y > obj.height
                error('Index out of bounds!');
            end

            ret = obj.image(y, x, :);
        end

        function clear(obj)
            % Clears the framebuffer to zeros.

            obj.image = zeros(obj.height, obj.width, obj.channels);
            obj.zbuffer = ones(obj.height, obj.width);
        end
    end

end
