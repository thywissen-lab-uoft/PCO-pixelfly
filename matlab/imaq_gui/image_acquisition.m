function varargout = image_acquisition(varargin)
% IMAGE_ACQUISITION M-file for image_acquisition.fig
%      IMAGE_ACQUISITION, by itself, creates a new IMAGE_ACQUISITION or raises the existing
%      singleton*.
%
%      H = IMAGE_ACQUISITION returns the handle to a new IMAGE_ACQUISITION or the handle to
%      the existing singleton*.
%
%      IMAGE_ACQUISITION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGE_ACQUISITION.M with the given input arguments.
%
%      IMAGE_ACQUISITION('Property','Value',...) creates a new IMAGE_ACQUISITION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before image_acquisition_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to image_acquisition_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help image_acquisition

% Last Modified by GUIDE v2.5 06-Jan-2015 13:51:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @image_acquisition_OpeningFcn, ...
                   'gui_OutputFcn',  @image_acquisition_OutputFcn, ...
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


% --- Executes just before image_acquisition is made visible.
function image_acquisition_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to image_acquisition (see VARARGIN)

%property/value pairs for the gui with defaults
mPropertyDefs = {...
    'ExposureMax',@localValidateInput,65E-3;  %was 65E-3
    'ExposureMin',@localValidateInput,50E-6;
    'Exposure',@localValidateInput,0.374E-3;
    'RunFit',@localValidateInput,1;
    'SoftTrig',@localValidateInput,0;
    'ImgContrast',@localValidateInput,1;
    'CamStart',@localValidateInput,0;
    'XSize',@localValidateInput,1392;
    'YSize',@localValidateInput,1024;
    'ROI',@localValidateInput,[];
    'CTR',@localValidateInput,[];
    'UseROI',@localValidateInput,0;
    'ImgBitSize',@localValidateInput,12;
    'MaxOD',@localValidateInput,5000;
    'NumImages',@localValidateInput,2; %Number of images (2 if no background, 3 if background) 
    'SaveImages',@localValidateInput,0;
    'SaveDirectory',@localValidateInput,'Y:\Data';
    'SavePrefix',@localValidateInput,'A';
    'SaveParameters',@localValidateInput,{};
    'SaveCount',@localValidateInput,0;
    'AutoSaveImages',@localValidateInput,1;
    'AutoSaveDirectory',@localValidateInput,'C:\Users\Solaire\ImageHistory\PixelFly';
    'NumHistory',@localValidateInput,200;
    'ComPath',@localValidateInput,'Y:\_communication';
    'IsFresh',@localValidateInput,0;
    'IsHistory',@localValidateInput,1;
    'ImageFile',@localValidateInput,'';
    'ImageHistoryFile',@localValidateInput,'';
    }; 
%%%changed to 1!

%add a flag to handles for testing. If RunCam=0 then don't initialize the
%camera and just use dummy data
handles.RunCam = 1;

%add to handles and update
handles.PropertyDefs = mPropertyDefs;
guidata(hObject,handles);

%process input
handles = processUserInputs(hObject,handles,varargin);

%initialize the controls
UpdateControls(handles);

%add arrays to hold the image data
xsize = getProperty('XSize',handles);
ysize = getProperty('YSize',handles);

[x1, x2] = meshgrid(1:ysize,1:xsize);

img1 = 1000*exp(-2*exp(-((x1-ysize/2).^2+(x2-xsize/2).^2)/10000)).*(((x1-ysize/2).^2+(x2-xsize/2).^2)<100000);
img2 = 1000*(((x1-ysize/2).^2+(x2-xsize/2).^2)<100000);
img3 = zeros(xsize,ysize);

%Images are stored in a cell array
handles.Images = {img1 img2 img3};
handles.ImagePars = struct;
guidata(hObject,handles);

%update the images
UpdateImages(handles);

% Choose default command line output for image_acquisition
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%check if the camera has been initialized
if ~isfield(handles,'board_handle')
    handles = CamInitialize(hObject,handles);
