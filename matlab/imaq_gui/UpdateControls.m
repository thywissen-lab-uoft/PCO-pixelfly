%------
%Author: David McKay
%Created: March 2011
%Summary: Updates the controls based on new data or user input
%------
function UpdateControls(handles)
% handles    structure with handles and user data (see GUIDATA)

mExposure = getProperty('Exposure',handles);
mExposureMin = getProperty('ExposureMin',handles);
mExposureMax = getProperty('ExposureMax',handles);

%set the position of the exposure slider
set(handles.exposuretime,'Value',(mExposure-mExposureMin)/(mExposureMax-mExposureMin));

if floor(mExposure/1E-6)>1000
    set(handles.exposuretimelabel,'String', [num2str(floor(mExposure/1E-6)/1E3) ' ms']);
else
    set(handles.exposuretimelabel,'String', [num2str(floor(mExposure/1E-6)) ' us']);
end

%set the position of the contrast slider
set(handles.contrastslide,'Value',getProperty('ImgContrast',handles));

%set history slider range
maxnum = getProperty('NumHistory',handles);
set(handles.sld_History,'Max',maxnum-1);
set(handles.sld_History,'SliderStep',1./((maxnum-1)*[1 1]));

%based on whether the camera is started/stopped 
if getProperty('CamStart',handles)
    set(handles.startbutton,'Value',1);
    set(handles.startbutton,'String','Stop');
    set(handles.exposuretime,'Enable','off');
    if getProperty('SoftTrig',handles)
        set(handles.testtriggers,'Visible','on');
    end
    set(handles.statustext,'String','Waiting for trigger...');
else
    set(handles.startbutton,'Value',0);
    set(handles.startbutton,'String','Start');
    set(handles.exposuretime,'Enable','on');
    set(handles.testtriggers,'Visible','off');
    set(handles.statustext,'String','Camera stopped.');
end
        