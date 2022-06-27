%
% Copyright 2022 TU Wien.
% Institute of Computer Graphics and Algorithms.
%

function [clipped_mesh] = clip(mesh, clipping_planes)
%CLIP clips all faces in the mesh M against every clipping plane defined in
%   clipplanes.
%     mesh              ... mesh object to clip
%     clipping_planes   ... array of clipping planes to clip against
%     clipped_mesh      ... clipped mesh

clipped_mesh = Mesh;

for f = 1:numel(mesh.faces)
    positions = mesh.getFace(f).getVertex(1:mesh.faces(f)).getPosition();
    colors = mesh.getFace(f).getVertex(1:mesh.faces(f)).getColor();
    vertex_count = 3;
    for i = 1:numel(clipping_planes)
        [vertex_count, positions, colors] = clipPlane(vertex_count, positions, colors, clipping_planes(i));
    end
    if vertex_count ~= 0
        clipped_mesh.addFace(vertex_count, positions, colors);
    end
end

end

function [vertex_count_clipped, pos_clipped, col_clipped] = clipPlane(vertex_count, positions, colors, clipping_plane)
%CLIPPLANE clips all vertices defined in positions against the clipping
%          plane clipping_plane. Clipping is done by using the Sutherland
%          Hodgman algorithm.
%     vertex_count          ... number of vertices of the face that is clipped
%     positions             ... n x 4 matrix with positions of n vertices
%                               one row corresponds to one vertex position
%     colors                ... n x 3 matrix with colors of n vertices
%                               one row corresponds to one vertex color
%     clipping_plane        ... plane to clip against
%     vertex_count_clipped  ... number of resulting vertices after clipping;
%                               this number depends on how the plane intersects
%                               with the face and therefore is not constant
%     pos_clipped           ... n x 4 matrix with positions of n clipped vertices
%                               one row corresponds to one vertex position
%     col_clipped           ... n x 3 matrix with colors of n clipped vertices
%                               one row corresponds to one vertex color

pos_clipped = zeros(vertex_count+1, 4);
col_clipped = zeros(vertex_count+1, 3);

% TODO 2:   Implement this function.
% HINT 1: 	Read the article about Sutherland Hodgman algorithm on Wikipedia.
%           https://en.wikipedia.org/wiki/Sutherland%E2%80%93Hodgman_algorithm
%           Read the tutorial.m for further explanations!
% HINT 2: 	There is an edge between every consecutive vertex in the positions
%       	matrix. Note: also between the last and first entry!

% NOTE:     The following lines can be removed. They prevent the framework
%           from crashing.

vertex_count_clipped = 0;
if vertex_count > 0
    v2 = positions(vertex_count, :); % Start with v2 = last vertex
    c2 = colors(vertex_count, :); % [r g b]
end

% v2 ... current position ; v1 ... previous position
for i = 1 : vertex_count
    % Initalisierung
    v1 = v2; % v1 becomes old v2 (from previous iteration)
    c1 = c2;
    v2 = positions(i, :);
    c2 = colors(i, :);

    % Berechne Schnittpunkt SP mit Ebene und dessen Farbe
    t = intersect(clipping_plane, v1, v2);
    SP = MeshVertex.mix(v1, v2, t);
    c_SP = MeshVertex.mix(c1, c2, t);
    
    % Fälle
    if inside(clipping_plane, v2)
        if ~inside(clipping_plane, v1)
	        vertex_count_clipped = vertex_count_clipped + 1;
            % Add position
            pos_clipped(vertex_count_clipped, :) = SP;
            col_clipped(vertex_count_clipped, :) = c_SP;
        end
	    vertex_count_clipped = vertex_count_clipped + 1;
        % Add position
        pos_clipped(vertex_count_clipped, :) = v2;
        col_clipped(vertex_count_clipped, :) = c2;

    elseif inside(clipping_plane, v1)
	    vertex_count_clipped = vertex_count_clipped + 1;
        % Add position
        pos_clipped(vertex_count_clipped, :) = SP;
        col_clipped(vertex_count_clipped, :) = c_SP;
        % No need to add v1, it was already looked at in previous iter.
    end

end

end
