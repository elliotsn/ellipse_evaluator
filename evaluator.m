function varargout = evaluator(varargin)
% EVALUATOR MATLAB code for evaluator.fig
%      EVALUATOR, by itself, creates a new EVALUATOR or raises the existing
%      singleton*.
%
%      H = EVALUATOR returns the handle to a new EVALUATOR or the handle to
%      the existing singleton*.
%
%      EVALUATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EVALUATOR.M with the given input arguments.
%
%      EVALUATOR('Property','Value',...) creates a new EVALUATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before evaluator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to evaluator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Generally this code contains functions that are directly linked to
% the functionality of UI elements, such as Callbacks.
% Where possible logic and program functionality is deferred to 
% functions in external source files.

%  Copyright 2016  Elliot Sefton-Nash

    % Initialization
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @evaluator_OpeningFcn, ...
                       'gui_OutputFcn',  @evaluator_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT    
end

% Executes just before evaluator is made visible.
function evaluator_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to evaluator (see VARARGIN)

    % Choose default command line output for evaluator
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes evaluator wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = evaluator_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% NOTE: The arguments 'hObject, eventdata, handles' MUST be passed to a
% callback function in order to address using the @ notation from another
% function in this GUI.
 

% Calls layerPBAdd, which is in a separate .m file. Adds layers to the GUIs
% layer list.
function layerPBAdd_Callback(hObject, eventdata, handles)
    
    setStatus('Loading layer...');

    rasterLayers = layerPBAdd();
    % If not an empty array add these layers to the guidata.
    if ~isempty(rasterLayers)
        
        % NOTE: gcbf if the handle of the figure that contains the object
        % whose callback is executing. We use this to our advantage because
        % we can store effectively global variables in the guidata of the
        % main figure.
        %
        % Data are accessed using: data = guidata(gcbf);
        % And set using:                  guidata(gcbf, dat)
        %
        % The structure 'handles' contains handles to UI elements, but also
        % further structures containing user data:
        %      handles.layers  - Cell array of rasterLayer objects that are
        %                        loaded in the list of layers.
        data = guidata(gcbf);
        
        % If the layers field doesn't exist, make and empty cell array.
        if ~isfield(data,'layers')
            data.layers = {};
            data.nlayers = 0;
        end
        
        if data.nlayers == 0
            % If these are new layers, enable the layer controls.
            data = setLayerControls(data, 'on');
        end

        % Add each new raster layer.
        for i = 1:numel(rasterLayers)
            
            data.nlayers = data.nlayers + 1;
            data.layers{data.nlayers} = rasterLayers{i};
            
            % If the layer added is now the only layer, then we select it.
            if data.nlayers == 1
                data.layerListBox.Value = data.nlayers;
            end
            
            % Add this layer to the layerListBox
            data.layerListBox.String = ...
                vertcat(data.layerListBox.String,{data.layers{data.nlayers}.fname});

            % Update setbounds listbox on the Evaluate tab
            data.evaluateSetBoundsPopup.String = data.layerListBox.String;
            data.evaluateSetBoundsPopup.Value = data.layerListBox.Value;
            
            % If this is the last layer in the list to be added, update layer controls 
            % passing only required structures and selected layer from 'data'.
            [data.layerMinEdit, data.layerMaxEdit, data.layerMinSlider,...
                data.layerMaxSlider, data.layerCBInvert, data.layers{data.nlayers}] = ...
                setlayerMinMaxEditSliders(...
                data.layerMinEdit,data.layerMaxEdit,...
                data.layerMinSlider, data.layerMaxSlider, data.layerCBInvert,...
                data.layers{data.nlayers});
        end
        
        % Put guidata back
        guidata(gcbf, data);
    end
    setStatus('Ready.');
end

% Remove a layer from the list of layers
function layerPBRemove_Callback(hObject, eventdata, handles)
    
    setStatus('Removing layer...');
    
    data = guidata(gcbf);
    
    if data.nlayers > 0
    
        % The array position of the layer should be the same as the list
        % position.
        data.nlayers = data.nlayers - 1;
        
        % Index of layer to remove.
        i = data.layerListBox.Value;
        
        % Index of selected layer should be same as array index in
        % layers.
        %data.layerListBox.String = ...
        %    data.layerListBox.String([1:data.layerListBox.Value-1,data.layerListBox.Value+1:end]);
        
        % Make empty elements in cell arrays of listbox and for rasterlayer
        % objects, to delete layer.
        data.layerListBox.String{i} = [];
        data.layers{i} = [];
        
        % Remove empty elements from these arrays.
        data.layers = removeEmptyCells(data.layers);
        data.layerListBox.String = removeEmptyCells(data.layerListBox.String);
        
        % Update setbounds listbox
        data.evaluateSetBoundsPopup.String = data.layerListBox.String;
        data.evaluateSetBoundsPopup.Value = data.layerListBox.Value;

        % If there was only one layer, then now there are none. disable layer controls.
        if data.nlayers == 0
            
            data.layerListBox.String = {};
            data.layerListBox.Value = 0;
            
            % Remove the min,max values from the threshold controls
            data.layerMinEdit.String = '';
            data.layerMaxEdit.String = '';
            
            % Reset the set bounds listbox - produces warning if Value <= 0
            % || isempty(String)
            data.evaluateSetBoundsPopup.String = ' '; % Requires non-empty string.
            data.evaluateSetBoundsPopup.Value = 1;
            
            data = setLayerControls(data, 'off');
            
        else
            % If still layers left, set selected layer back to first layer.
            data.layerListBox.Value = 1;
            data.evaluateSetBoundsPopup.Value = data.layerListBox.Value;
        end
    end
    % Put guidata back
    guidata(gcbf, data);
    setStatus('Ready.');
end

% Remove empty cells from a cell array.
function A = removeEmptyCells(A)
	A(cellfun(@(A) isempty(A),A))=[];
end

% When min slider is adjusted, update layer edit box and layer minthresh
function layerMinSlider_Callback(hObject, eventdata, handles)
    data = guidata(gcbf);
    % Slider can only be adjusted within min and max ranges of current
    % layer, so new values are intrinsically range- and format-validated.
    % Get new value of slider.
    v = data.layerMinSlider.Value;
    % Index of selected layer.
    i = data.layerListBox.Value;
    % Only set values if value has changed. Avoids running when mouse click
    % without slider drag.
    if v ~= data.layers{i}.threshmin
        % If value is above threshmax for this layer then set it to threshmax.
        if v > data.layers{i}.threshmax
            v = data.layers{i}.threshmax;
            % Set slider back to maximum allowed position.
            data.layerMinSlider.Value = v;
        end
        % Set edit box and layer threshmin.
        data.layers{i}.threshmin = v;
        data.layerMinEdit.String = num2str(v);
    end
    % Put guidata back
    guidata(gcbf, data);
end

% When max slider is adjusted, update layer edit box and layer maxthresh
function layerMaxSlider_Callback(hObject, eventdata, handles)
    data = guidata(gcbf);
    % Slider can only be adjusted within min and max ranges of current
    % layer, so new values are intrinsically range- and format-validated.
    % Get new value of slider.
    v = data.layerMaxSlider.Value;
    % Index of selected layer.
    i = data.layerListBox.Value;
    % Only set values if value has changed. Avoids running when mouse click
    % without slider drag.
    if v ~= data.layers{i}.threshmax
        % If value is above threshmax for this layer then set it to threshmax.
        if v < data.layers{i}.threshmin
            v = data.layers{i}.threshmin;
            % Set slider back to minimum allowed position.
            data.layerMaxSlider.Value = v;
        end
        % Set edit box and layer threshmin.
        data.layers{i}.threshmax = v;
        data.layerMaxEdit.String = num2str(v);
    end
    % Put guidata back
    guidata(gcbf, data);
end

% Validate and set new minimum when value is entered.
function layerMinEdit_Callback(hObject, eventdata, handles)
    % Get guidata
    data = guidata(gcbf); 
    % Validate entered strings, returns v as double. Empty if invalid.
    v = validNumeric(data.layerMinEdit.String);
    % If invalid number, set string to empty.
    if isempty(v)
        data.layerMinEdit.String = '';
    else
        % If valid, test if value is between allowed limits.
        if v < data.layers{data.layerListBox.Value}.zmin || v > data.layers{data.layerListBox.Value}.zmax
            % If outside bounds, set minimum to minimum value in raster.
            v = data.layers{data.layerListBox.Value}.zmin;
            data.layerMinEdit.String = num2str(v);
        end
        % Set slider position.
        data.layerMinSlider.Value = v;
        % Update value for layer.
        data.layers{data.layerListBox.Value}.threshmin = v;
    end
    % Put guidata back
    guidata(gcbf, data);
end

