function [error_code] = pfREMOVE_ALL_BUFFERS_FROM_LIST(board_handle)
% [error_code] = pfREMOVE_ALL_BUFFER_FROM_LIST(board_number);
% pfREMOVE_ALL_BUFFER_FROM_LIST removes all buffers from the buffer queue.
% If a transfer is actually in progress to one of the buffer this buiffer is not removed
% and an error is returned.
%
% input  : board_handle [libpointer] - board_handle from INITBOARD
%
% output : error_code [int32] - zero on success, nonzero indicates failure,
%                               returned value is the errorcode
% 2013 March - new pf_cam SDK (64Bit) MBL PCO AG

% check if library has been already loaded
if not(libisloaded('PCO_PF_SDK'))
 error('library must have been loaded with pfINITBOARD')
end

if nargin ~= 1
 error('...wrong number of arguments have been passed to pfREMOVE_ALL_BUFFER_FROM_LIST, see help!')
end

error_code =calllib('PCO_PF_SDK', 'REMOVE_ALL_BUFFERS_FROM_LIST', board_handle);

end

