function GET_PIC16_VIDEO(board_number)
% pfGET_PIC16_VIDEO();
% pfGET_PIC16_VIDEO does display one image grabbed from the camera in video mode
% It does load the library, open a camera, read information and close the
% camera 
% 2008 June - MBL PCO AG
% 2012 November - new pf_cam SDK (64Bit) MBL PCO AG

 if(~exist('board_num','var'))
  board_number=0;   
 end

%try to initialize camera
 [error_code,board_handle] = pfINITBOARD(board_number);
 if(error_code~=0) 
  pco_errdisp('pfINITBOARD',error_code);
  if(libisloaded('PCO_PF_SDK'))
   unloadlibrary('PCO_PF_SDK');
  end 
  return;
 end 
 disp(['Camera ',int2str(board_number),' opened']);
 
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
 
 progstate=1;
%set mode=VIDEO, exposuretime=10ms, no horizontal and vertical binning,
%12bit readout
 error_code=pfSETMODE(board_handle,hex2dec('031'),50,10,0,0,0,0,12,0);
 if(error_code~=0) 
  pco_errdisp('pfSETMODE',error_code);
  prog_exit(progstate,board_handle,0);
  return;
 end 

 disp(['Camera ',int2str(board_number),' SETMODE done']);

 [error_code,ccd_width,ccd_height,act_width,act_height,bit_pix]=...
    pfGETSIZES(board_handle);
 if(error_code~=0) 
  pco_errdisp('pfGETSIZES',error_code);
  prog_exit(progstate,board_handle,0);
  return;
 end

 size=act_width*act_height*floor((bit_pix+7)/8);
 disp(['image size is: ',int2str(size)]); 

%get the memory for the images
% imas=uint32(fix((double(bit_pix)+7)/8));
% imas= imas*uint32(act_width)* uint32(act_height); 
% imasize=imas;

% disp(['imasize is: ',int2str(imas),' aligned: ',int2str(imasize)]); 
% if (bit_pix == 8)5  image_stack=ones(act_width,act_height,'uint8');
%  im_ptr = libpointer('uint8Ptr',image_stack);
% else 
%  image_stack=ones(act_width,act_height,'uint16');
%  im_ptr = libpointer('uint16Ptr',image_stack);
% end

 bufnr=-1;
 [error_code, ret_bufnr] = pfALLOCATE_BUFFER(board_handle, bufnr,size);
 if(error_code~=0) 
  pco_errdisp('pfALLOCATE_BUFFER',error_code);
  prog_exit(progstate,board_handle,0);
  return;
 end
 progstate=2;
 
 [error_code,bufadr] = pfMAP_BUFFER(board_handle,ret_bufnr,size);
 if(error_code~=0) 
  pco_errdisp('pfMAP_BUFFER_EX',error_code);
  prog_exit(progstate,board_handle,ret_bufnr);
  return;
 end
 progstate=3;
 
 error_code=pfSTART_CAMERA(board_handle);
 if(error_code~=0) 
  pco_errdisp('pfSTART_CAMERA',error_code);
  prog_exit(progstate,board_handle,ret_bufnr);
  return;
 end
 progstate=4;

%now grab one image out of the video stream
 error_code=pfADD_BUFFER_TO_LIST(board_handle,ret_bufnr,size,0,0);
 if(error_code~=0) 
  pco_errdisp('pfADD_BUFFER_TO_LIST',error_code);
  prog_exit(progstate,board_handle,ret_bufnr);
  return;
 end

 error_code=pfTRIGGER_CAMERA(board_handle);
 if(error_code~=0) 
  pco_errdisp('pfTRIGGER_CAMERA',error_code);
  prog_exit(progstate,board_handle,ret_bufnr);
  return;
 end

 [error_code,image_status] = pfGETBUFFER_STATUS(board_handle,ret_bufnr,0,4);
 if(error_code~=0) 
  pco_errdisp('pfGETBUFFER_STATUS',error_code);
 else
  disp(['image status is ',num2str(pco_uint32(image_status),'%08X')]);
 end

 [error_code,ima_bufnr]=pfWAIT_FOR_BUFFER(board_handle,1000,ret_bufnr);
 if(error_code~=0) 
  pco_errdisp('pfWAIT_FOR_BUFFER',error_code);
 else
  disp(['image grabbed to buffer ',int2str(ima_bufnr)]);
 end

 [error_code,image_status] = pfGETBUFFER_STATUS(board_handle,ret_bufnr,0,4);
 if(error_code~=0) 
  pco_errdisp('pfGETBUFFER_STATUS',error_code);
 else
  disp(['image status is ',num2str(pco_uint32(image_status),'%08X')]);
 end
 
 if(ima_bufnr<0)
  error_code=1;    
 end

 if(error_code==0) 
  [error_code,ima]= pfCOPY_BUFFER(bufadr,bit_pix,act_width,act_height);

  m=max(max(ima(:,:)));
  imshow(ima',[0,m+100]);
  disp('Press "Enter" to close window and proceed')
  pause();
  close();
  pause(1);
  clear ima;
 else
  [error_code]=pfREMOVE_BUFFER_FROM_LIST(board_handle,ret_bufnr);
  pco_errdisp('pfREMOVE_BUFFER_FROM_LIST',error_code);
 end 

 prog_exit(progstate,board_handle,ret_bufnr);
 
end
  
function prog_exit(progstate,board_handle,ret_bufnr)

 if(progstate>=4)
  error_code=pfSTOP_CAMERA(board_handle);
  pco_errdisp('pfSTOP_CAMERA',error_code);
 end    

 if(progstate>=3)
  error_code=pfUNMAP_BUFFER(board_handle,ret_bufnr);
  pco_errdisp('pfUNMAP_BUFFER',error_code);
 end    
 
 if(progstate>=2)
  error_code=pfFREE_BUFFER(board_handle,ret_bufnr);
  pco_errdisp('pfFREE_BUFFER',error_code);
 end    
 
 if(progstate>=1)
  error_code=pfCLOSEBOARD(board_handle,1);
  pco_errdisp('pfCLOSEBOARD',error_code);
 end 
end

