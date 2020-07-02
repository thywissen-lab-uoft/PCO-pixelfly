function [error_code, result_image] = pfREAD_IMAGE(board_handle,mode,...
                                       ima_size,ima_ptr,timeout)
% pfREAD_IMAGE does a single image read from the camera to the
% address of an external allocated buffer with size bufsize.
% The allocated buffer must be greater than the imagesize resulting from
% the actual settings.
% Camera must have been started before.
% If Software Trigger is set, a Trigger command is sent to the camera
% Some postprocessing can be done on the image 
%
% input  : board_handle [libpointer] - board_handle from INITBOARD
%          mode [int32]         - postprocessing
%                                 0x00 none
%                                 0x01 flip image (vertical)
%                                 0x08 mirror image (horizontal)
%                                 0x09 flip and mirror image
%          bufsize [int32]      - size of external allocated buffer    
%          bufadr [libpointer]  - address of external allocated buffer                    
%          timeout 
%
% output : error_code [int32] - zero on success, nonzero indicates failure,
%                               returned value is the errorcode
%          result_image       - Matlab array of either [uint8] or [uint16]
%                       
%          
% The camera only produces either 8 bit pixels or 12 bit. 
% a 12 bit pixel occupies 16 bits (two bytes)
% When the sensor is colored, color information can be extracted from the 
% 12 bit data array in post-acquisation processing. 
%
% 2012 November - new pf_cam SDK (64Bit) MBL PCO AG

% check if library has been already loaded
if not(libisloaded('PCO_PF_SDK'))
 error('library must have been loaded with pfINITBOARD')
end

error_code =calllib('PCO_PF_SDK','READ_IMAGE',board_handle,mode,ima_size,ima_ptr,timeout);


if(error_code==0)
 result_image=get(ima_ptr,'Value');  
else
    result_image=NaN;
end
    
end 

