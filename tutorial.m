%
% Copyright 2022 TU Wien.
% Institute of Computer Graphics and Algorithms.
%

% load mesh data
mesh = loadTransformedModel('data/star.ply', 800/600);

% this is a short tutorial to get into the EVC rasterization framework.

% classes and objects in MATLAB

% objects of a certain class are created as follows:
framebuffer = Framebuffer(800, 600); % creates an object of the class Framebuffer

% arrays of objects are also simple to create
planes(1) = ClippingPlane([0, 0, 0, 0]);
planes(2) = ClippingPlane([0, 0, 0, 0]);
planes(3) = ClippingPlane([0, 0, 0, 0]);


% about our mesh interface

% public properties of the mesh can be accessed via '.'
mesh.num_faces % number of faces
mesh.num_vertices % number of vertices

% acces methods of the mesh like in java
mesh.homogenize();

% static methods of a class are accessed like this
MeshVertex.mix(1, 5, 0.5)

% traversing the mesh
% NOTE: indices start with 1 instead of 0 (unlike Java)!
face1 = mesh.getFace(1); % returns the first face as an MeshFace object
v1 = face1.getVertex(1); % return the first vertex of the first face as an MeshVertex object
pos1 = v1.getPosition() % returns the position of the vertex above
col1 = v1.getColor() % returns the color of the vertex above

% you can also get more than one face/vertex by using vectors as indices
faces = mesh.getFace(1:3); % returns the first 3 faces of the mesh
% properties and methods can still be accessed in the same way
verts = faces.getVertex(1:3).getPosition() % positions of all 3 vertices of the first 3 faces

% you can also retrieve the number of vertices a face has
mesh.faces(1) % returns the number of vertices of the first face (3 before clipping)
% with this number you can get all vertices of a face at once (3 before
% clipping, might be more than 3 after clipping)
mesh.getFace(1).getVertex(1:mesh.faces(1)).getPosition() % returns positions of all vertices of the first face
% of course vector indices can be combined as well
mesh.getFace(1:mesh.num_faces).getVertex(1:3).getPosition() % return positions of the first 3 vertices for every face of the mesh

% the Framebuffer class is used to store the image which contains the rasterized mesh.
% a pixel in the framebuffer can be set with the setPixel method:
framebuffer.setPixel(1, 1, 0, [1, 0, 0]); % sets first pixel with coordinates (1, 1) to red
% the third parameter defines the depth and is necessary to determine
% overlapping regions and to prevent overwriting a pixel which is actually
% nearer than another one. (parts of objects might hide other objects)

% you can also set multiple pixels at once:
framebuffer.setPixel([1, 2, 3], [1, 2, 3], [0.5, 0.5, 0.5], [1, 0, 0; 0, 1, 0; 0, 0, 1]);
% where each entry of the vectors (and row of matrix) defines one pixel
% in this example all pixels have the depth 0.5
% pixel 1 with position (1, 1) is colored in red (1, 0, 0)
% pixel 2 with position (2, 2) is colored in green (0, 1, 0)
% pixel 3 with position (3, 3) is colored in blue (0, 0, 1)