% Validate and set new maximum when value is entered.
function layerMaxEdit_Callback(hObject, eventdata, handles)
    % Get guidata
    data = guidata(gcbf); 
    % Validate entered strings, returns v as double. Empty if invalid.
    v = validNumeric(data.layerMaxEdit.String);
    % If invalid number, set string to empty.
    if isempty(v)
        data.layerMaxEdit.String = '';
    else
       % If valid, test if value is between allowed limits.
        if v < data.layers{data.layerListBox.Value}.zmin || v > data.layers{data.layerListBox.Value}.zmax
            % If outside bounds, set maximum to maximum value in raster.
            v = data.layers{data.layerListBox.Value}.zmax;
            data.layerMaxEdit.String = num2str(v);
        end
        % Set slider position.
        data.layerMaxSlider.Value = v;
        % Update value for layer.
        data.layers{data.layerListBox.Value}.threshmax = v;
    end
    % Put guidata back
    guidata(gcbf, data);
end

% Plot the currently selected image in the axes, accounting for the
% thresholds set.
function layerPBPreview_Callback(hObject, eventdata, handles)
    
    setStatus('Plotting layer...');
    
    data = guidata(gcbf); 
    
    % Clear the plot axes.
    cla(data.plot.hAx);
    
     % Index of selected layer with threshold applied.
    i = data.layerListBox.Value;
    
    data.layers{i} = data.layers{i}.calcMask();
    
    imagesc(data.layers{i}.lonvec,data.layers{i}.latvec,...
        data.layers{i}.im,'AlphaData',data.layers{i}.mask,...
        'Parent',data.plot.hAx);
    
    data.plot.hAx.YDir = 'normal';
    data.plot.hAx.DataAspectRatio = [1 1 1];
    xlabel(data.plot.hAx, 'Longitude');
    ylabel(data.plot.hAx, 'Latitude');
    
    % Set title to name of plotted layer
    title(data.plot.hAx, data.layers{i}.fname, 'Interpreter','none');
    
    % Nothing to change in the raster layer, so no need to put back the
    % guidata.
    setStatus('Ready.');
end

% List box callback. When an item in the list box is selected the values in
% the sliders are updated.
function layerLB_Callback(hObject, eventdata, handles)
    % hObject    handle to listbox1 (see GCBO)
    % handles    structure with handles and user data (see GUIDATA)
    % Hints: contents = cellstr(get(hObject,'String')) returns contents
    % contents{get(hObject,'Value')} returns selected item from listbox1
    
    % Get the guidata.
    data = guidata(gcbf);
    % Only if there are any layers loaded
    if data.nlayers > 0    
        
        % Update layer controls for selected layer, passing only required
        % structures and selected layer from 'data'.
        [data.layerMinEdit, data.layerMaxEdit, data.layerMinSlider,...
            data.layerMaxSlider, data.layerCBInvert, data.layers{data.layerListBox.Value}] = ...
            setlayerMinMaxEditSliders(...
            data.layerMinEdit,data.layerMaxEdit,...
            data.layerMinSlider, data.layerMaxSlider, data.layerCBInvert,...
            data.layers{data.layerListBox.Value});
    end
    guidata(gcbf, data);
end

% Function to set relevant properties of edit boxes and threshold sliders
% based on the values set for a particular layer. This is called when
% either a new layer is added or a layer in the list box is selected.
function [layerMinEdit,layerMaxEdit, layerMinSlider,...
    layerMaxSlider, layerCBInvert, thisRasterLayer] = setlayerMinMaxEditSliders(...
    layerMinEdit,layerMaxEdit, layerMinSlider,...
    layerMaxSlider, layerCBInvert, thisRasterLayer)
    
    layerMinEdit.String = num2str(thisRasterLayer.threshmin);
    layerMaxEdit.String = num2str(thisRasterLayer.threshmax);

    % Set the limits of both sliders to the limits of the raster.
    layerMaxSlider.Value = thisRasterLayer.threshmax;
    layerMaxSlider.Max = thisRasterLayer.zmax;
    layerMaxSlider.Min = thisRasterLayer.zmin;

    layerMinSlider.Value = thisRasterLayer.threshmin;
    layerMinSlider.Max = thisRasterLayer.zmax;
    layerMinSlider.Min = thisRasterLayer.zmin;
    
    % Invert box
    layerCBInvert.Value = thisRasterLayer.invert;
end

% Set whether layer has inverted mask or not.
function layerCBInvert_Callback(hObject, eventdata, handles)
    data = guidata(gcbf);
    % Set selected layer invert state.
    data.layers{data.layerListBox.Value}.invert = data.layerCBInvert.Value;
    guidata(gcbf, data);
end


% Edit the minor axis dimension
function ellipseYAEdit_Callback(hObject, eventdata, handles)
    data = guidata(gcbf);
    % If not valid number value gets set empty. Set empty string.
    data.ellipseYAEdit.Value = validNumericAndPositive(data.ellipseYAEdit.String);
    if isempty(data.ellipseYAEdit.Value)
        data.ellipseYAEdit.String = '';
    end
    guidata(gcbf, data);
end

% Edit the major axis dimension
function ellipseXAEdit_Callback(hObject, eventdata, handles)
	data = guidata(gcbf);
    % If not valid number value gets set empty. Set empty string.
    data.ellipseXAEdit.Value = validNumericAndPositive(data.ellipseXAEdit.String);
    if isempty(data.ellipseXAEdit.Value)
        data.ellipseXAEdit.String = '';
    end
    guidata(gcbf, data);
end

% Edit the azimuth in the ellipse tab
function ellipseAzEdit_Callback(hObject, eventdata, handles)
	data = guidata(gcbf);
    
    [data.ellipseAzEdit.String, data.ellipseAzEdit.Value] = ...
    validAz(data.ellipseAzEdit.String, data.ellipseAzEditUnitsListBox.Value);
    
    guidata(gcbf, data);
end

% Edit the longitude position of the ellipse
function ellipseXEdit_Callback(hObject, eventdata, handles)
	data = guidata(gcbf);
    [data.ellipseXEdit.String, data.ellipseXEdit.Value] = validLon(data.ellipseXEdit.String);
    % Ellipse is special case, position has to be somewhere.
    defaultLon = 180;
    if isempty(data.ellipseXEdit.String)
        data.ellipseXEdit.String = num2str(defaultLon);
        data.ellipseXEdit.String = defaultLon;
    end
    guidata(gcbf, data);
end

% Edit the latitude position of the ellipse
function ellipseYEdit_Callback(hObject, eventdata, handles)
	data = guidata(gcbf);
    [data.ellipseYEdit.String, data.ellipseYEdit.Value] = validLat(data.ellipseYEdit.String);
    % Defaults to 0 rather than empty when outside +/-90.
    guidata(gcbf, data);
end

%% No need to convert units when list box is changed.
% Could be an annoyance to user if not desired.
% % List box units edit, convert units if needed.
% function ellipseYAEditUnitsListBox_Callback(hObject, eventdata, handles)
% 	data = guidata(gcbf);
% 	% Get the value of the edit box and convert the units if necessary.
% end
% 
% % List box units edit, convert units if needed.
% function ellipseXAEditUnitsListBox_Callback(hObject, eventdata, handles)
% 	data = guidata(gcbf);
% end
% 
% % List box units edit, convert units if needed.
% function ellipseAzEditUnitsListBox_Callback(hObject, eventdata, handles)
% 	data = guidata(gcbf);
% end

