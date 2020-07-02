function [error_code] = pfREMOVE_BUFFER_FROM_LIST(board_handle, bufnr)
% [error_code] = pfREMOVE_BUFFER_FROM_LIST(board_number, bufnr);
% pfREMOVE_BUFFER_FROM_LIST removes the buffer bufnr from the buffer queue.
% If a transfer is actually in progress to this buffer, an error is
% returned. pixelfly SDK manual p.12.
% input  : board_handle [libpointer] - board_handle from INITBOARD
%          bufnr [int32]      - buffer number of the allocated buffer
%                               which should be removed
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
 error('...wrong number of arguments have been passed to pfREMOVE_BUFFER_FROM_LIST, see help!')
end

bufnr = int32(bufnr);
error_code =calllib('PCO_PF_SDK', 'REMOVE_BUFFER_FROM_LIST', board_handle,bufnr);

end

