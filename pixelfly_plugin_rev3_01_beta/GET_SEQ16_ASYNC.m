function GET_SEQ16_ASYNC(board_number,nr_of_images)
% GET_SEQ16_ASYNC();
% GET_SEQ16_ASYNC does grab 'nr_of_images' in ASYNC mode from the camera 
% to a Matlab image stack
% It does load the library, open a camera, read information and close the
% camera 
% 2008 June - MBL PCO AG

 if(~exist('board_num','var'))
  board_number=0;   
 end

 if(~exist('nr_of_images','var'))
  nr_of_images=10;   
 end

 if(~exist('waittime','var'))
  waittime = 0.500;   
 end
 
 nr_of_buffer=4;
 
 if(nr_of_images<nr_of_buffer)
  nr_of_buffer=nr_of_images;   
 end
 
 comment=1;

 if(comment)
  disp(['call pfINITBOARD(',int2str(board_number),') open driver and initialize camera']);
 end
 [error_code,board_handle] = pfINITBOARD(board_number);
 if(error_code~=0) 
  pco_errdisp('pfINITBOARD',error_code);
  return;
 end 
 progstate=1;

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

 if(comment)
  disp('call pfSETMODE, set mode ASYNC SW trigger, exposuretime=5ms ');
  disp('                no horizontal and vertical binning, 12bit readout');
 end

 exptime=5000; 
 waittime_ms=exptime/1000+1000;
 error_code=pfSETMODE(board_handle,hex2dec('11'),50,exptime,0,0,0,0,12,0);
 if(error_code~=0) 
  pco_errdisp('pfSETMODE',error_code);
  prog_exit(progstate,board_handle,0);
  return;
 end 

 if(comment)
  disp('call pfGETSIZES, return actual resolution of the camera');
 end

 [error_code,ccd_width,ccd_height,image_width,image_height,bit_pix]=...
    pfGETSIZES(board_handle);
 if(error_code~=0) 
  pco_errdisp('pfGETSIZES',error_code);
  prog_exit(progstate,board_handle,0);
  return;
 end

 if(comment)
  disp(['allocate image stack for ',int2str(nr_of_images),' images']);
 end

 imasize=image_width*image_height*floor((bit_pix+7)/8);
 if(bit_pix==8)
  image_stack=ones(image_width,image_height,nr_of_images,'uint8');
 else 
  image_stack=ones(image_width,image_height,nr_of_images,'uint16');
 end 

 bufnr=zeros(nr_of_buffer,1,'int32');
  
 for nr=1:nr_of_buffer
  if(bit_pix==8)
   ima_ptr(nr) = libpointer('uint8Ptr',image_stack(:,:,nr));
  else 
   ima_ptr(nr) = libpointer('uint16Ptr',image_stack(:,:,nr));
  end   
  [error_code, bufnr(nr)] = pfALLOCATE_BUFFER_EX(board_handle,-1,imasize,ima_ptr(nr));
  if(error_code~=0) 
   pco_errdisp('pfALLOCATE_BUFFER_EX',error_code);
   break;
  end
  if(comment)
   disp(['pfALLOCATE_BUFFER_EX done got buffer nr.: ',int2str(bufnr(nr))]);
  end
 end
 
 progstate=2;
 if(error_code~=0) 
  prog_exit(progstate,board_handle,bufnr);
  return;
 end 
  
 if(comment)
  disp('call pfSTART_CAMERA, start the camera');
 end

 error_code=pfSTART_CAMERA(board_handle);
 if(error_code~=0) 
  pco_errdisp('pfSTART_CAMERA',error_code);
  prog_exit(progstate,board_handle,bufnr);
  return;
 end
