% --- TIMER: Reading the current camera temperature.
function UpdateTemp(tmrobj,event,hObject)

% Get handles structure
handles = guidata(hObject);

% Read temperature from camera
[ret,handles.cam.currentTemp]=GetTemperature;

% Display temperature in black if stabilized -- in red otherwise
if ret==20036
    set(handles.txtTemp,'ForegroundColor',[0 0 0]);
else
    set(handles.txtTemp,'ForegroundColor',[0.8 0 0]);
end
set(handles.txtTemp,'String',sprintf('%g°C',...
            handles.cam.currentTemp));
        
% Also display the camera status (idle or acquiring)
[ret,gstatus]=AndorGetStatus;
set(handles.txtStatus,'String',GetStatusString(gstatus));

% Update handles structure
guidata(hObject,handles);