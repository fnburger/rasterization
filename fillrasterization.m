%
% Copyright 2022 TU Wien.
% Institute of Computer Graphics and Algorithms.
%

function fillrasterization(mesh, framebuffer)
%FILLRASTERIZATION iterates over all faces of mesh and rasterizes them
%       by coloring every pixel in the framebuffer covered by the triangle.
%       Faces with more than 3 vertices are triangulated after the clipping stage.
%     mesh                  ... mesh object to rasterize
%     framebuffer           ... framebuffer

for i = 1:numel(mesh.faces)
    v1 = mesh.getFace(i).getVertex(1);
    for j = 2:mesh.faces(i) - 1
        v2 = mesh.getFace(i).getVertex(j);
        v3 = mesh.getFace(i).getVertex(j+1);
        drawTriangle(framebuffer, v1, v2, v3);
    end
end
end

function drawTriangle(framebuffer, v1, v2, v3)
%drawTriangle draws a filled triangle between v1, v2 and v3 into the
%   framebuffer using barycentric coordinates. Therefore the bounding box
%   of the triangle is computed as the minimum and maximum screen
%   coordinates of the given vertices. Then every pixel of this bounding
%   box is traversed and line equations are used to determine whether a
%   pixel is inside or outside the triangle. Furthermore, those line
%   equations are helpful to compute the barycentric coordinates of this
%   pixel. Then the color can be easily interpolated with the
%   MeshVertex.barycentricMix() function.
%     framebuffer           ... framebuffer
%     v1                    ... vertex 1
%     v2                    ... vertex 2
%     v3                    ... vertex 3

[x1, y1, depth1] = v1.getScreenCoordinates();
[x2, y2, depth2] = v2.getScreenCoordinates();
[x3, y3, depth3] = v3.getScreenCoordinates();
col1 = v1.getColor();
col2 = v2.getColor();
col3 = v3.getColor();

% Calculate triangle area * 2
a = ((x3 - x1) * (y2 - y1) - (x2 - x1) * (y3 - y1));

if a ~= 0
    % Swap order of clockwise triangle to make them counter-clockwise
    if a < 0
        t = x2;
        x2 = x3;
        x3 = t;
        t = y2;
        y2 = y3;
        y3 = t;
        t = depth2;
        depth2 = depth3;
        depth3 = t;
        t = col2;
        col2 = col3;
        col3 = t;
    end

    % TODO 3: Implement this function.
    % HINT:   Don't forget to implement the function lineEq!
    %         Read the instructions and tutorial.m for further explanations!
    % BONUS:  Solve this task without using loops and without using loop
    %         emulating functions (e.g. arrayfun).
    
    % Bereite Geradengleichungen vor
    v1 = [x1,y1]; v2 = [x2,y2]; v3 = [x3,y3];
        % Kanten aufstellen
    e1 = v3 - v2; % Vektor v2-->v3 (Kante 1)
    e2 = v1 - v3;
    e3 = v2 - v1;
        % Normalvektoren d. Kanten
    e1_n = [-e1(2), e1(1)]; % entspricht A und B für Gerade 1
    e2_n = [-e2(2), e2(1)]; % A und B für Gerade 2
    e3_n = [-e3(2), e3(1)]; % A und B für Gerade 3
        % C berechnen
    C1 = -(e1_n(1) * v2(1) + e1_n(2) * v2(2));
    C2 = -(e2_n(1) * v3(1) + e2_n(2) * v3(2));
    C3 = -(e3_n(1) * v1(1) + e3_n(2) * v1(2));

    % Erstelle bounding box für das Dreieck
    x_vals = [v1(1), v2(1), v3(1)];
    y_vals = [v1(2), v2(2), v3(2)];
    x_max = max(x_vals);
    x_min = min(x_vals);
    y_max = max(y_vals);
    y_min = min(y_vals);

    % Berechne Linien für v1 bis v3 für später
    line1_v1 = lineEq(e1_n(1), e1_n(2), C1, x1, y1);
    line2_v2 = lineEq(e2_n(1), e2_n(2), C2, x2, y2);
    line3_v3 = lineEq(e3_n(1), e3_n(2), C3, x3, y3);
    
    for x = x_min : x_max % Only look at the points inside the bounding box
        for y = y_min : y_max
            % Check if point is inside triangle
            line1 = lineEq(e1_n(1), e1_n(2), C1, x, y);
            line2 = lineEq(e2_n(1), e2_n(2), C2, x, y);
            line3 = lineEq(e3_n(1), e3_n(2), C3, x, y);
            if (line1 <= 0) && (line2 <= 0) && (line3 <= 0)
                % Berechne baryzent. Koord. d. Punktes (x,y) mittels
                %   der vorher berechneten Linien
                alpha = line1 / line1_v1;
                beta = line2 / line2_v2;
                gamma = line3 / line3_v3;
                % Nutze bary für Farb- u. Tiefeninterpolation
                Farbe = MeshVertex.barycentricMix(col1,col2,col3,alpha,beta,gamma);
                Tiefe = MeshVertex.barycentricMix(depth1,depth2,depth3,alpha,beta,gamma);
                % Draw pixel
                framebuffer.setPixel(x,y,Tiefe,Farbe);
            end
        end
    end

end
end

function res = lineEq(A, B, C, x, y)
%lineEq defines the line equation described by the provided parameters and
%   returns the distance of a point (x, y) to this line.
%     A    ... line equation parameter 1
%     B    ... line equation parameter 2
%     C    ... line equation parameter 3
%     x    ... x coordinate of point to test against the line
%     y    ... y coordinate of point to test against the line
%     res  ... distance of the point (x, y) to the line (A, B, C).

% TODO 3:   Implement this function.
% NOTE:     The following lines can be removed. They prevent the framework
%           from crashing.

res = A*x + B*y + C;

end