% Callback for when ellipse Preview button is pressed.
function ellipsePreviewPB_Callback(hObject, eventdata, handles)
	data = guidata(gcbf);
    
    plotted = false;
    
    % If layer footprint checkbox is checked & if there are any layers
    % loaded, then plot the footprints of all the raster layers.
    if data.ellipseRasterFootprintCB.Value == 1 && data.nlayers > 0
        % Clear the plot axes.
        cla(data.plot.hAx);
        setStatus('Plotting layer footprints...');
        plotLayerFootprints(data.layers, data.plot.hAx);
        setStatus('Ready.');
        plotted = true;
    end
    
    % If there are no polygons, then there must be an ellipse
    if isempty(data.poly)
  
        % Plot ellipse last == on top.
        % If there are values in the edit boxes. Already validated.
        if ~isempty(data.ellipseXAEdit.Value) && ...
           ~isempty(data.ellipseYAEdit.Value)        

            % Can still plot without having entered a value for azimuth, assume
            % user wants no rotation.
            az = 0;
            if ~isempty(data.ellipseAzEdit.Value)
                % Turn ellipse azimuth into radians for plotting.
                [~, ~, mult] = getAngUnitList();
                az = data.ellipseAzEdit.Value * mult(data.ellipseAzEditUnitsListBox.Value);
            end

            % Turn ellipse dimensions into metres for plotting.
            [~, ~, mult] = getLengthUnitList;
            xa = data.ellipseXAEdit.Value * mult(data.ellipseXAEditUnitsListBox.Value);
            ya = data.ellipseYAEdit.Value * mult(data.ellipseYAEditUnitsListBox.Value);

            % 1 degree angular resolution of the ellipse.
            angRes = pi/180;

            % Set ellipse centre, in metres.
            if isempty(data.ellipseXEdit.Value)
                data.ellipseXEdit.Value = 0;
            else
                % Convert longitude to x-coord.
                clon = data.ellipseXEdit.Value;
            end
            if isempty(data.ellipseYEdit.Value)
                data.ellipseYEdit.Value = 0;
            else
                % Convert to latitude to y-coord.
                clat = data.ellipseYEdit.Value;
            end

            % Values in edit boxes are in latlon, convert to equal-area map coords for
            % drawing ellipse.
            [xc, yc] = latlon2eqa( clat, clon, data.re , data.proj.lat1, data.proj.lonO );

            % Make an ellipse object and put it into data.
            data.ellipse{1} = ellipseObj(xa, ya, az, angRes, xc, yc);

            % Make the ellipses lat,lon coordinates
            fe = 0; fn = 0;
            data.ellipse{1} = data.ellipse{1}.getLatLonFromEqaXY(fe, fn, data.re, data.proj.lat1, data.proj.lonO);

            % If we're plotting the ellipse only, i.e. if layers havn't been drawn here, 
            % then clear the axes, because a previous plot might persist. Can
            % tell by setting of titleStr.
            if ~plotted
                cla(data.plot.hAx);
            end

            % Convention is that hold is normally turned off and re-turned on every time 
            % overlay plotting is required. hold may have been off either because no rasters 
            % were drawn, or because it was set back to off in the function plotRasterLayers.
            hold(data.plot.hAx, 'on');
            plotPoly(data.ellipse{1}.lon, data.ellipse{1}.lat, data.plot.hAx);
            hold(data.plot.hAx, 'off');

            % Wrap the axes to its children
            axis(data.plot.hAx, 'tight');

            % Put data back.
            guidata(gcbf, data);
        end
    
    else
        
        % Clear the axes, because a previous plot might persist.
        if ~plotted
            cla(data.plot.hAx);
        end
        
        % There are polygons, gotta plot them all.
        hold(data.plot.hAx, 'on');
        for i = 1:numel(data.poly)
            plotPoly(data.poly{i}.x, data.poly{i}.y, data.plot.hAx);    
        end
        hold(data.plot.hAx, 'off');
        % Put data back.
        guidata(gcbf, data);
    end
    
    setStatus('Ready.');
end

% Callback for evaluate minimum x coord. edit box
function evaluateXMinEdit_Callback(hObject, eventdata, handles)
	data = guidata(gcbf);
    [data.evaluateXMinEdit.String, data.evaluateXMinEdit.Value] = validLon(data.evaluateXMinEdit.String);
    guidata(gcbf, data); 
end

% Callback for evaluate x coord. interval edit box
function evaluateXStepEdit_Callback(hObject, eventdata, handles)
    data = guidata(gcbf);
    [data.evaluateXStepEdit.String, data.evaluateXStepEdit.Value] = validLon(data.evaluateXStepEdit.String);
    guidata(gcbf, data);
end

% Callback for evaluate maximum x coord. edit box
function evaluateXMaxEdit_Callback(hObject, eventdata, handles)
    data = guidata(gcbf);
    [data.evaluateXMaxEdit.String, data.evaluateXMaxEdit.Value] = validLon(data.evaluateXMaxEdit.String);
    guidata(gcbf, data); 
end

% Callback for evaluate minimum y coord. edit box
function evaluateYMinEdit_Callback(hObject, eventdata, handles)
	data = guidata(gcbf);
    [data.evaluateYMinEdit.String, data.evaluateYMinEdit.Value] = validLat(data.evaluateYMinEdit.String);
    guidata(gcbf, data); 
end

% Callback for evaluate y coord. interval edit box
function evaluateYStepEdit_Callback(hObject, eventdata, handles)
    data = guidata(gcbf);
    [data.evaluateYStepEdit.String, data.evaluateYStepEdit.Value] = validLat(data.evaluateYStepEdit.String);
    guidata(gcbf, data);
end

% Callback for evaluate maximum y coord. edit box
function evaluateYMaxEdit_Callback(hObject, eventdata, handles)
    data = guidata(gcbf);
    [data.evaluateYMaxEdit.String, data.evaluateYMaxEdit.Value] = validLat(data.evaluateYMaxEdit.String);
    guidata(gcbf, data); 
end

% Edit the azimuth in the ellipse tab, min
function evaluateAzMinEdit_Callback(hObject, eventdata, handles)
	data = guidata(gcbf);
    [data.evaluateAzMinEdit.String, data.evaluateAzMinEdit.Value] = ...
    validAz(data.evaluateAzMinEdit.String, data.evaluateAzEditUnitsListBox.Value);
    guidata(gcbf, data);
end

% Edit the azimuth in the ellipse tab, step
function evaluateAzStepEdit_Callback(hObject, eventdata, handles)
	data = guidata(gcbf);
    [data.evaluateAzStepEdit.String, data.evaluateAzStepEdit.Value] = ...
    validAz(data.evaluateAzStepEdit.String, data.evaluateAzEditUnitsListBox.Value);
    guidata(gcbf, data);
end

% Edit the azimuth in the ellipse tab, max
function evaluateAzMaxEdit_Callback(hObject, eventdata, handles)
	data = guidata(gcbf);
    [data.evaluateAzMaxEdit.String, data.evaluateAzMaxEdit.Value] = ...
    validAz(data.evaluateAzMaxEdit.String, data.evaluateAzEditUnitsListBox.Value);
    guidata(gcbf, data);
end


% Callback for when evaluate set bounds is called. This is only pressed
% when layers are present, so no need to check that.
function layerEvaluateSetBoundsPB_Callback(hObject, eventdata, handles)
	data = guidata(gcbf);
    
    % Array of layers should be same as order in ellipseLayerListBox
    i = data.evaluateSetBoundsPopup.Value;
    
    % Set values
    data.evaluateXMinEdit.Value = data.layers{i}.lonlims(1);
    data.evaluateXMaxEdit.Value = data.layers{i}.lonlims(2);
    data.evaluateYMinEdit.Value = data.layers{i}.latlims(1);
    data.evaluateYMaxEdit.Value = data.layers{i}.latlims(2);
    
    % Set strings;
    data.evaluateXMinEdit.String = num2str(data.layers{i}.lonlims(1));
    data.evaluateXMaxEdit.String = num2str(data.layers{i}.lonlims(2));
    data.evaluateYMinEdit.String = num2str(data.layers{i}.latlims(1));
    data.evaluateYMaxEdit.String = num2str(data.layers{i}.latlims(2));
    
    guidata(gcbf, data);
end

% Returns 1 if we are in azimuth evaluation mode, 0 if not.
function azMode = getAzMode(val)
    modes = getEvaluateModes();
    azMode = false;
    if strcmpi(modes{val},'azimuth')
        azMode = true;
    end
end

