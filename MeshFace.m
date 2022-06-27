%
% Copyright 2022 TU Wien.
% Institute of Computer Graphics and Algorithms.
%

classdef MeshFace < handle
    %MESHFACE defines the handle to a face with its properties. The
    %         face references to the face store of the mesh via an
    %         index/indices.

    properties (GetAccess = public, SetAccess = private)
        mesh % A reference to the Mesh
        index % The index (indices) of the referenced faces (vertices)
    end

    methods (Access = {?Mesh})

        function obj = MeshFace(mesh, index)
            % Constructor for the class MeshFace.
            % mesh      ... reference to mesh
            % index     ... index or indices to the face store

            obj.mesh = mesh;
            obj.index = index;
        end

    end

    methods

        function ret = getVertex(obj, i)
            % Returns the vertex/vertices with index/indices i of this face.
            % If any index in i is out of bounds an error will be thrown!
            % obj      ... this pointer
            % i        ... vertex index/indices which should be accessed. This
            %              can either be a scalar to select one vertex or a
            %              vector to select multiple vertices at once.
            % ret      ... MeshVertex object with index/indices i of this face.

            if ~isnumeric(i)
                error('Index must be numeric!');
            elseif any(i < 0)
                error(['Index ', int2str(i), ' out of bounds!']);
            end

            if numel(obj.index) > 1 && numel(i) > 1
                idx = repmat((obj.index - 1)*obj.mesh.vert_per_face, [numel(i), 1]);
                idx = reshape(idx, [1, numel(obj.index) * numel(i)]);
                idx = idx + repmat(i, [1, numel(obj.index)]);
            else
                idx = (obj.index - 1) * obj.mesh.vert_per_face + i;
            end
            ret = MeshVertex(obj.mesh, idx);
        end

        function addVertex(obj, position, color)
            % Adds an vertex with given position and color to this face.
            % A face can store up to 6 vertices. If more are added an error
            % will be thrown!
            % obj       ... this pointer
            % position  ... position of the vertex as a row or column vector
            %               with 4 components.
            % color     ... color of the vertex as a row or column vector
            %               with 3 components.

            if obj.mesh.faces(obj.index) == obj.mesh.vert_per_face
                % no more vertices can be added!
                error(['Cannot add more than ', num2str(obj.mesh.vert_per_face), ' vertices to a face!']);
            elseif numel(position) ~= 4 || numel(color) ~= 3
                error('Position or color has the wrong format! Position must has 4 components and color 3!');
            end

            V_idx = (obj.index - 1) * obj.mesh.vert_per_face + obj.mesh.faces(obj.index) + 1;
            obj.mesh.V_position(V_idx, :) = position;
            obj.mesh.V_color(V_idx, :) = color;
            obj.mesh.faces(obj.index) = obj.mesh.faces(obj.index) + 1;
        end
    end

end
