%
% Copyright 2022 TU Wien.
% Institute of Computer Graphics and Algorithms.
%

classdef ViewerUI < handle
    %VIEWERUI main UI class

    properties (Access = private)
        % ui controls/properties
        fig
        last_file
        last_fb_file
        last_file_name
        ui_img_axes
        ui_file_panel
        ui_file
        ui_file_vertices
        ui_file_faces
        ui_rasterize
        ui_saveas

        % framework properties
        framebuffer
        mesh
        mesh_clipped
        rasterization_mode
    end

    methods
        function obj = ViewerUI()

            % init framework
            obj.framebuffer = Framebuffer(600, 600);
            obj.rasterization_mode = 'line';

            % init GUI
            obj.fig = figure('Name', 'EVC Rasterizer', ...
                'Visible', 'off', 'Position', [360, 500, 900, 600], ...
                'Resize', 'off');
            set(obj.fig, 'menubar', 'none');

            % file panel
            img_panel = uipanel(obj.fig, 'Units', 'pixels', ...
                'Position', [1, 1, 600, 600]);
            set(img_panel, 'BorderType', 'none');
            set(img_panel, 'BorderWidth', 0.0);
            obj.ui_img_axes = axes('Units', 'pixels', 'Position', [1, 1, 600, 600], ...
                'Parent', img_panel);
            imshow(obj.framebuffer.image, 'Parent', obj.ui_img_axes);

            obj.ui_file_panel = uipanel(obj.fig, 'Title', 'Model', 'Units', 'pixels', ...
                'Position', [650, 450, 200, 140], 'Units', 'normalized');
            uicontrol(obj.ui_file_panel, 'Style', 'pushbutton', 'String', 'Load Model...', ...
                'Position', [5, 100, 80, 20], 'Units', 'normalized', 'Callback', @obj.loadModelPressed);
            obj.ui_file = uicontrol(obj.ui_file_panel, 'Style', 'text', 'String', 'No model selected', 'Position', [5, 70, 200, 20], 'HorizontalAlignment', 'left');
            obj.ui_file_vertices = uicontrol(obj.ui_file_panel, 'Style', 'text', 'String', 'Vertices: 0', 'Position', [5, 40, 110, 20], 'HorizontalAlignment', 'left');
            obj.ui_file_faces = uicontrol(obj.ui_file_panel, 'Style', 'text', 'String', 'Faces: 0', 'Position', [5, 10, 110, 20], 'HorizontalAlignment', 'left');

            % rasterization mode panel
            rasterization_mode_grp = uibuttongroup('Visible', 'off', ...
                'Units', 'pixels', ...
                'Position', [650, 380, 200, 56], ...
                'Units', 'normalized', ...
                'SelectionChangeFcn', @obj.rasterizationModeChanged, ...
                'Title', 'Rasterization mode');
            uicontrol(rasterization_mode_grp, 'Style', 'radio', 'String', 'line', ...
                'Position', [5, 15, 80, 20], 'Units', 'normalized', 'HandleVisibility', 'off');
            uicontrol(rasterization_mode_grp, 'Style', 'radio', 'String', 'fill', ...
                'Position', [65, 15, 80, 20], 'Units', 'normalized', 'HandleVisibility', 'off');
            set(rasterization_mode_grp, 'Visible', 'on');

            % rasterize panel
            obj.ui_rasterize = uicontrol(obj.fig, 'Style', 'pushbutton', 'String', 'Rasterize', ...
                'Position', [650, 320, 200, 30], 'Units', 'normalized', 'Callback', @obj.rasterizePressed);

            % save as panel
            obj.ui_saveas = uicontrol(obj.fig, 'Style', 'pushbutton', 'String', 'Save as ...', ...
                'Position', [650, 280, 200, 30], 'Units', 'normalized', 'Callback', @obj.saveAsPressed);

            % show GUI
            movegui(obj.fig, 'center');
            set(obj.fig, 'Visible', 'on');
        end

        function loadModelPressed(obj, ~, ~)
            % only allow ply files
            filters = {'*.ply', 'PLY Files (*.ply)'; ...
                '*.*', 'All Files (*.*)'};
            if isempty(obj.last_file)
                [filename, pathname] = uigetfile(filters, 'Load Model...');
            else
                [filename, pathname] = uigetfile(filters, 'Load Model...', obj.last_file);
            end
            if ~(isnumeric(filename) && isnumeric(pathname))
                set(obj.ui_rasterize, 'Enable', 'off');

                obj.last_file = [pathname, filename];
                obj.last_file_name = filename;
                obj.mesh = loadTransformedModel(obj.last_file, obj.framebuffer.width/obj.framebuffer.height);

                set(obj.ui_file, 'String', obj.last_file_name);
                set(obj.ui_file_vertices, 'String', ['Vertices: ', num2str(obj.mesh.num_vertices)]);
                set(obj.ui_file_faces, 'String', ['Faces: ', num2str(obj.mesh.num_faces)]);
                set(obj.ui_rasterize, 'Enable', 'on');
            end
        end

        function rasterizationModeChanged(obj, ~, event)
            obj.rasterization_mode = event.NewValue.String;
        end

        function rasterizePressed(obj, ~, ~)
            if ~isempty(obj.mesh)
                set(obj.ui_rasterize, 'Enable', 'off');

                try
                    % rasterize
                    rasterize(obj.mesh, obj.framebuffer, obj.rasterization_mode);

                    % show rasterized mesh
                    imshow(obj.framebuffer.image, 'Parent', obj.ui_img_axes);
                catch ME
                    % show rasterized mesh
                    imshow(obj.framebuffer.image, 'Parent', obj.ui_img_axes);

                    set(obj.ui_rasterize, 'Enable', 'on');
                    rethrow(ME);
                end

                set(obj.ui_rasterize, 'Enable', 'on');
            end
        end

        function saveAsPressed(obj, ~, ~)
            if ~isempty(obj.mesh)
                % only allow png files
                filters = {'*.png', 'PNG Files (*.png)'; ...
                    '*.*', 'All Files (*.*)'};
                if isempty(obj.last_fb_file)
                    [filename, pathname] = uiputfile(filters, 'Save Framebuffer...');
                else
                    [filename, pathname] = uiputfile(filters, 'Load Model...', obj.last_fb_file);
                end
                if ~(isnumeric(filename) && isnumeric(pathname))
                    set(obj.ui_rasterize, 'Enable', 'off');

                    obj.last_fb_file = [pathname, filename];
                    imwrite(obj.framebuffer.image, obj.last_fb_file);

                    set(obj.ui_rasterize, 'Enable', 'on');
                end
            end
        end
    end

end
