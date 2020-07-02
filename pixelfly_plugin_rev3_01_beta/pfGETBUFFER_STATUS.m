function [ error_code,image_status] = pfGETBUFFER_STATUS(board_handle, ...
                                                 bufnr, mode, len)
% [error_code,image_status] = pfGETBUFFER_STATUS(board_handle, bufnr, ...
%                                                               mode, len);
% pfGETBUFFER_STATUS returns length len status bytes from the buffer 
% structure DEVBUF of the specified buffer bufnr. In the header file
% pccamdef.h there are macro definitions to extract certain information
% from this structure. Ensure that the buffer is large enough and the value
% of len is large enough to transfer all values, which you need in your
% macros. The structure DEVBUF is only defined in the driver.
% For example, if you want to know when the DMA transfer is done, means
% image is in PC memory, the second Bit is set, which can be used for
% polling. pixelfly SDK manual p.10.
% input  : board_handle [libpointer] - board_handle from INITBOARD
%          bufnr [int32]        - valid buffer number from a
%                                 pfALLOCATE_BUFFER call
%          mode [int32]         - 0
%          len [int32]          - bytes to read
% output : error_code [int32] - zero on success, nonzero indicates failure,
%                               returned value is the errorcode
%          image_status [int32] - values of structure DEVBUF
%          
% date: 03.2003 / written by S. Zhao, The Cooke Corporation,
% www.cookecorp.com
% revision history:
% 2005 March - first release
% 2005 March - added help comments GHo, PCO AG
% 2008 June - switch to work with handles MBL PCO AG
% 2012 November - new pf_cam SDK (64Bit) MBL PCO AG

% check if library has been already loaded
if not(libisloaded('PCO_PF_SDK'))
 error('library must have been loaded with pfINITBOARD')
end

if nargin ~= 4
 error('...wrong number of arguments have been passed to pfGETBUFFER_STATUS, see help!')
end

mode = int32(mode);         
len = int32(len);         
image_status =  zeros(1,len/4,'int32'); 
image_status_ptr = libpointer('int32Ptr', image_status);
error_code =calllib('PCO_PF_SDK', 'GETBUFFER_STATUS',board_handle, bufnr, mode, ...
                                                    image_status_ptr, len);
image_status=int32(get(image_status_ptr, 'Value'));


end