% Callback for when evaluate Preview button is pressed. Purpose of this
% callback is to visualise the spatial extent of the ellipses that will be 
% evaluated, with options for a bounding box and layer footprints.
function layerEvaluatePreviewPB_Callback(hObject, eventdata, handles)
	data = guidata(gcbf);
    
    % Check if a valid ellipse exists, if not there is no point in
    % continuing.
    if isfield(data, 'ellipse')
        if isempty(data.ellipse) || ~iscell(data.ellipse)
            setStatus('No valid ellipse defined.')
            return
        end
    else
        setStatus('No ellipse defined.')
        return
    end

    azMode = getAzMode(data.mode);
    
    % We always plot the cumulative ellipse perimeter and the ellipse
    % centres. If there are large numbers of ellipses the perimeter could just be a 
    % bounding rectangle to speed up the calculation.
    setStatus('Calculating...');
    
    if azMode

        % Check for valid azimuth vector definitions.
        if ~isempty(data.evaluateAzMinEdit.Value) &&...
           ~isempty(data.evaluateAzMaxEdit.Value) &&...
           ~isempty(data.evaluateAzStepEdit.Value)
            % Try to make a vector of azimuths, in radians.
            try
                [~, ~, mult] = getAngUnitList();
                % List box value corresponds to position in arrays returned by
                % getAngUnitList. Convert to radians.
                azVec = validAzVec(data.evaluateAzMinEdit.Value,...
                                   data.evaluateAzStepEdit.Value,...
                                   data.evaluateAzMaxEdit.Value,...
                            mult(data.evaluateAzEditUnitsListBox.Value));

                % Get the ellipse extents at the azimuth range.
                [xEllPoly, yEllPoly] = getEllipseExtentAz(...
                    data.ellipse{1}, azVec, data.re, data.proj.lat1, data.proj.lonO);
                
                % Plot the enclosing area.
                plotExtentPatch(data.plot.hAx,xEllPoly,yEllPoly);
            catch
                % Vector is invalid
                setStatus('Azimuth definition is invalid.');
                return
            end
        else
            setStatus('No valid azimuth vector entered.');
            return
        end
 
    else % Grid mode
        
        % Check that all the required edit boxes have values.
        if ~isempty(data.evaluateXMinEdit.Value) && ~isempty(data.evaluateXMaxEdit.Value) &&...
           ~isempty(data.evaluateYMinEdit.Value) && ~isempty(data.evaluateYMaxEdit.Value) &&... 
           ~isempty(data.evaluateYStepEdit.Value) && ~isempty(data.evaluateXStepEdit.Value)
            
            % Try to make a grid object, if vectors are returned empty then
            % grid is invalid.
            data.grid{1} = grdObj(getVec([data.evaluateXMinEdit.Value data.evaluateXMaxEdit.Value],...
                                          data.evaluateXStepEdit.Value),...
                                  getVec([data.evaluateYMinEdit.Value data.evaluateYMaxEdit.Value],...
                                          data.evaluateYStepEdit.Value) );                        
            
            if isempty(data.grid{1})
                setStatus('Grid definition is invalid.');
                return
            end

            % A valid grid exists if we are here, so find the outer
            % boundary of ellipses at the corners of the grid 
            % (in lat,lon). Ellipses are drawn in equal area 
            % projection, grid is defined in lat lon, but must 
            % convert it to working projection to figure out extent
            data.grid{1} = data.grid{1}.getEqaXYFromLatLon(...
                data.re,data.proj.lat1,data.proj.lonO);

            [xEllPoly, yEllPoly] = getEllipseExtentOnGrid(...
                data.ellipse{1}, data.grid{1},...
                data.re, data.proj.lat1, data.proj.lonO);
        else
            setStatus('No valid grid defined.')
            return
        end
    end
    
    % If we made it here, grid or azVec is valid.
    cla(data.plot.hAx);
    setStatus('Plotting...');

    % PLOT RASTER FOOTPRINTS
    % If the check box is enabled and checked, plot raster layer footprints.
    if strcmpi(data.evaluatePlotRasterFootprintCB.Enable, 'on') && ...
               data.evaluatePlotRasterFootprintCB.Value == 1
        hold(data.plot.hAx, 'on');
        plotLayerFootprints(data.layers, data.plot.hAx);
        hold(data.plot.hAx, 'off');
    end

    % Plot the ellipse bounding polygon.
    plotExtentPatch(data.plot.hAx,xEllPoly,yEllPoly);

    % Plot the ellipse centres.
    if azMode
        xp = data.ellipse{1}.lonc;
        yp = data.ellipse{1}.latc;
    else
        % Plot grid as centre points of each ellipse placement, i.e.
        % each pixel.
        [xp,yp] = meshgrid(data.grid{1}.lonc, data.grid{1}.latc);
    end
    hold(data.plot.hAx, 'on');
    plot(xp(:), yp(:), 'k+', 'Parent',data.plot.hAx);            
    hold(data.plot.hAx, 'off');
    title(data.plot.hAx, 'Ellipse extents');

    guidata(gcbf, data);
    setStatus('Ready.');
end

% Function to enable/disable all the UI elements that require layers to be
% loaded for them to function.
function data = setLayerControls(data, state)
    % Layer controls on layer tab.
    data.layerListBox.Enable = state;
    data.layerPBRemove.Enable = state;
    data.layerMinSlider.Enable = state;
    data.layerMinEdit.Enable = state;
    data.layerMaxSlider.Enable = state;
    data.layerMaxEdit.Enable = state;
    data.layerPBPreview.Enable = state;
    data.layerCBInvert.Enable = state;
    % Draw raster layer footprint checkbox on Ellipse tab.
    data.ellipseRasterFootprintCB.Enable = state;
    % 'Set bounds' PB, Popup and raster CB and  on the Evaluate tab.
    data.evaluateSetBoundsPB.Enable = state;
    data.evaluateSetBoundsPopup.Enable = state;
    data.evaluatePlotRasterFootprintCB.Enable = state;
end

% Status
function setStatus(msg)
    data = guidata(gcbf);
    data.status.String = ['STATUS: ', msg];
end

% Evaluate pushbutton callback. DO THE EVALUATE.
function layerEvaluateEvaluatePB_Callback(hObject, eventdata, handles)

    data = guidata(gcbf);

    % Check for the 3 required items:
    % At least one layer
    goFlag = true;
    if data.nlayers < 1
        setStatus('Can''t evaluate - no layers loaded.')
        return
    end
    
    % A valid ellipse?
    errStr = 'Can''t evaluate - no valid ellipse entered.';
    if ~isfield(data,'ellipse')
        goFlag = false;
    else
        if isempty(data.ellipse)
            goFlag=false;
        end
    end
    if ~goFlag
        setStatus(errStr);
        return
    end
    
    % A valid grid, or azvec
	errStr = 'Can''t evaluate - no valid parameters entered.';
    
    azMode = getAzMode(data.mode);
    if azMode
        [~, ~, mult] = getAngUnitList();
        % List box value corresponds to position in arrays returned by
        % getAngUnitList. Convert to radians.
        data.azVec = validAzVec(data.evaluateAzMinEdit.Value,...
                           data.evaluateAzStepEdit.Value,...
                           data.evaluateAzMaxEdit.Value,...
                    mult(data.evaluateAzEditUnitsListBox.Value));
        if ~data.azVec  % Returned empty if invalid.
            setStatus(errStr);
            return
        end
    else
        % Lat-lon grid mode
        if ~isfield(data,'grid')
            goFlag = false;
        else
            if isempty(data.grid)
                goFlag = false;
            end
        end
        if ~goFlag
            setStatus(errStr);
            return 
        end
    end
    
    % If we made it this far, everything appears valid.
    % Pass all the details to the evaluating routine     
	setStatus('Evaluating...');
     
    % data.ellipse, data.grid and data.layers are cell arrays of thier
    % respective objects. We pass the grid and ellipse objects to
    % evaluateXYCore or evaluateAzCore as single objects not embedded in a
    % cell array. However we DO pass a cell array of rasterLayer objects.
    
    wb = true; % We want a waitbar.
    
    if azMode
        data.result = evaluateAzCore(data.ellipse{1}, data.azVec, data.layers, wb);
    else
        % Make sure the grid has map coordinates. It may not have been
        % previewed.
        data.grid{1} = data.grid{1}.getEqaXYFromLatLon(data.re,data.proj.lat1,data.proj.lonO);
        % Run assessment.
        data.result = evaluateXYCore(data.ellipse{1}, data.grid{1}, data.layers, wb); 
    end

    setStatus('Ready.');
    
    if ~isempty(data.result)
        
        % There is a result. Make the results panel visible.
        data = setResultsControlsState(data, 'on');
    end
    
    guidata(gcbf, data);
end


% Function to set the state of the results panel UI elements.
function data = setResultsControlsState(data, state)    
    % Set control states.
    data.evaluateResultsPreviewPB.Enable = state;
    data.evaluateResultsOutputPB.Enable = state;
    data.evaluateResultsOutputEdit.Enable = state;
    data.evaluateResultsFormatListBox.Enable = state;
    data.evaluateResultsSavePB.Enable = state;
end


% Function to select the output directory from the built-in UI.
function evaluateResultsOutputPB_Callback(hObject, eventdata, handles)

    % Open the directory file selection dialogue.
    dirName = uigetdir(matlabroot, 'Select results output directory');
    
    % A single path is returned, and 0 if nothing is selected.
    if ~isnumeric(dirName)        
        data = guidata(gcbf);
        % Set edit box to returned path.
        data.evaluateResultsOutputEdit.String = dirName;
        guidata(gcbf, data);
    end
end

% Function to write the results
function evaluateResultsSavePB_Callback(hObject, eventdata, handles)

	data = guidata(gcbf);
    % If the results directory is not valid then do not write and set the
    % save path to null.
    if ~exist(data.evaluateResultsOutputEdit.String,'dir')
        data.evaluateResultsOutputEdit.String = '';
        % Warn here that the data directory is not valid.
        warn('Data output directory is invalid.');
    else
        setStatus('Saving results.');
        % Save the results in desired format, ext is the identifier (not
        % desc, which is the string of the list box).
        outfpath = [data.evaluateResultsOutputEdit.String,'/ee_result_',getTimeStrNow()];
        data.result.write(data.mode, data.evaluateResultsFormatListBox.Value, outfpath);
        setStatus('Ready.');
    end
    guidata(gcbf, data);
