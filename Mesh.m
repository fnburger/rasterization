%
% Copyright 2022 TU Wien.
% Institute of Computer Graphics and Algorithms.
%

classdef Mesh < handle
    %MESH stores all the information of a loaded model.
    %   The mesh consists of faces (initially triangles) which consist of
    %   vertices.

    properties (GetAccess = public, SetAccess = private)
        vert_per_face % maximum number of vertices per face, default 9
        V_position % #vpf x n x 4    - #vpf vertices per face, vertex store
        V_color % see vertices but only RGB values
        V_screen_position % #vpf x n x 3 values with x, y and depth components
        faces % f x 1 - number of vertices per face, face store
        num_vertices % initial number of vertices
        num_faces % initial number of faces
    end

    methods
        function obj = Mesh(V, C, F)
            % Constructor for the class Mesh.
            % V      ... n x 4 matrix where each row corresponds to a
            %            vertex position.
            % C      ... n x 3 matrix where each row corresponds to a
            %            vertex color.
            % F      ... f x 3 matrix where each row corresponds to a
            %            triangle with 3 vertex indices.

            obj.vert_per_face = 9;
            % Clipping of a 3D triangle against a 3D box can yield up to 9
            % vertices.
            if nargin ~= 0
                num_faces = size(F, 1);
                obj.num_faces = num_faces;
                obj.num_vertices = size(V, 1);
                obj.V_position = zeros(obj.vert_per_face*num_faces, 4);
                obj.V_color = zeros(obj.vert_per_face*num_faces, 3);
                obj.V_screen_position = zeros(obj.vert_per_face*num_faces, 3);
                obj.faces = 3 * ones(num_faces, 1); % default use triangles

                for i = 1:num_faces
                    j = obj.vert_per_face * (i - 1) + 1;
                    obj.V_position(j:j+2, :) = V(F(i, :), :);
                    obj.V_color(j:j+2, :) = C(F(i, :), :);
                end
            else
                obj.num_faces = 0;
                obj.num_vertices = 0;
                obj.V_position = [];
                obj.V_color = [];
                obj.V_screen_position = [];
                obj.faces = [];
            end
        end

        function ret = getFace(obj, i)
            % Returns the face/faces with index/indices i.
            % If any of the indices in i is out of bounds an error will be
            % thrown!
            % obj   ... this pointer
            % i     ... face index/indices which should be accessed. This
            %           can either be a scalar to select one face or a
            %           vector to select multiple faces at once.
            % ret   ... MeshFace object with index/indices i of this mesh.

            if ~isnumeric(i)
                error('Index must be numeric!');
            elseif any(i < 0) || any(i > size(obj.faces, 1))
                error(['Index ', int2str(i), ' out of bounds!']);
            elseif size(i, 1) > 1 && size(i, 2) > 1 || numel(size(i)) > 2
                error('Index must be a scalar or vector!');
            end
            ret = MeshFace(obj, i);
        end

        function addFace(obj, vertex_count, positions, colors)
            % Adds a face to this mesh. The face has vertex_count vertices with
            % positions corresponding to rows of the parameter positions and
            % colors corresponding to rows of the parameter colors. There have
            % to be at least as many rows in positions and colors as the value
            % of vertex_count.
            % obj            ... this pointer
            % vertex_count   ... number of vertices of the new face
            % positions      ... n x 4 matrix where each row corresponds to a
            %                    vertex position
            % colors         ... n x 3 matrix where each row corresponds to a
            %                    vertex color

            if vertex_count < 1 || vertex_count > obj.vert_per_face
                error(['Cannot add face with ', num2str(vertex_count), ' vertices. A face must have more than 1 and less than ', num2str(obj.vert_per_face), ' vertices!']);
            elseif vertex_count > size(positions, 1)
                error('There have to be at least as many positions as in vertex count defined!');
            elseif vertex_count > size(colors, 1)
                error('There have to be at least as many color as in vertex count defined!');
            elseif size(positions, 2) ~= 4 || size(colors, 2) ~= 3
                error('Positions or colors have the wrong format! Positions must have 4 components and colors 3!');
            end

            positions_ = zeros(obj.vert_per_face, 4);
            colors_ = zeros(obj.vert_per_face, 3);
            positions_(1:vertex_count, :) = positions(1:vertex_count, :);
            colors_(1:vertex_count, :) = colors(1:vertex_count, :);
            obj.faces = [obj.faces; vertex_count];
            obj.V_position = [obj.V_position; positions_];
            obj.V_color = [obj.V_color; colors_];
            obj.V_screen_position = [obj.V_screen_position; zeros(obj.vert_per_face, 3)];
        end

        function homogenize(obj)
            % Homogenizes all positions of this mesh. This is done by dividing
            % each position by its w component.
            % obj   ... this pointer

            if size(obj.V_position, 1) > 0
                obj.V_position = obj.V_position ./ repmat(obj.V_position(:, 4), [1, 4]);
            end
        end

        function screenTransform(obj, width, height)
            % Performs the viewport or screen transform where 3 coordinates
            % in NDC space are transformed to screen coordinates (pixel
            % coordinates).
            % obj     ... this pointer
            % width   ... width of the framebuffer
            % height  ... height of the framebuffer

            if size(obj.V_position, 1) > 0
                eps = 0.001;
                sx = (width - eps) / 2.0;
                dx = (width - eps) / 2.0;
                sy = (height - eps) / -2.0;
                dy = (height - eps) / 2.0;
                obj.V_screen_position(:, 1) = int32(floor(obj.V_position(:, 1)*sx+dx)) + 1;
                obj.V_screen_position(:, 2) = int32(floor(obj.V_position(:, 2)*sy+dy)) + 1;
                obj.V_screen_position(:, 3) = obj.V_position(:, 3);
            end
        end

        function ret = export(obj)
            % Prepares mesh data for export into .MAT file
            % obj     ... this pointer
            ret.vert_per_face = obj.vert_per_face;
            ret.V_position = obj.V_position;
            ret.V_color = obj.V_color;
            ret.V_screen_position = obj.V_screen_position;
            ret.faces = obj.faces;
            ret.num_vertices = obj.num_vertices;
            ret.num_faces = obj.num_faces;
        end
    end

    methods (Static)
        function ret = import(cdata)
            % Imports a mesh previously exported using export()
            % cdata     ... data to import, generated by mesh.export()
            % ret       ... Mesh object containing cdata
            ret = Mesh();
            ret.vert_per_face = cdata.vert_per_face;
            ret.V_position = cdata.V_position;
            ret.V_color = cdata.V_color;
            ret.V_screen_position = cdata.V_screen_position;
            ret.faces = cdata.faces;
            ret.num_vertices = cdata.num_vertices;
            ret.num_faces = cdata.num_faces;
        end
    end

end
