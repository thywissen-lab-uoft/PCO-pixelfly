%------
%Author: David McKay
%Created: March 2011
%Summary: Trigger the camera with software (testing only)
%------
function CamTrigger(hObject, handles)

if handles.RunCam
    %software trigger
    for i = 1:getProperty('NumImages',handles)
        [error_code] = pfTRIGGER_CAMERA(handles.board_handle);
        if(error_code~=0) 
         error(['Could not trigger camera. Error is ',int2str(error_code)]);
         return;
        end
        pause(0.2);
    end
    
    while(1)
        [error_code,b] = pfWAIT_FOR_BUFFER(handles.board_handle,1000, handles.buf_nums);
        if error_code==0
            break;
        end
    end
    
    %read in new images
    handles = ReadInImages(hObject,handles);
    
    %update the displayed images
    UpdateImages(handles);
        
    %re-queue
    CamQueueBuffers(hObject,handles);
    
end

if ~handles.RunCam && getProperty('RunFit',handles)
    %set this flag for different images
    %0: absorption
    %1: fluorescence with reference
    %2: averaged fluorescence of two images
    %3: fluor first picture only
    imaging_pars.image_type = 0;
    imaging_pars.fit_type = 'gauss';
    imaging_pars.cam = 'Pixelfly';
    %pixelsize is 6.45um
    mot_mag = 14.3; %13.2
    sci_mag = 6.45; %6.45*2 for "Gun barrel" imaging (1:2 mag), 6.45 for "X Lattice" imaging (1:1 mag), 6.45/2 for "Y Lattice" imaging (2:1 mag), 0.250 for Objective imaging
    imaging_pars.magnification = sci_mag;
    process_images({handles.Images{1} handles.Images{2} handles.Images{3}}, imaging_pars);
end