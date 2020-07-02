function [error_code] = pfUNMAP_BUFFER(board_handle, bufnr)
% [error_code] = pfUNMAP_BUFFER(board_handle, bufnr);
% pfUNMAP_BUFFER unmaps the buffer with the number bufnr. Please unmap all
% mapped buffers before closing the driver to prevent memory leakage.
% pixelfly SDK manual p.13.
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
 error('...wrong number of arguments have been passed to pfUNMAP_BUFFER_EX, see help!')
end

bufnr = int32(bufnr);
error_code =calllib('PCO_PF_SDK', 'UNMAP_BUFFER', board_handle, bufnr);

end

