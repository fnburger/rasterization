function rasterize(mesh, framebuffer, rasterization_mode)
%RASTERIZE performs all steps in the rasterization pipeline: Clipping,
%    perspective division, viewport transform, line/fill rasterization.

% clear framebuffer
framebuffer.clear();

% clip mesh
clipping_planes = ClippingPlane.getClippingPlanes();
mesh_clipped = clip(mesh, clipping_planes);

% perspective division and screen (viewport) transform
mesh_clipped.homogenize();
mesh_clipped.screenTransform(framebuffer.width, framebuffer.height);

% rasterization
if strcmp(rasterization_mode, 'line')
    linerasterization(mesh_clipped, framebuffer);
elseif strcmp(rasterization_mode, 'fill')
    fillrasterization(mesh_clipped, framebuffer);
end
end