end

%update the camera (mode and exposure)
CamUpdate(handles);

%create a timer object used for waiting for the hardware triggers
handles.wait_timer = timer('TimerFcn',{@CheckforTriggers,hObject},'Period',0.5,...
    'ExecutionMode','FixedSpacing','Name','timer-TriggerCheck');

guidata(hObject,handles);

% UIWAIT makes image_acquisition wait for user response (see UIRESUME)
% uiwait(handles.mainfigure);


% --- Executes when user attempts to close mainfigure.
function mainfigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to mainfigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%check if the camera is still running or not
if getProperty('CamStart',handles)
    msgbox('Stop camera before exiting','Exit','Warn');
    
else
    
    if handles.RunCam
        %close all the camera handles
        CamClose(hObject,handles);
    end
    
    %kill timer
    delete(handles.wait_timer);    
    clear handles.wait_timer;    
    delete(hObject);    
end

% --- Outputs from this function are returned to the command line.
function varargout = image_acquisition_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in startbutton.
function startbutton_Callback(hObject, eventdata, handles)
% hObject    handle to startbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of startbutton

butval =  get(hObject,'Value');

if butval==1
    CamStart(hObject,handles);    
else
    CamStop(hObject,handles);
end


% --- Executes on slider movement.
function contrastslide_Callback(hObject, eventdata, handles)
% hObject    handle to contrastslide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = setProperty(hObject,'ImgContrast',get(hObject,'Value'),handles);
UpdateControls(handles);
UpdateImages(handles);

% --- Executes during object creation, after setting all properties.
function contrastslide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrastslide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function exposuretime_Callback(hObject, eventdata, handles)
% hObject    handle to exposuretime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderval = get(hObject,'Value');

mExposureMin = getProperty('ExposureMin',handles);
mExposureMax = getProperty('ExposureMax',handles);

handles = setProperty(hObject,'Exposure',sliderval*(mExposureMax-mExposureMin)+mExposureMin,handles);

%update controls
UpdateControls(handles);

%update Camera
CamUpdate(handles);

% --- Executes during object creation, after setting all properties.
function exposuretime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exposuretime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in fitsenable.
function fitsenable_Callback(hObject, eventdata, handles)
% hObject    handle to fitsenable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fitsenable
setProperty(hObject,'RunFit',get(hObject,'Value'),handles);

% --- Executes on button press in testtriggers.
function testtriggers_Callback(hObject, eventdata, handles)
% hObject    handle to testtriggers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CamTrigger(hObject,handles)

