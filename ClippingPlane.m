%
% Copyright 2022 TU Wien.
% Institute of Computer Graphics and Algorithms.
%

classdef ClippingPlane < handle
    %PLANE defines an arbitrary plane in 3D space.
    %   The plane equation is stored in Hessian normal form to easily
    %   compute if a given point in space lies in front or behind the
    %   plane.

    properties (GetAccess = public, SetAccess = private)
        plane
    end

    methods
        function obj = ClippingPlane(plane)
            % Constructor for the class ClippingPlane.
            % plane     ... plane stored in Hessian normal form as a 1x4 vector
            %               with the normal vector in first 3 components and the
            %               negative distance to the origin in the last component

            if nargin ~= 0
                obj.plane = plane;
            end
        end

        function ret = inside(obj, position)
            % Checks if a given point lies behind the plane (opposite direction
            % of normal vector). Points lying on the plane are considered to be
            % inside.
            % position  ... homogeneous position with 4 components
            % ret       ... logical value which indicates if the point is
            %               inside or not

            % TODO 2: Implement this function.
            % HINT:   You can access the plane property via obj.plane.
            % NOTE:   The following lines can be removed. They prevent the framework
            %         from crashing.
            
            dot_pr = dot(position, obj.plane); % Skalarprodukt
            % Check if point is on/inside plane
            if dot_pr <= 0
                ret = 1;
            else
                ret = 0;
            end

        end

        function ret = intersect(obj, pos1, pos2)
            % Intersects the plane with a line between pos1 and pos2.
            % pos1      ... homogeneous position with 4 components
            % pos2      ... homogeneous position with 4 components
            % ret       ... normalized intersection value t in [0, 1]

            % TODO 2: Implement this function.
            % HINT:   You can access the plane property via obj.plane.
            % NOTE:   The following lines can be removed. They prevent the framework
            %         from crashing.
            
            la = dot(pos1, obj.plane);
            lb = dot(pos2, obj.plane);
            ret = la / (la - lb);
            % Rektifiziere numerische Ungenauigkeiten
            if inside(obj, pos1)
                ret = ret - 0.000001;
            elseif inside(obj, pos2)
                ret = ret + 0.000001;
            end
            
        end
    end

    methods (Static)

        function ret = getClippingPlanes()
            % Returns a list of 6 clipping planes used for clipping in clip.m.
            % ret       ... list of clipping planes, order doesn't matter

            % TODO 2: Define the correct clip planes.
            % NOTE:   The following lines can be removed. They prevent the framework
            %         from crashing.

            ret(6) = ClippingPlane([1, 0, 0, -1]);
            ret(5) = ClippingPlane([-1, 0, 0, -1]);
            ret(4) = ClippingPlane([0, 1, 0, -1]);
            ret(3) = ClippingPlane([0, -1, 0, -1]);
            ret(2) = ClippingPlane([0, 0, 1, -1]);
            ret(1) = ClippingPlane([0, 0, -1, -1]);
            
        end

    end

end
