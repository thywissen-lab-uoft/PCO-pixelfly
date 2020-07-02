%------
%Author: David McKay
%Created: March 2011
%Summary: Stop the camera
%------

function CamStop(hObject,handles)
%stop looking for tiggers
stop(handles.wait_timer);
pause(.1);

if handles.RunCam
    fprintf('Stopping the camera ...');
    [error_code] = pfSTOP_CAMERA(handles.board_handle);
    if(error_code~=0) 
        disp(' camera NOT stopped.');
     error(['Could not stop camera. Error is ',int2str(error_code)]);
     return;
    else
        disp(' camera stopped.');
    end 
    
    fprintf(' Removing buffers from write list ...');
    [error_code] = pfREMOVE_ALL_BUFFER_FROM_LIST(handles.board_handle);
    disp(' done');
end



handles = setProperty(hObject,'CamStart',0,handles);
UpdateControls(handles);