% progstate=3;

 if(comment)
  disp('call pfADD_BUFFER_TO_LIST, set the buffers in the working list of the driver');
 end

 for nr=1:nr_of_buffer
  if(comment)
   disp(['pfADD_BUFFER_TO_LIST buffer nr.: ',int2str(bufnr(nr))]);
  end
  error_code=pfADD_BUFFER_TO_LIST(board_handle,bufnr(nr),imasize,0,0);
  if(error_code~=0) 
   pco_errdisp('pfADD_BUFFER_TO_LIST',error_code);
   break;
  end 
 end
 progstate=4;

 if(error_code~=0) 
  prog_exit(progstate,board_handle,bufnr);
  return;
 end

 if(comment)
  disp('begin grab loop, trigger first image');
 end

 error_code=pfTRIGGER_CAMERA(board_handle);
 if(error_code~=0) 
  pco_errdisp('pfTRIGGER_CAMERA',error_code);
  prog_exit(progstate,board_handle,bufnr);
  return;
 end

 bnr=1; 
 for imanr=1:nr_of_images
  [error_code,ima_bufnr]=pfWAIT_FOR_BUFFER(board_handle,waittime_ms,bufnr(bnr));
  if(error_code~=0) 
   pco_errdisp('pfWAIT_FOR_BUFFER',error_code);
   break;
  else
   disp([int2str(imanr),'. image grabbed to buffer ',int2str(ima_bufnr)]);
  end
 
  [error_code,image_status] = pfGETBUFFER_STATUS(board_handle,ima_bufnr,0,4);
  if(error_code~=0) 
   pco_errdisp('pfGETBUFFER_STATUS',error_code);
  else
   disp(['image status is ',num2str(pco_uint32(image_status),'%08X')]);
  end
  
  pause(1);
  
  error_code=pfTRIGGER_CAMERA(board_handle);
  if(error_code~=0) 
   pco_errdisp('pfTRIGGER_CAMERA',error_code);
   break;
  end
  
  image_stack(:,:,imanr)=get(ima_ptr(bnr),'Value');
  
  

  if(imanr+nr_of_buffer<=nr_of_images)
   if(bit_pix==8)
    ima_ptr(bnr) = libpointer('uint8Ptr',image_stack(:,:,imanr+nr_of_buffer));
   else 
    ima_ptr(bnr) = libpointer('uint16Ptr',image_stack(:,:,imanr+nr_of_buffer));
   end   
   if(comment)
    disp(['reassign buffer ',int2str(ima_bufnr),' to image_stack number ',int2str(imanr+nr_of_buffer)]);
   end
   error_code = pfALLOCATE_BUFFER_EX(board_handle,ima_bufnr,imasize,ima_ptr(bnr));
   if(error_code~=0) 
    pco_errdisp('pfALLOCATE_BUFFER_EX',error_code);
    break;
   end
   if(comment)
    disp(['call pfADD_BUFFER_TO_LIST buffer ',int2str(ima_bufnr),' to image_stack number ',int2str(imanr+nr_of_buffer)]);
   end 
   error_code=pfADD_BUFFER_TO_LIST(board_handle,ima_bufnr,imasize,0,0);
   if(error_code~=0) 
    pco_errdisp('pfADD_BUFFER_TO_LIST',error_code);
    break;
   end 
  end 
  bnr=bnr+1; 
  if(bnr>nr_of_buffer)
   bnr=1;
  end 
 end

%we can close our camera here 
 prog_exit(progstate,board_handle,bufnr);
 if(error_code~=0) 
  return;   
 end 
     
     
 for ima_nr=1:nr_of_images
  m=max(image_stack(:,1:end,ima_nr));
  m=sort(m,'descend');
%discard 50 highest pixel  
  m=m(50);
  disp(['Found maxvalue ',int2str(m)]);
  ima=image_stack(:,:,ima_nr);
  imshow(ima',[0,m+100]);
  pause(waittime);
 end 
 
 while(1)
  ima_nr = input('CR to close window\n or number to show image ');  
  if isempty(ima_nr)
    break;
  end
  if(ima_nr<1)||(ima_nr>nr_of_images)
   disp('input out of range');   
   continue;
  end 
  disp(['show image ',int2str(ima_nr)]);   
  ima=image_stack(:,:,ima_nr);
  imshow(ima',[0,m+100]);
  pause(1);
 end
 close();
 pause(1);
 
 
 
 end
 
 
 

% if(error_code==0) 
%  if(comment)
%   disp('create an average image and show it ');
%  end
%  result_ima=zeros(image_width,image_height);
%  for imanr=1:nr_of_images
%   result_ima(:,:)= result_ima(:,:) + double(image_stack(:,:,imanr));
%   maxval=max(max(image_stack(:,:,imanr)));
%   minval=min(min(image_stack(:,:,imanr)));
%   if(comment)
%    disp(['maximum value in image ', int2str(maxval)]);   
%    disp(['minimum value in image ', int2str(minval)]);   
%   end
%  end
%  result_ima(:,:) = result_ima(:,:) / nr_of_images;
%  result_ima=uint16(result_ima');
%  maxval=max(max(result_ima(:,:)));
%  minval=min(min(result_ima(:,:)));
%  if(comment)
%   disp(['maximum value in image ', int2str(maxval)]);   
%   disp(['minimum value in image ', int2str(minval)]);   
%  end
%  
%  imshow(result_ima,[0,maxval+10]);
%  
%  disp('Press "Enter" to close window and proceed')
%  pause();
%  close();
%  pause(1);
% end
% 
% 
% end
  
function prog_exit(progstate,board_handle,ret_bufnr)

 if(progstate>=4)
  error_code=pfREMOVE_ALL_BUFFER_FROM_LIST(board_handle);
  pco_errdisp('pfREMOVE_ALL_BUFFER_FROM_LIST',error_code);
 end     
     
 if(progstate>=3)
  error_code=pfSTOP_CAMERA(board_handle);
  pco_errdisp('pfSTOP_CAMERA',error_code);
 end    

 if(progstate>=2)
  nr_of_buffer=size(ret_bufnr);   
  for nr=1:nr_of_buffer
   if(ret_bufnr(nr)>=0)  
    error_code=pfFREE_BUFFER(board_handle,ret_bufnr(nr));
    pco_errdisp('pfFREE_BUFFER',error_code);
   end
  end 
 end    
 
 if(progstate>=1)
  error_code=pfCLOSEBOARD(board_handle,1);
  pco_errdisp('pfCLOSEBOARD',error_code);
 end 
end

