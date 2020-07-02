function [error_code, ccd_width, ccd_height,...
                      image_width, image_height, ...
                      bit_pix] = pfGETSIZES(board_handle)
% [error_code,ccd_width, ccd_height,...
%             image_width, image_height, ...
%             bit_pix] = pfGETSIZES(board_number);                     
% pfGETSIZES returns the size of the CCD and the size of 1 image in pixel
% units, where the latter depends on the binning settings
%  
% input  : board_handle [libpointer] - board_handle from INITBOARD
% output : error_code [int32]  - zero on success, nonzero indicates failure,
%                                returned value is the errorcode
%          ccd_width [int32]   - width of CCD image sensor in pixel units
%          ccd_height [int32]  - height of CCD image sensor in pixel units
%          image_width [int32] - width of image in pixel
%          image_height [int32]- height of image in pixel
%          bit_pix [int32]     - bits per pixel
% date: 03.2003 / written by S. Zhao, The Cooke Corporation,
% www.cookecorp.com
% revision history:
% 2005 March - first release
% 2005 March - changed bit_pix to bit_pix_ptr in calllib, GHo, PCO AG
% 2008 June - switch to work with handles MBL PCO AG
% 2012 November - new pf_cam SDK (64Bit) MBL PCO AG

% check if library has been already loaded
if not(libisloaded('PCO_PF_SDK'))
 error('library must have been loaded with pfINITBOARD')
end

if nargin ~= 1
 error('...wrong number of arguments have been passed to pfGETSIZES, see help!')
end


ccd_width = int32(0);
ccd_width_ptr = libpointer('int32Ptr', ccd_width);
ccd_height = int32(0);
ccd_height_ptr = libpointer('int32Ptr', ccd_height);
image_width = int32(0);
image_width_ptr = libpointer('int32Ptr', image_width);
image_height = int32(0);
image_height_ptr = libpointer('int32Ptr', image_height);
bit_pix = int32(0);
bit_pix_ptr = libpointer('int32Ptr', bit_pix);
error_code = calllib('PCO_PF_SDK', 'GETSIZES', board_handle, ccd_width_ptr, ...
           ccd_height_ptr, image_width_ptr, image_height_ptr, bit_pix_ptr);

ccd_width = int32(get(ccd_width_ptr, 'Value'));
ccd_height = int32(get(ccd_height_ptr, 'Value'));  
image_width = int32(get(image_width_ptr, 'Value'));
image_height = int32(get(image_height_ptr, 'Value'));  
bit_pix = int32(get(bit_pix_ptr, 'Value'));  

end
