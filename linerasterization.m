%
% Copyright 2022 TU Wien.
% Institute of Computer Graphics and Algorithms.
%

function linerasterization(mesh, framebuffer)
%LINERASTERIZATION iterates over all faces of mesh and draws lines between
%                  their vertices.
%     mesh                  ... mesh object to rasterize
%     framebuffer           ... framebuffer

for i = 1:numel(mesh.faces)
    for j = 1:mesh.faces(i)
        v1 = mesh.getFace(i).getVertex(j);
        v2 = mesh.getFace(i).getVertex(mod(j, mesh.faces(i))+1);
        drawLine(framebuffer, v1, v2);
    end
end
end

function drawLine(framebuffer, v1, v2)
%DRAWLINE draws a line between v1 and v2 into the framebuffer using the
%               Bresenham algorithm.
%     framebuffer           ... framebuffer
%     v1                    ... vertex 1
%     v2                    ... vertex 2

[x1, y1, depth1] = v1.getScreenCoordinates();
[x2, y2, depth2] = v2.getScreenCoordinates();

% TODO 1: Implement this function.

% Steigung <= 1 ? else swap axis
swapped_axis = 0;
if abs(y2-y1) > abs(x2-x1)
    tmp1 = x1;
    x1 = y1;
    y1 = tmp1;
    tmp2 = x2;
    x2 = y2;
    y2 = tmp2;
    swapped_axis = 1;
end

% Bresenham
y = y1; x = x1;
dx = abs(x2 - x1); dy = abs(y2 - y1);
d = 2*dy - dx;
dO = 2*dy;
dNO = 2*(dy - dx);

for i = 0 : dx
    signX = sign(x2-x1); signY = sign(y2-y1);
    if d < 0
        d = d + dO;
        x = x + signX;
    else
        d = d + dNO;
        x = x + signX;
        y = y + signY;
    end
    % Berechne Farbe und Tiefe mittels Koeffizient:
    %   Strecke 1. Endpunkt bis aktueller Punkt, durch Gesamtstrecke
    norm_koeff = abs(x1 - x) / dx; 
    farbe = MeshVertex.mix(v1.getColor(), v2.getColor(), norm_koeff);
    tiefe = MeshVertex.mix(depth1, depth2, norm_koeff);
    % Färbe Pixel ; care x - y - axis-swap
    if (swapped_axis == 0) && (y ~= 0) && (x ~= 0) && (x <= 600) && (y <= 600)
        framebuffer.setPixel(x, y, tiefe, farbe);
    elseif (y ~= 0) && (x ~= 0) && (x <= 600) && (y <= 600)
        framebuffer.setPixel(y, x, tiefe, farbe);
    end
end

end