end

% Function to preview the results.
function evaluateResultsPreviewPB_Callback(hObject, eventdata, data)
    
    data = guidata(gcbf);
    
    % Check whether the result object is a raster, ellipse over x-y
    % position, or ellipse drawn at different azimuths, which would give
    % just a vector of results.
    if isempty(data.result.grid)
        
        % Plot ellTrueFrac, the cumulative result for all layers, 
        % as a function of ellipse azimuth.
        cla(data.plot.hAx);
        [data.hAx, data.hTitle, data.hXLab, data.hYLab, data.hLeg] = ...
            plotEllFracVsAz(data.plot.hAx, data.layers, data.result);
        
    else
        % TODO
        % data.plot.hAx = plotEllFracGrid;
        
        % Assumption is that the results object contains results over a
        % spatial grid object.
        
        % Plot ellTrueFrac, this is the cumulative result for all layers. By
        % plotting only this in the preview functionality we avoid hard choices
        % on how to display the results w.r.t. each layer.
        cla(data.plot.hAx);
        imagesc(data.result.grid.lonc,data.result.grid.latc,...
            data.result.ellTrueFrac,...
            'Parent',data.plot.hAx);
        colorbar;
        data.plot.hAx.YDir = 'normal';
        data.plot.hAx.DataAspectRatio = [1 1 1];
        xlabel(data.plot.hAx, 'Longitude');
        ylabel(data.plot.hAx, 'Latitude');
        title(data.plot.hAx,...
            'Fraction of ellipse at pixel center that meets layer constraints',...
            'Interpreter','none');
    end
end

function evaluateModeListBox_Callback(hObject, eventdata, data)
    allOff = false;
    guidata(gcbf, setEvaluateModeState(guidata(gcbf), allOff));
end

% Function to set the enablement state of ui controls for ellipse
% placement. Optionally, if the boolean, allOff is true, then all controls
% are disabled. This is used when loading ellipses from shapefiles rather
% than defining them.
function data = setEvaluateModeState(data, allOff)
    
    % Find the value of the azimuth list box and set it.
    stateOn = 'on';
    stateOff = 'off';
    
    % Option to disable all controls relating to ellipse definition.
    if allOff
        data.evaluateModeListBox.Enable = stateOff;
        
        data.evaluateAzMinEdit.Enable = stateOff;
        data.evaluateAzStepEdit.Enable = stateOff;
        data.evaluateAzMaxEdit.Enable = stateOff;
        data.evaluateAzEditUnitsListBox.Enable = stateOff;

        data.evaluateXMinEdit.Enable = stateOff;
        data.evaluateXStepEdit.Enable = stateOff;
        data.evaluateXMaxEdit.Enable = stateOff;
        data.evaluateYMinEdit.Enable = stateOff;
        data.evaluateYStepEdit.Enable = stateOff;
        data.evaluateYMaxEdit.Enable = stateOff;
        data.evaluateSetBoundsPB.Enable = stateOff;
        data.evaluateSetBoundsPopup.Enable = stateOff;
    else
        
        % Set the mode as an integer in a top-level variable.
        data.mode = data.evaluateModeListBox.Value;
        evalModes = getEvaluateModes();
    
        switch evalModes{data.evaluateModeListBox.Value}
            case 'azimuth'
                % Make azimuth evaluator controls active, but disable lat-lon.

                data.evaluateAzMinEdit.Enable = stateOn;
                data.evaluateAzStepEdit.Enable = stateOn;
                data.evaluateAzMaxEdit.Enable = stateOn;
                data.evaluateAzEditUnitsListBox.Enable = stateOn;

                data.evaluateXMinEdit.Enable = stateOff;
                data.evaluateXStepEdit.Enable = stateOff;
                data.evaluateXMaxEdit.Enable = stateOff;
                data.evaluateYMinEdit.Enable = stateOff;
                data.evaluateYStepEdit.Enable = stateOff;
                data.evaluateYMaxEdit.Enable = stateOff;
                data.evaluateSetBoundsPB.Enable = stateOff;
                data.evaluateSetBoundsPopup.Enable = stateOff;

            case 'lat-lon'
                % Make lat-lon evaluator controls active, but disable azimuth.
                data.evaluateAzMinEdit.Enable = stateOff;
                data.evaluateAzStepEdit.Enable = stateOff;
                data.evaluateAzMaxEdit.Enable = stateOff;
                data.evaluateAzEditUnitsListBox.Enable = stateOff;

                data.evaluateXMinEdit.Enable = stateOn;
                data.evaluateXStepEdit.Enable = stateOn;
                data.evaluateXMaxEdit.Enable = stateOn;
                data.evaluateYMinEdit.Enable = stateOn;
                data.evaluateYStepEdit.Enable = stateOn;
                data.evaluateYMaxEdit.Enable = stateOn;

                % Only enable if there are layers loaded.
                if data.nlayers > 0
                    data.evaluateSetBoundsPB.Enable = stateOn;
                    data.evaluateSetBoundsPopup.Enable = stateOn;
                end
        end
        % Set the content of the write file formats list box.
        [desc, ~, ~] = getFileFormatWriteList(data.mode);
        data.evaluateResultsFormatListBox.String = desc;
    end
    
end

% Save plot
function plotSavePB_Callback(hObject, eventdata, data)

    data = guidata(gcbf);

    % Luckily there is a function that does most of this for us.
    defaultName = ['ee_',getTimeStrNow()];
    
    % List of file types and descriptions.
    [desc, ext] = getImageFormatWriteList();
    extAst = cellfun(@(x) ['*.' x], ext, 'UniformOutput', false);
    filterSpec = [extAst', desc'];

    [filename, pathname] = uiputfile(filterSpec, 'Save Plot As', defaultName);
    
    if ~isequal(filename,0) && ~isequal(pathname,0)
        % Save this file using the given extension.
        fpath = fullfile(pathname, filename);
        
        % Allows for extensions that are not exactly 3 characters.
        thisExt = lower(reverse(strtok(reverse(fpath),'.')));
        
        % Sanity check on extension
        if any(strcmp(ext,thisExt))
            success = writeAx(data.plot, fpath, thisExt);
            if isempty(success)
                setStatus('File save failed.');
            end
        else
            setStatus('Invalid image file format, plot not saved.'); 
        end
    end
end


% Load a polygon from a shapefile
function ellipseLoadPB_Callback(hObject, eventdata, data)
    
    data = guidata(gcbf);    
    
    % Makes load UI and populates cell array of poly objects if
    % shapefile is valid.
    data.poly = shapeLoad();
    
    if isempty(data.poly)
        setStatus('Unable to load shapefile.');
    else
        % There are polygons now defined, disable the user 
        % controls for manual ellipse definition.
        data = setEllipseControlsState(data, 'off');
        
        setStatus('Loaded polygon(s) in shapefile.');
    end
    guidata(gcbf, data);
end

% Function to set the state of the controls involved in defining the
% ellipse size and placement, on both the ellipse tab AND the evaluate tab.
function data = setEllipseControlsState(data, state)    
    
    % Ellipse tab, definition panel
    data.ellipseXAEdit.Enable = state;
    data.ellipseXAEditUnitsListBox.Enable = state;
    data.ellipseYAEdit.Enable = state;
    data.ellipseYAEditUnitsListBox.Enable = state;
    data.ellipseAzEdit.Enable = state;
    data.ellipseAzEditUnitsListBox.Enable = state;
    data.ellipseXEdit.Enable = state;
    data.ellipseYEdit.Enable = state;
    
    % Evaluate tab, placement panel
    allOff = true;
    data = setEvaluateModeState(data, allOff);
    
    % If we are re-enabling the Evaluate tab, we must reset the ui elements
    % according to whether the ellipse is evaluated over azimuth or
    % lat-lon.
    if strcmpi(state,'on')
        allOff = false;
        % Re-enable the evaluate mode list box. This is not set in
        % setEvaluateModeState.
        data.evaluateModeListBox.Enable = 'on';
        data = setEvaluateModeState(data, allOff);
    end
    
end

% Call back for Clear Loaded Pushbutton on ellipse define tab.
function ellipseClearLoadedPB_Callback(hObject, eventdata, data)
    data = guidata(gcbf);
    % Re-enable ellipse defintion controls
    data = setEllipseControlsState(data, 'on');
    % Remove shapefiles from data
    data.poly = {};
    % Clear the axes in case there is anything plotted.
    cla(data.plot.hAx);
    guidata(gcbf, data)
end

