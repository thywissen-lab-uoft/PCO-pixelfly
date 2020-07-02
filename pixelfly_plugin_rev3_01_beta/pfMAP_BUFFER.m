function [error_code,bufadr] = pfMAP_BUFFER(board_handle,bufnr, bufsize)
% [error_code,bufadr] = pfMAP_BUFFER(board_number, bufnr, bufsize);
% pfMAP_BUFFER maps an allocated buffer to an user address. The address can
% be used for read, write and other operations on the buffer data from the
% PC CPU.
% If bufsize is lower that the allocated buffer size not all data in the
% buffer can be accessed. If bufsize is greater than the allocated buffer
% size an error is returned. pixelfly SDK Manual p.12.
% input  : board_handle [libpointer] - board_handle from INITBOARD
%          bufnr [int32]      - buffer number of the allocated buffer
%                               which should be mapped
%          bufsize [int32]    - size of the allocated buffer, which
%                               should be mapped
% output : error_code [int32] - zero on success, nonzero indicates failure,
%                               returned value is the errorcode
%          bufadr [ptr]       - address of the mapped buffer
%
% date: 03.2003 / written by S. Zhao, The Cooke Corporation,
% www.cookecorp.com
% revision history:
% 2005 March - first release
% 2005 March - added help comments GHo, PCO AG
% 2008 June  - switch to work with handles MBL PCO AG
%              no pf_offset parameter             
% 2012 November - new pf_cam SDK (64Bit) MBL PCO AG
keyboard
% check if library has been already loaded
if not(libisloaded('PCO_PF_SDK'))
 error('library must have been loaded with pfINITBOARD')
end

if nargin ~= 3
 error('...wrong number of arguments have been passed to pfMAP_BUFFER, see help!')
end


bufnr=int32(bufnr);
bufsize=int32(bufsize);
buf_ptr = libpointer('voidPtrPtr');
[error_code,board_handle,bufadr] = ...
    calllib('PCO_PF_SDK', 'MAP_BUFFER', board_handle, bufnr, bufsize,0,buf_ptr);
                                           
end