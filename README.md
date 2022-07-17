# Rasterization
This Matlab project includes an implementation of the Bresenham algorithm, Sutherland-Hodgman algorithm and more.
They are used to draw 3D objects from data onto a computer screen using pixel rasterization, either as lines or filled (color).
The framework was provided by the Institute of Computer Graphics and Algorithms at TU Wien, 2022. The data folder contains the data of 3D objects that can be used with this program. Fully rasterized they should look like the screenshots inside the references folder.

## linerasterization.m
This file includes the Bresenham algorithm inside the "drawLine" function. It is based on pseudo code from Wikipedia but I extended it so not only lines in the first quadrant can be drawn, but every line works. The color and depth values for each pixel are calculated using the helper function "mix", which can be found in the MeshVertex.m file.

## fillrasterization.m
Here i implemented the ability to draw the 3D objects fully filled with colors, as opposed to the wire mesh versions produced by the Bresenham algorithm. The code is based on triangle math and line equations. Color and depth values are again calculated by a helper function which uses barycentric coordinates to interpolate the values over the triangle's faces.

## clip.m
The Sutherland-Hodgman algorithm is used to create the possibility of a clip space, so we do not have to render the whole 3D object on the screen. This way we can "zoom" in and only show parts of an object on the screen.
