%------
%Author: David McKay
%Created: March 2011
%Summary: Initialize the Pixel Fly camera
%------

function handles = CamInitialize(hObject,handles)
if handles.RunCam
    % Initialize the board
    
    disp('Intializing PCI PCO 540 board...');
    [error_code,board_handle] = pfINITBOARD(0);    
    if(error_code~=0) 
        disp('Unable to initialize board!!');
        error(['Could not the board. Error is ' ...
            '0x' dec2hex(pco_uint32err(error_code))]);
     return;
    end     
    
    % Stop the camera on the board if it running
    disp('Stopping any running camera on the board...');
    [error_code, value] = pfGETBOARDVAL(board_handle,'PCC_VAL_BOARD_STATUS');
    if(error_code)
        pco_errdisp('pfGETBOARDVAL',error_code);    
    else
        if(bitand(value,hex2dec('01'))==hex2dec('01'))
            disp('Camera is running call STOP_CAMERA')     
            error_code=pfSTOP_CAMERA(board_handle);
            pco_errdisp('pfSTOP_CAMERA',error_code);
        end 
    end    
    handles.board_handle=board_handle;
    handles.buf_nums = [-1 -1 -1];
    handles.buf_ptrs=[libpointer libpointer libpointer];
    
    CamUpdate(handles);
    
    [error_code,ccd_width,ccd_height,act_width,act_height,bit_pix]=...
        pfGETSIZES(board_handle);
    NumImages = getProperty('NumImages',handles);

%     act_width=getProperty('XSize',handles);
%     act_height=getProperty('YSize',handles);        
    imasize=act_width*act_height*floor((bit_pix+7)/8);  
    image_stack=ones(act_width,act_height,NumImages,'uint16');    
    
    disp(' ');
    disp(['Allocating buffers for ' num2str(NumImages) ' images.']);
    %allocate and map buffers for each image
    for i = 1:NumImages   
        disp(['Allocating buffer ' num2str(i) ' ...']);
        ima_ptr(i) = libpointer('uint16Ptr',image_stack(:,:,i));
        [error_code, handles.buf_nums(i)] = pfALLOCATE_BUFFER_EX(...
            board_handle,-1,imasize,ima_ptr(i)); 
        disp(['Allocated to buffer ' num2str(i) ' to buffer num ' ...
            num2str(handles.buf_nums(i))]);
    end
    disp(' ');
    handles.buf_ptrs=ima_ptr;
   fprintf(' Removing buffers from write list ...');
    [error_code] = pfREMOVE_ALL_BUFFER_FROM_LIST(handles.board_handle);
    disp(' done');
    
    %same guidata changes
    guidata(hObject,handles);
end