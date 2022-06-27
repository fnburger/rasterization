%
% Copyright 2022 TU Wien.
% Institute of Computer Graphics and Algorithms.
%

classdef MeshVertex < handle
    %MESHVERTEX defines the handle to a vertex with its properties. The
    %           vertex references to the vertex store of the mesh via an
    %           index/indices.

    properties (GetAccess = public, SetAccess = private)
        mesh % A reference to the Mesh
        index % The index (indices) of the referenced vertex (vertices)
    end

    methods (Access = {?Mesh, ?MeshFace})

        function obj = MeshVertex(mesh, index)
            % Constructor for the class MeshVertex.
            % mesh      ... reference to mesh
            % index     ... index or indices to the vertex store

            obj.mesh = mesh;
            obj.index = index;
        end

    end

    methods

        function ret = getPosition(obj)
            % Returns the position of this vertex/vertices.
            % obj      ... this pointer
            % ret      ... position as a n x 4 matrix where n is the number of
            %              indices of this vertex. Each row corresponds to a
            %              position.

            ret = obj.mesh.V_position(obj.index, :);
        end

        function ret = getColor(obj)
            % Returns the color of this vertex/vertices.
            % obj      ... this pointer
            % ret      ... color as a n x 3 matrix where n is the number of
            %              indices of this vertex. Each row corresponds to a
            %              color.

            ret = obj.mesh.V_color(obj.index, :);
        end

        function [x, y, depth] = getScreenCoordinates(obj)
            % Returns the screen coordinates of this vertex/vertices.
            % obj      ... this pointer
            % x        ... x coordinate/s on the screen
            % y        ... y coordinate/s on the screen
            % depth    ... depth of this vertex

            x = obj.mesh.V_screen_position(obj.index, 1);
            y = obj.mesh.V_screen_position(obj.index, 2);
            depth = obj.mesh.V_screen_position(obj.index, 3);
        end

    end

    methods (Static)

        function res = mix(a, b, t)
            % Linearly interpolates between a and b with the interpolation
            % factor t. a and b must have the same type!
            % a        ... value 1 (can be a scalar or vector)
            % b        ... value 2 (can be a scalar or vector)
            % t        ... interpolation factor (must be in [0, 1]!)
            % res      ... value linearly inerpolated between a and b with factor t

            % TODO 1:   Implement this function.
            % NOTE:     The following lines can be removed. They prevent the
            %           framework from crashing.

            res = a * (1 - t) + b * t;

        end

        function res = barycentricMix(a, b, c, alpha, beta, gamma)
            % Barycentric interpolation between a, b and c with the interpolation
            % factors alpha, beta, gamma. a, b and c must have the same type!
            % The sum of all three interpolation factors must be 1!
            % a        ... value 1 (can be a scalar or vector)
            % b        ... value 2 (can be a scalar or vector)
            % c        ... value 3 (can be a scalar or vector)
            % alpha    ... interpolation factor 1 (must be in [0, 1]!)
            % beta     ... interpolation factor 2 (must be in [0, 1]!)
            % gamma    ... interpolation factor 3 (must be in [0, 1]!)


            % TODO 3:   Implement this function.
            % NOTE:     The following lines can be removed. They prevent the
            %           framework from crashing.

            res = a*alpha + b*beta + c*gamma;

        end

    end

end