% --- Executes during object creation, after setting all properties.
function evaluatorCreate(hObject, eventdata, data) %#ok<DEFNU>
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % data    empty - data not created until after all CreateFcns called
    
    % Radius of the planet. In this case, Mars is a sphere. IAU2000
    % equatorial radius.
    data.re = 3396190;
    
    % Set up projection parameters for Lambert Equal Area Cylindrical,
    % in which everything is plot.
    data.proj.lat1 = 0;  % 1st standard parallel at equator.
    data.proj.lonO = 0;  % Prime meridian at 0 degrees.
    
    data.fig = hObject;
%     data.fig.Units = 'pixels';
%     data.fig.Position = [600 400 1480 780];
%     data.fig.Resize = 'on';
%     data.fig.PaperType = 'A3';
%     data.fig.PaperOrientation = 'Landscape';
%     
    % Make tab groups
    data.tabgroup = uitabgroup(data.fig,'Position',[.01 .11 .28 .88],...
        'Units', 'normalized');
    data.tabLayers = uitab(data.tabgroup,'Title','Layers');
    data.tabEllipse = uitab(data.tabgroup,'Title','Ellipse');
    data.tabEvaluate = uitab(data.tabgroup,'Title','Evaluate');

    stateOn = 'on';
    stateOff = 'off';
    
    % Populate tabs
    % --- LAYERS ---
    data.layerListBox = uicontrol(data.tabLayers,'Style','listbox',...
                    'Units','normalized','Position',[.05 .67 .9 .3],...
                    'Visible', 'on','Value',[],...
                    'Enable',stateOff,...
                    'Callback',@layerLB_Callback);
    % Add layer pushbutton
    data.layerPBAdd = uicontrol(data.tabLayers,'Style','pushbutton',...
                    'Units','normalized','Position',[.18 .6 .24 .055],...
                    'Visible', 'on', 'String', 'Add',...
                    'Callback',@layerPBAdd_Callback);
    % Remove layer pushbutton
    data.layerPBRemove = uicontrol(data.tabLayers,'Style','pushbutton',...
                    'Units','normalized','Position',[.58 .6 .24 .055],...
                    'Visible', 'on', 'String', 'Remove',...
                    'Enable',stateOff,...
                    'Callback', @layerPBRemove_Callback);
                 
    % Min layer threshold
    data.layerMinSlider = uicontrol(data.tabLayers, 'Style', 'slider',...
                'Min',0,'Max',100,'Value',50,...
                'Enable',stateOff,...
                'Units','normalized','Position', [.35 .44 .6 .1],...
                'Visible', 'on', 'Callback', @layerMinSlider_Callback);
    data.layerMinLabel = uicontrol(data.tabLayers,'Style','text',...
                'Visible', 'on','String','Min',...
                'Units','normalized','Position',[.02 .435 .1 .1]);
	data.layerMinEdit = uicontrol(data.tabLayers,'Style','edit',...
                'Visible', 'on', 'String','',...
                'Enable',stateOff,...
                'Units','normalized','Position',[.12 .505 .2 .04],...
                'Callback', @layerMinEdit_Callback);
            
    % Max layer threshold
    data.layerMaxSlider = uicontrol(data.tabLayers, 'Style', 'slider',...
                'Min',0,'Max',100,'Value',50,...
                'Enable',stateOff,...
                'Units','normalized','Position', [.35 .36 .6 .1],...
                'Visible', 'on', 'Callback', @layerMaxSlider_Callback);
    data.layerMaxLabel = uicontrol(data.tabLayers,'Style','text',...
                'Visible', 'on','String','Max',...
                'Units','normalized','Position',[.02 .355 .1 .1]);
	data.layerMaxEdit = uicontrol(data.tabLayers,'Style','edit',...
                'Visible', 'on', 'String','',...
                'Enable',stateOff,...
                'Units','normalized','Position',[.12 .425 .2 .04],...
                'Callback', @layerMaxEdit_Callback);

    % Preview button
    data.layerPBPreview = uicontrol(data.tabLayers,'Style','pushbutton',...
                    'Units','normalized','Position',[.58 .32 .25 .055],...
                    'Visible', 'on', 'String', 'Preview',...
                    'Enable',stateOff,...
                    'Callback',@layerPBPreview_Callback);
    
	% Invert checkbox
    data.layerCBInvert = uicontrol(data.tabLayers,'Style','checkbox',...
        'Units','normalized','Position',[.1 .32 .4 .055],...
        'Visible', 'on', 'String', 'Exclusive limits',...
        'Enable',stateOff,'Value',0,...
        'Callback',@layerCBInvert_Callback);

    % --- ELLIPSE ---
    
    % ELLIPSE DEFINE PANEL
    data.ellipseDefinePanel = uipanel('Parent', data.tabEllipse, 'Title', 'DEFINE',...
        'FontSize', 11, 'Position', [.04 .5 .92 .48]);
    
    
    % Separate cell array of ellipse objects, so we can address ellipse
    % properties quickly without cumbersomely querying UI elements.
    data.ellipse = {};
    
    % Similarly for polygon objects
    data.poly = {};
    
    % Common position parameters for ellipse controls. Units are normalized
    % fraction of ellipseDefinePanel, which is 0.48 of main window height.
    xl = .05; xm = .3; xr = .7;
    labelw = .24; editw = .38; listboxw = .25;   
    labelh = .12; edith = .08; listboxh = .1;
    ytop = .85;
    ySpacing = .19;
    labelYOffset = -.065;
    listBoxOffset = -.03;
    rowNumber = 0;
    
    % Ellipse x-axis size
    [lengthUnitsLabel, ~, ~] = getLengthUnitList();
    % y-position of this row on panel
    ypos = ytop - (rowNumber*ySpacing);
    data.ellipseXALabel = uicontrol(data.ellipseDefinePanel,'Style','text',...
                'Visible', 'on','String','x axis',...
                'Units','normalized','Position',[xl ypos+labelYOffset labelw labelh]);
    data.ellipseXAEdit = uicontrol(data.ellipseDefinePanel,'Style','edit',...
                'Visible', 'on', 'String','',...
                'Enable',stateOn,...
                'Units','normalized','Position',[xm ypos editw edith],...
                'Value',[],...
                'Callback', @ellipseXAEdit_Callback);
	data.ellipseXAEditUnitsListBox = uicontrol(data.ellipseDefinePanel,'Style','popupmenu',...
                'Visible', 'on', 'String', lengthUnitsLabel,...
                'Value',2,...
                'Enable',stateOn,...
                'Units','normalized','Position',[xr ypos+listBoxOffset listboxw listboxh]);
	
	% Ellipse y-axis size. This is measured in on-target, projected units.
    rowNumber = rowNumber + 1;
    ypos = ytop - (rowNumber*ySpacing);
    data.ellipseYALabel = uicontrol(data.ellipseDefinePanel,'Style','text',...
                'Visible', 'on','String','y axis',...
                'Units','normalized','Position',[xl ypos+labelYOffset labelw labelh]);
    data.ellipseYAEdit = uicontrol(data.ellipseDefinePanel,'Style','edit',...
                'Visible', 'on', 'String','',...
                'Enable',stateOn,...
                'Units','normalized','Position',[xm ypos editw edith],...
                'Value',[],...
                'Callback', @ellipseYAEdit_Callback);
	data.ellipseYAEditUnitsListBox = uicontrol(data.ellipseDefinePanel,'Style','popupmenu',...
                'Visible', 'on', 'String', lengthUnitsLabel,...
                'Value',2,...
                'Enable',stateOn,...
                'Units','normalized','Position',[xr ypos+listBoxOffset listboxw listboxh]);
    
	% Azimuth of ellipse.
	[angUnitsLabel, ~, ~] = getAngUnitList();
    rowNumber = rowNumber + 1;
	ypos = ytop - (rowNumber*ySpacing);
    data.ellipseAzLabel = uicontrol(data.ellipseDefinePanel,'Style','text',...
                'Visible', 'on', 'String', 'Rotation (deg)',...
                'Units','normalized','Position',[xl ypos+labelYOffset labelw labelh]);
    data.ellipseAzEdit = uicontrol(data.ellipseDefinePanel,'Style','edit',...
                'Visible', 'on', 'String','',...
                'Enable',stateOn,...
                'Units','normalized','Position',[xm ypos editw edith],...
                'Value',[],...
                'Callback', @ellipseAzEdit_Callback);
    data.ellipseAzEditUnitsListBox = uicontrol(data.ellipseDefinePanel,'Style','popupmenu',...
                'Visible', 'on', 'String', angUnitsLabel,...
                'Value',1,...
                'Enable',stateOn,...
                'Units','normalized','Position',[xr ypos+listBoxOffset listboxw listboxh]);

    % Ellipse longitude position (0-360). Default is 180.
    rowNumber = rowNumber + 1;
    ypos = ytop - (rowNumber*ySpacing);
    data.ellipseXLabel = uicontrol(data.ellipseDefinePanel,'Style','text',...
                'Visible', 'on','String','Longitude',...
                'Units','normalized','Position',[xl ypos+labelYOffset labelw labelh]);
    data.ellipseXEdit = uicontrol(data.ellipseDefinePanel,'Style','edit',...
                'Visible', 'on', 'String','180',...
                'Enable',stateOn,...
                'Units','normalized','Position',[xm ypos editw edith],...
                'Value',180,...
                'Callback', @ellipseXEdit_Callback);

	% Ellipse latitude position (-90 to 90). Default is equator.
    rowNumber = rowNumber + 1;
    ypos = ytop - (rowNumber*ySpacing);
    data.ellipseYLabel = uicontrol(data.ellipseDefinePanel,'Style','text',...
                'Visible', 'on','String','Latitude',...
                'Units','normalized','Position',[xl ypos+labelYOffset labelw labelh]);
    data.ellipseYEdit = uicontrol(data.ellipseDefinePanel,'Style','edit',...
                'Visible', 'on', 'String','0',...
                'Enable',stateOn,...
                'Units','normalized','Position',[xm ypos editw edith],...
                'Value',0,...
                'Callback', @ellipseYEdit_Callback);

	
    % SHAPEFILE LOAD PANEL
    data.ellipseLoadPanel = uipanel('Parent', data.tabEllipse, 'Title', 'LOAD',...
        'FontSize', 11, 'Position', [.04 .22 .92 .26]);
    
    s = '';
    data.ellipseLoadEdit = uicontrol(data.ellipseLoadPanel,'Style','text',...
        'Visible', 'on','String',s,...
        'Units','normalized','Position',[.5 .4 .4 .5]);
    
    
	% Load shapefile button
	data.ellipseLoadPB = uicontrol(data.ellipseLoadPanel,'Style','pushbutton',...
        'Units','normalized','Position',[.1 .5 .4 .25],...
        'Visible', 'on', 'String', 'Load from shapefile',...
        'Enable',stateOn,...
        'Callback',@ellipseLoadPB_Callback);
    
    % Clear loaded shapefile button
    data.ellipseClearLoadedPB = uicontrol(data.ellipseLoadPanel,'Style','pushbutton',...
        'Units','normalized','Position',[.1 .2 .4 .25],...
        'Visible', 'on', 'String', 'Clear loaded',...
        'Enable',stateOn,...
        'Callback',@ellipseClearLoadedPB_Callback);
    

    % PREVIEW PANEL
    data.ellipsePreviewPanel = uipanel('Parent', data.tabEllipse, 'Title', 'PREVIEW',...
        'FontSize', 11, 'Position', [.04 .03 .92 .17]);
    
    % Ellipse preview pushbutton
    data.ellipsePreviewPB = uicontrol(data.ellipsePreviewPanel,'Style','pushbutton',...
                    'Units','normalized','Position',[.1 .35 .3 .38],...
                    'Visible', 'on', 'String', 'Preview',...
                    'Enable',stateOn,...
                    'Callback',@ellipsePreviewPB_Callback);
    
    % Check box to preview with footprints of loaded rasters.
    data.ellipseRasterFootprintCB = uicontrol(data.ellipsePreviewPanel,'Style','checkbox',...
        'Units','normalized','Position',[.5 .35 .5 .38],...
        'Visible', 'on', 'String', 'Plot layer footprints',...
        'Enable',stateOff,'Value', 0);
    
    
    %% --- EVALUATE ---
    
    % Panel to set parameters over which to evaluate
    data.evaluateParamPanel = uipanel('Parent', data.tabEvaluate, 'Title', 'PLACEMENT PARAMETERS',...
        'FontSize', 11, 'Position', [.04 .5 .92 .48]);
    
    % Spatial constraint layout
    %
    %         min   step   max
    %  x     ----- ------ -----
    %  y     ----- ------ -----
    %  
    % Common position parameters.
    xlbl = .01; xl = .09; xm = .39; xr = .69;
    labelw = .27; editw = .27; %listboxw = .25;
    labelh = .13; edith = .1; %listboxh = .04;
    ytop = .94;
    ySpacing = .14;
    labelYOffset = -.05;
    rowNumber = 0;
    llblw = .08; % width of narrow 'X','Y' labels.
    
    ypos = ytop - 2*.02;
    % Drop down list box to choose in what mode to operate.
    data.evaluateModeLabel = uicontrol(data.evaluateParamPanel,'Style','text',...
                'Visible', 'on','String', 'Evaluate ellipse compliance over:',...
                'Units','normalized','Position',[xl ypos+1.5*labelYOffset 2*labelw labelh]);   
    
	% The default evaluate mode is for a grid of lat-lon.
	data.mode = 1;
    data.evaluateModeListBox = uicontrol(data.evaluateParamPanel,'Style','popupmenu',...
        'Visible', 'on', 'String', getEvaluateModes(),...
                'Value',data.mode,...
                'Units','normalized','Position',[xl+2*labelw ypos-0.08 1.1*labelw 1.1*labelh],...
                'Callback', @evaluateModeListBox_Callback);

    rowNumber = rowNumber + 1;
	% x label
    ypos = ytop - (rowNumber*ySpacing) - 0.03;    
    
    % minlabel
    data.evaluateMinLabel = uicontrol(data.evaluateParamPanel,'Style','text',...
                'Visible', 'on','String','Min',...
                'Units','normalized','Position',[xl ypos+labelYOffset labelw labelh]);        
    % steplabel
    data.evaluateStepLabel = uicontrol(data.evaluateParamPanel,'Style','text',...
                'Visible', 'on','String','Interval',...
                'Units','normalized','Position',[xm ypos+labelYOffset labelw labelh]);
    % maxlabel
    data.evaluateMaxLabel = uicontrol(data.evaluateParamPanel,'Style','text',...
                'Visible', 'on','String','Max',...
                'Units','normalized','Position',[xr ypos+labelYOffset labelw labelh]);
            
    rowNumber = rowNumber + 1;
	% x label
    ypos = ytop - (rowNumber*ySpacing);
    data.evaluateXLabel = uicontrol(data.evaluateParamPanel,'Style','text',...
                'Visible', 'on','String','Lon',...
                'Units','normalized','Position',[xlbl ypos+labelYOffset llblw labelh]);
	% x min edit box.
    data.evaluateXMinEdit = uicontrol(data.evaluateParamPanel,'Style','edit',...
        'Visible', 'on', 'String','',...
        'Enable',stateOn,...
        'Units','normalized','Position',[xl ypos editw edith],...
        'Value',[],...
        'Callback', @evaluateXMinEdit_Callback);
    % x interval edit box.
    data.evaluateXStepEdit = uicontrol(data.evaluateParamPanel,'Style','edit',...
        'Visible', 'on', 'String','',...
        'Enable',stateOn,...
        'Units','normalized','Position',[xm ypos editw edith],...
        'Value',[],...
        'Callback', @evaluateXStepEdit_Callback);
    % x max edit box.
	data.evaluateXMaxEdit = uicontrol(data.evaluateParamPanel,'Style','edit',...
        'Visible', 'on', 'String','',...
        'Enable',stateOn,...
        'Units','normalized','Position',[xr ypos editw edith],...
        'Value',[],...
        'Callback', @evaluateXMaxEdit_Callback);
    
	rowNumber = rowNumber + 1;
	% y label
    ypos = ytop - (rowNumber*ySpacing);
    data.evaluateYLabel = uicontrol(data.evaluateParamPanel,'Style','text',...
                'Visible', 'on','String','Lat',...
                'Units','normalized','Position',[xlbl ypos+labelYOffset llblw labelh]);
	% x min edit box.
    data.evaluateYMinEdit = uicontrol(data.evaluateParamPanel,'Style','edit',...
        'Visible', 'on', 'String','',...
        'Enable',stateOn,...
        'Units','normalized','Position',[xl ypos editw edith],...
        'Value',[],...
        'Callback', @evaluateYMinEdit_Callback);
    % x interval edit box.
    data.evaluateYStepEdit = uicontrol(data.evaluateParamPanel,'Style','edit',...
        'Visible', 'on', 'String','',...
        'Enable',stateOn,...
        'Units','normalized','Position',[xm ypos editw edith],...
        'Value',[],...
        'Callback', @evaluateYStepEdit_Callback);
    % x max edit box.
	data.evaluateYMaxEdit = uicontrol(data.evaluateParamPanel,'Style','edit',...
        'Visible', 'on', 'String','',...
        'Enable',stateOn,...
        'Units','normalized','Position',[xr ypos editw edith],...
        'Value',[],...
        'Callback', @evaluateYMaxEdit_Callback);
    

    rowNumber=rowNumber+1.2;
    ypos = ytop - (rowNumber*ySpacing);
    % Button to set edit limits to boundary of ellipse.
    data.evaluateSetBoundsPB = uicontrol(data.evaluateParamPanel,'Style','pushbutton',...
                    'Units','normalized','Position',[xl ypos+.02 .27 .1],...
                    'Visible', 'on', 'String', 'Set bounds to',...
                    'Enable',stateOff,...
                    'Callback',@layerEvaluateSetBoundsPB_Callback);
    % Listbox of layers that bounds are allowed to be set to
    data.evaluateSetBoundsPopup = uicontrol(data.evaluateParamPanel,'Style','popupmenu',...
                'Visible', 'on', 'String', ' ',...
                'Value',1,...
                'Enable',stateOff,...
                'Units','normalized','Position',[xm-.02 ypos .61 .1]);

    % Azimuth label and controls
    rowNumber=rowNumber+1;
    ypos = ytop - (rowNumber*ySpacing);
    data.evaluateAzLabel = uicontrol(data.evaluateParamPanel,'Style','text',...
                'Visible', 'on','String','Az.',...
                'Units','normalized','Position',[xlbl ypos+labelYOffset llblw labelh]);
    
    data.evaluateAzMinEdit = uicontrol(data.evaluateParamPanel,'Style','edit',...
        'Visible', 'on', 'String','',...
        'Enable',stateOff,...
        'Units','normalized','Position',[xl ypos editw edith],...
        'Value',[],...
        'Callback', @evaluateAzMinEdit_Callback);
    % x interval edit box.
    data.evaluateAzStepEdit = uicontrol(data.evaluateParamPanel,'Style','edit',...
        'Visible', 'on', 'String','',...
        'Enable',stateOff,...
        'Units','normalized','Position',[xm ypos editw edith],...
        'Value',[],...
        'Callback', @evaluateAzStepEdit_Callback);
    % x max edit box.
	data.evaluateAzMaxEdit = uicontrol(data.evaluateParamPanel,'Style','edit',...
        'Visible', 'on', 'String','',...
        'Enable',stateOff,...
        'Units','normalized','Position',[xr ypos editw edith],...
        'Value',[],...
        'Callback', @evaluateAzMaxEdit_Callback);

    % Next row, azimuth units list box
    rowNumber=rowNumber+1;
    ypos = ytop - (rowNumber*ySpacing);
    data.evaluateAzEditUnitsLabel = uicontrol(data.evaluateParamPanel,'Style','text',...
                'Visible', 'on', 'String', 'Azimuth units:',...
                'Units','normalized','Position',[xl ypos+labelYOffset labelw labelh]);
    data.evaluateAzEditUnitsListBox = uicontrol(data.evaluateParamPanel,'Style','popupmenu',...
                'Visible', 'on', 'String', angUnitsLabel,...
                'Value',1,...
                'Enable',stateOff,...
                'Units','normalized','Position',[xm-.02 ypos+.04 listboxw listboxh]);


    %% Panel to preview and run the evaluation.
    data.evaluatorunPanel = uipanel('Parent', data.tabEvaluate, 'Title', 'RUN',...
        'FontSize', 11, 'Position', [.04 .31 .92 .18]);

    % Button to Preview plot area against ellipse and raster layers.
    data.evaluatePreviewPB = uicontrol(data.evaluatorunPanel,'Style','pushbutton',...
                    'Units','normalized','Position',[.05 .6 .3 .35],...
                    'Visible', 'on', 'String', 'Preview',...
                    'Enable',stateOn,...
                    'Callback',@layerEvaluatePreviewPB_Callback);            

    % Check box to preview with footprints of loaded rasters.
    data.evaluatePlotRasterFootprintCB = uicontrol(data.evaluatorunPanel,'Style','checkbox',...
        'Units','normalized','Position',[xm .6-.08 .6 .5],...
        'Visible', 'on', 'String', 'Plot layer footprints',...
        'Enable',stateOff,'Value', 0);

    % Evaluate pushbutton
    data.evaluateEvaluatePB = uicontrol(data.evaluatorunPanel,'Style','pushbutton',...
                        'Units','normalized','Position',[.05 .15 .3 .35],...
                        'Visible', 'on', 'String', 'EVALUATE',...
                        'Enable',stateOn,...
                        'BackgroundColor', 'r',...
                        'Callback',@layerEvaluateEvaluatePB_Callback);


    % --- RESULTS ---
    % When results are returned, the panel becomes enabled.
    % Results panel
    data.evaluateResultsPanel = uipanel('Parent', data.tabEvaluate, 'Title', 'RESULTS',...
        'FontSize', 11, 'Position', [.04 .04 .92 .26]);
    
    % Output directory

    % Pushbutton to preview results.
    data.evaluateResultsPreviewPB = uicontrol(data.evaluateResultsPanel,'Style','pushbutton',...
                    'Units','normalized','Position',[.02 .76 .34 .18],...
                    'Visible', 'on', 'String', 'Preview',...
                    'Enable', stateOff,...
                    'Callback',@evaluateResultsPreviewPB_Callback);
    
    % Pushbutton to select save directory for results.
    data.evaluateResultsOutputPB = uicontrol(data.evaluateResultsPanel,'Style','pushbutton',...
                    'Units','normalized','Position',[.02 .54 .34 .18],...
                    'Visible', 'on', 'String', 'Output dir.',...
                    'Enable', stateOff,...
                    'Callback',@evaluateResultsOutputPB_Callback);
    
	% Edit box for directory in which to output results. No need for a
	% callback. The contents are filled either by manually entering a path
	% or selecting one from the OS UI, and validated when the save PB is
	% pressed.
    data.evaluateResultsOutputEdit = uicontrol(data.evaluateResultsPanel,'Style','edit',...
                'Visible', 'on','String','',...
                'Enable', stateOff,...
                'Units','normalized','Position',[.4 .56 .57 .14],...
                'Value',[]);
                    
    % Text label for listbox.
    data.evaluateResultsFormatLabel = uicontrol(data.evaluateResultsPanel,'Style','text',...
                'Visible', 'on', 'String', 'Output format',...
                'Units','normalized','Position',[.05 .32 .3 .14]);
    
	% Listbox to select results format. Output formats available depend on
	% the operation mode.
    [desc, ~, ~] = getFileFormatWriteList(data.mode);
    data.evaluateResultsFormatListBox = uicontrol(data.evaluateResultsPanel,'Style','popupmenu',...
                'Visible', 'on', 'String', desc,...
                'Value', 1,...
                'Enable', stateOff,...
                'Units', 'normalized', 'Position',[.38 .32 .5 .14]);
    
	% Pushbutton to save the results.
    data.evaluateResultsSavePB = uicontrol(data.evaluateResultsPanel,'Style','pushbutton',...
                    'Units','normalized','Position',[.02 .1 .34 .18],...
                    'Visible', 'on', 'String', 'Save',...
                    'Enable', stateOff,...
                    'Callback',@evaluateResultsSavePB_Callback);
	
	% --- SAVE PLOT ---
    % Browse directory, select directory and save format select button to 
    % save the current figure.
    data.plotSavePB = uicontrol(data.fig,'Style','pushbutton',...
                    'Units','normalized','Position',[.095 .06 .1 .04],...
                    'Visible', 'on', 'String', 'Save Plot',...
                    'FontSize',12,...
                    'Enable', stateOn,...
                    'Callback',@plotSavePB_Callback);

    % --- STATUS ---
    data.status = uicontrol(data.fig,'Units', 'normalized', 'Visible', 'on',...
        'Style', 'text', 'String', 'STATUS: Ready.',...
        'HorizontalAlignment', 'left', 'Position', [.015 .025 .28 .02],...
        'FontSize', 12);
    
    % --- AXES ---
    data.plot.hAx = axes('Position',[.32 .08 .62 .86],...
        'Box','on',...
        'PlotBoxAspectRatio',[1 1 1],...
        'Parent', data.fig);

    xlabel(data.plot.hAx, 'Longitude');
    ylabel(data.plot.hAx, 'Latitude');
    % Set up empty legend handle
    data.plot.hLeg = [];
    
    % Initialize number of layers loaded
    data.nlayers = 0;
    
    % Set all text objects in the tabgroup to have size 11 font
    set(findall(data.tabgroup,'type','uicontrol'),'FontSize',11);
    
    % Panel containers have 12
    set(findall(data.tabgroup,'type','uipanel'),'FontSize',12);
    
    % Set data back into guidata. In this case hObject is actually gcbf,
    % it's just it won't have been created until after this function is
    % exited.
    guidata(hObject, data);
   
end