function isValid = localValidateInput(property,value,handles)
% helper function that validates the user provided input property/value
% pairs. You can choose to show warnings or errors here.
    isValid = false;
    switch lower(property)
        case 'exposuremax'
            %check larger than exposure min
            if isnumeric(value) && value > getProperty('ExposureMin',handles)
                isValid = true;
            end
        case 'exposuremin'
            %check less than exposure max
            if isnumeric(value) && value < getProperty('ExposureMax',handles)
                isValid = true;
            end
        case 'exposure'
            if isnumeric(value) && value <= getProperty('ExposureMax',handles) && ...
                    value >= getProperty('ExposureMin',handles)
                isValid = true;
            end
        case {'runfit','softtrig','camstart','saveimages','autosaveimages','isfresh','ishistory','useroi'}
            if isnumeric(value) && (value==1 || value==0)
                isValid = true;
            end
        case 'imgcontrast'
            if isnumeric(value) && value>=0.01 && value <=1
                isValid = true;
            end
                  
        case {'xsize','ysize'}
            %make sure it is an integer
            if rem(value,1)==0
                isValid = true;
            end
        case {'numimages'}
            if isnumeric(value) && (value==2 || value==3)
                isValid = true;
            end
        case {'roi'}
            if (isnumeric(value) && (size(value,1) == 2) && (size(value,2) == 2)) || isempty(value)
                isValid = true;
            end 
        case {'ctr'}
            if (isnumeric(value) && (size(value,1) == 1) && (size(value,2) == 2)) || isempty(value)
                isValid = true;
            end   
        case {'savedirectory','autosavedirectory','compath'}
            if ischar(value)
                if exist(value,'dir')
                    isValid = true;
                else
                    disp(['Warning: Cannot access ' property '''' value '''']);
                end
            end
        case {'saveprefix','imagefile','imagehistoryfile'}
            if ischar(value)
                isValid = true;
            end
        case {'saveparameters'}
            if iscell(value)
                isValid = true;
            end         
        case {'savecount', 'numhistory'}
            if isnumeric(value) && (value >= 0)
                isValid = true;
            end              
    end
    
    if ~isValid
        %throw error here
    end

function handles = processUserInputs(hObject,handles,varargin)
% helper function that processes the input property/value pairs 
% Apply possible figure and recognizable custom property/value pairs
    varargin = varargin{1};
    for index=1:2:length(varargin)
        if length(varargin) < index+1
            break;
        end
        match = find(ismember({handles.PropertyDefs{:,1}},varargin{index}));
        if ~isempty(match)  
           % Validate input and assign it to a variable if given
           handles = setProperty(hObject,varargin{index},varargin{index+1},handles);
        end
        
    end        
 
% --- Executes on button press in saveenable.
% --- Enables / disables automatic image saving
function saveenable_Callback(hObject, eventdata, handles)
% hObject    handle to saveenable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = setProperty(hObject,'SaveImages',get(hObject,'Value'),handles);
if (get(hObject,'Value'))
    set(handles.text_SavePrefix,'Enable','off'); 
    set(handles.txt_SaveParameterStr,'Enable','off'); 
    set(handles.savefolderselect,'Enable','off');
    handles = setProperty(hObject,'SavePrefix',get(handles.text_SavePrefix,'String'),handles);
    handles = setProperty(hObject,'SaveCount',0,handles);
    parstr = CheckEval(get(handles.txt_SaveParameterStr,'String'));
    if iscell(parstr)
        handles = setProperty(hObject,'SaveParameters',parstr,handles);
        set(handles.txt_IsValidParameterString,'String','Ok');
    else
        handles = setProperty(hObject,'SaveParameters',{},handles);
        set(handles.txt_IsValidParameterString,'String','invalid');
    end
    set(handles.txt_ImageCount,'String',sprintf('%g',getProperty('SaveCount',handles)));
else
    set(handles.text_SavePrefix,'Enable','on');
    set(handles.txt_SaveParameterStr,'Enable','on'); 
    set(handles.savefolderselect,'Enable','on');
    set(handles.txt_IsValidParameterString,'String','');
    set(handles.txt_ImageCount,'String','');
end

% --- Executes on button press in savefolderselect.
% --- Select folder to automatically save images in.
function savefolderselect_Callback(hObject, eventdata, handles)
% hObject    handle to savefolderselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
directory = uigetdir;
if ischar(directory)
    setProperty(hObject,'SaveDirectory',directory,handles);
    set(handles.txt_SaveFolder,'String',directory);
end

function text_SavePrefix_Callback(hObject, eventdata, handles)
% hObject    handle to text_SavePrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_SavePrefix as text
%        str2double(get(hObject,'String')) returns contents of text_SavePrefix as a double

% --- Executes during object creation, after setting all properties.
function text_SavePrefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_SavePrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in autosaveenable.
% --- Enables / disables image history
function autosaveenable_Callback(hObject, eventdata, handles)
% hObject    handle to autosaveenable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setProperty(hObject,'AutoSaveImages',get(hObject,'Value'),handles);
if (get(hObject,'Value'))
    set(handles.autosavefolderselect,'Enable','off');
    setProperty(hObject,'SavePrefix',get(handles.autosavefolderselect,'String'));
else
    set(handles.autosavefolderselect,'Enable','on');
end

% --- Executes on button press in autosavefolderselect.
% --- Select folder for image history
function autosavefolderselect_Callback(hObject, eventdata, handles)
% hObject    handle to autosavefolderselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
directory = uigetdir;
if ischar(directory)
    setProperty(hObject,'AutoSaveDirectory',directory,handles);
    set(handles.txt_AutoSaveFolder,'String',directory);
end

% --- Executes during object creation, after setting all properties.
function txt_AutoSaveFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_AutoSaveFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in btn_SaveCurrentImage.
% --- Save the currently displayed image
function btn_SaveCurrentImage_Callback(hObject, eventdata, handles)
% hObject    handle to btn_SaveCurrentImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = getProperty('SaveDirectory',handles);
[filename,path] = uiputfile('*.mat','Save image file',[path filesep]);
ImageSave({handles.Images{1} handles.Images{2} handles.Images{3}}, ...
            [path filename], handles.ImagePars, 0, 0);



% --- Executes on button press in btn_LoadImage.
% --- Load a saved image.
function btn_LoadImage_Callback(hObject, eventdata, handles)
% hObject    handle to btn_LoadImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = getProperty('SaveDirectory',handles);
cd([path filesep]);
[filename,path] = uigetfile('*.mat','Select image file');
[img, pars] = ImageLoad([path filename]);
numimg = getProperty('NumImages',handles);
if length(img) ~= (numimg + 1);
    disp('Wrong number of subimages. Doing nothing.');
else
    handles.Images = img; handles.ImagePars = pars;
    guidata(hObject,handles); UpdateImages(handles);
    % reset history slider and displays
    set(handles.sld_History,'Value',0);
    set(handles.txt_History,'String','');
    set(handles.txt_HistoryFile,'String','');
    handles = setProperty(hObject,'IsHistory',0,handles);
    handles = setProperty(hObject,'IsFresh',0,handles);
    handles = setProperty(hObject,'ImageFile',[path filename],handles);
    handles = setProperty(hObject,'ImageHistoryFile','',handles);
    guidata(hObject,handles)
end


% --- Executes on button press in btn_Refit.
function btn_Refit_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Refit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imaging_pars.ROI = getProperty('ROI',handles);
imaging_pars.CTR = getProperty('CTR',handles);

%set this flag for different images
%0: absorption
%1: fluorescence with reference
%2: averaged fluorescence of two images
%3: fluor first picture only
imaging_pars.image_type = 0;
imaging_pars.fit_type = get(handles.txtFitType,'String');
imaging_pars.cam = 'Pixelfly';
%pixelsize is 6.45um
mag = cellstr(get(handles.popMag,'String'));
imaging_pars.magnification = str2double(mag{get(handles.popMag,'Value')});

[fitresults, handles.ImagePars.processcmd] = ...
            process_images({handles.Images{1} handles.Images{2} handles.Images{3}},imaging_pars);
if isfield(handles,'ImagePars'); if isfield(handles.ImagePars,'fitresults')
        handles.ImagePars.fitresults = appendto(handles.ImagePars.fitresults, fitresults);
    else
        handles.ImagePars.fitresults = fitresults;
end; end
AutoResave(handles);
UpdateImages(handles);
guidata(hObject,handles);


% --- Executes on slider movement.
% --- Browse through image history
function sld_History_Callback(hObject, eventdata, handles)
% hObject    handle to sld_History (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(get(handles.txt_History,'String'));
    set(hObject,'Value',0);
end
num = get(hObject,'Value') + 1;
GetHistory(num, handles);



% --- Executes during object creation, after setting all properties.
function sld_History_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_History (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function txt_SaveParameterStr_Callback(hObject, eventdata, handles)
% hObject    handle to txt_SaveParameterStr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_SaveParameterStr as text
%        str2double(get(hObject,'String')) returns contents of txt_SaveParameterStr as a double


% --- Executes during object creation, after setting all properties.
function txt_SaveParameterStr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_SaveParameterStr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in btn_ROIselect.
function btn_ROIselect_Callback(hObject, eventdata, handles)
% hObject    handle to btn_ROIselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = setProperty(hObject,'ROI',[],handles);
UpdateImages(handles);
axes(handles.mainpic);
gin = round(ginput(2));
XSize = getProperty('XSize',handles);
YSize = getProperty('YSize',handles);
ROI = [sort(gin(:,1)) sort(gin(:,2))];
ROI = [max(ROI(1,1),1) max(ROI(1,2),1); min(ROI(2,1),XSize) min(ROI(2,2),YSize)];
ROIstr = sprintf('[%g %g;%g %g]',ROI(1,1),ROI(1,2),ROI(2,1),ROI(2,2));
set(handles.txt_ROI,'String',ROIstr);
handles = setProperty(hObject,'ROI',ROI,handles);
UpdateImages(handles)
guidata(hObject,handles);




% --- Executes on button press in btn_ROIset.
function btn_ROIset_Callback(hObject, eventdata, handles)
% hObject    handle to btn_ROIset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btn_ROIset
value = get(hObject,'Value');
if value
    set(handles.txt_ROI,'Enable','off')
    try 
        ROI = eval(get(handles.txt_ROI,'String'));
        ROI = [sort(ROI(:,1)) sort(ROI(:,2))];
        ROIstr = sprintf('[%g %g;%g %g]',ROI(1,1),ROI(1,2),ROI(2,1),ROI(2,2));
    catch
        ROI = [];
        ROIstr = getProperty('ROI',handles);
    end
    if ~( (size(ROI,1) == 2) && (size(ROI,2) == 2) )
        ROI = [];
        ROIstr = getProperty('ROI',handles);
    end
    set(handles.txt_ROI,'String',ROIstr)
    handles = setProperty(hObject,'ROI',ROI,handles);
    handles = setProperty(hObject,'UseROI',1,handles);
else
    set(handles.txt_ROI,'Enable','on')
    handles = setProperty(hObject,'UseROI',0,handles);
end
UpdateImages(handles)
guidata(hObject,handles)



function txt_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to txt_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_ROI as text
%        str2double(get(hObject,'String')) returns contents of txt_ROI as a double


% --- Executes during object creation, after setting all properties.
function txt_ROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function out = appendto(in, add)
% help function that appends a row of data to an existing array and deals
% with size-mismatches
if size(in,2)>size(add,2);
    add = [add zeros(1,size(in,2)-size(add,2))];
else
    in = [in zeros(size(in,1),size(add,2)-size(in,2))];
end
out = [in;add];


% --- Executes on button press in btn_CTRselect.
function btn_CTRselect_Callback(hObject, eventdata, handles)
% hObject    handle to btn_CTRselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = get(hObject,'Value');
if (value)
    ROI = getProperty('ROI',handles);
    handles = setProperty(hObject,'ROI',[],handles);
    UpdateImages(handles);
    axes(handles.mainpic);
    CTR = round(ginput(1));
    XSize = getProperty('XSize',handles);
    YSize = getProperty('YSize',handles);
    CTR = [min(max(CTR(1,1),1),XSize) min(max(CTR(1,2),1),YSize)];
    handles = setProperty(hObject,'CTR',CTR,handles);
    handles = setProperty(hObject,'ROI',ROI,handles);
    UpdateImages(handles)
    guidata(hObject,handles);
else
    handles = setProperty(hObject,'CTR',[],handles);
    UpdateImages(handles)
    guidata(hObject,handles);
end


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% this = calcROIStats(handles)



function txtFitType_Callback(hObject, eventdata, handles)
% hObject    handle to txtFitType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtFitType as text
%        str2double(get(hObject,'String')) returns contents of txtFitType as a double


% --- Executes during object creation, after setting all properties.
function txtFitType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtFitType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popMag.
function popMag_Callback(hObject, eventdata, handles)
% hObject    handle to popMag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popMag contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popMag


% --- Executes during object creation, after setting all properties.
function popMag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popMag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
