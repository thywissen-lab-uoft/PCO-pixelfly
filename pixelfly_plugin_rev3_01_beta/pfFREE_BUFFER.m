function [error_code] = pfFREE_BUFFER(board_handle, bufnr)
% [error_code] = pfFREE_BUFFER(board_handle, bufnr);
% pfFREE_BUFFER releases the allocated buffer. If the buffer was set into
% the buffer queue and no transfer was done to this buffer call
% pfREMOVE_BUFFER_FROM_LIST first. If an event was created for this buffer
% it will be closed and must not be used any longer. pixelfly SDK manual 
% p.11.
% input  : board_handle [libpointer] - board_handle from INITBOARD
%          bufnr [int32]        - buffer number of the allocated buffer
%                                 which should be unmapped
% output : error_code [int32] - zero on success, nonzero indicates failure,
%                               returned value is the errorcode
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

if nargin ~= 2
 error('...wrong number of arguments have been passed to pfFREE_BUFFER, see help!')
end

bufnr = int32(bufnr);
error_code =calllib('PCO_PF_SDK', 'FREE_BUFFER', board_handle, bufnr);

end


