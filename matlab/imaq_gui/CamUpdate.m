%------
%Author: David McKay
%Created: March 2011
%Summary: Update the camera exposure and trigger type
%------

function CamUpdate(handles)

disp('Sending settings to camera...');

if ~handles.RunCam
    return;
end

if getProperty('CamStart',handles)
    error('Cannot update the camera when it is started');
end

%update trigger type
if getProperty('SoftTrig',handles)
    cammode = 17; %async software trigger;
else
    cammode = 16; %async hardware trigger;
end



%update exposure time
%see pfSETMODE.m for documentation of the arguments

exptime=floor(getProperty('Exposure',handles)/1E-6);
[error_code] = pfSETMODE(handles.board_handle,cammode,50,exptime,...
    0,0,0,0,12,0);
if(error_code~=0) 
 error(['Error updating camera. Error is ',int2str(error_code)]);
 return;
end 