%------
%Author: David McKay
%Created: March 2011
%Summary: Start the camera and wait for triggers
%------

function CamStart(hObject,handles)

if handles.RunCam
    fprintf('Starting the camera ... ');
    
    try
        error_code=pfSTART_CAMERA(handles.board_handle);
    end
    
    if ~error_code 
        disp('camera started.');
    else
        disp('camera NOT started.');
        error(['Could not start camera. Error is ',int2str(error_code)]);
        return;
    end 

    CamQueueBuffers(hObject,handles);
end

handles = setProperty(hObject,'CamStart',1,handles);
UpdateControls(handles);

if ~getProperty('SoftTrig',handles)
    %wait for triggers
    start(handles.wait_timer);
end