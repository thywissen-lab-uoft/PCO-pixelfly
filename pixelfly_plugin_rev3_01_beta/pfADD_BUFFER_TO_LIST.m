function [error_code] = pfADD_BUFFER_TO_LIST(board_handle, bufnr, ...
                                                 bufsize, pf_offset, data)
% [error_code] = pfADD_BUFFER_TO_LIST(board_number, bufnr, bufsize,...
%                                                 pf_offset, data);                                             
% pfADD_BUFFER_TO_LIST sets a buffer into the buffer queue. The driver can
% manage a queue of 32 buffers. A buffer cannot be set to the queue a
% second time.
% If other buffers are already in the list, the buffer is set at the end of
% the queue. If no other buffers are set in the queue, the buffer is
% immediately prepared to read in the data of the next image released from
% the camera. If a transfer is done the driver changes the buffer status
% word and searches for the next buffer in the queue. If a buffer is found,
% it is removed from the queue and prepared for the next transfer.
% To wait until a transfer to one of the buffers is finished, poll the
% buffer status word ("or create a buffer event with pfSETBUFFER_EVENT.." -
% not realized yet for Matlab). pixelfly SDK manual p.11.
% input  : board_handle [libpointer] - board_handle from INITBOARD
%          bufnr [int32]        - valid buffer number from a
%                                 pfALLOCATE_BUFFER call
%          bufsize [int32]      - number of bytes to transfer, buffer size
%          pf_offset [int32]    - 0 (offset of bytes in the buffer)
%          data [int32]         - 0 not implemented yet
% output : error_code [int32] - zero on success, nonzero indicates failure,
%                               returned value is the errorcode
%
% Recommended buffer sizes (bufsize) for:
% 12bit data: actual_x_size * actual_y_size * 2
%  8bit data: actual_x_size * actual_y_size
% Get the actual_x_size and actual_y_size with the function pfGET_SIZES.
% If the number of bytes of the transfer doesn not match the number of
% bytes which are sent by the camera to the PCI-board errors may occur in
% the status byte of the buffer. bufsize must always be a value larger than
% 4096. If the transfer size is smaller than camera size, the transfer is
% done with the specified transfer size and no error should occur. If
% transfer size is larger than camera size, the transfer will generate a
% timeout and subsequently an error.
% With pf_offset values other than zero, it is possible to have more small
% images in one large buffer (pf_offset must be a multiple of 4096!).
% date: 03.2003 / written by S. Zhao, The Cooke Corporation,
% www.cookecorp.com
% revision history:
% 2005 March - first release
% 2005 March - added help comments GHo, PCO AG
% 2008 June - switch to work with handles MBL PCO AG

% check if library has been already loaded
% 2012 November - new pf_cam SDK (64Bit) MBL PCO AG
if not(libisloaded('PCO_PF_SDK'))
 error('library must have been loaded with pfINITBOARD')
end

if nargin ~= 5
 error('...wrong number of arguments have been passed to pfADD_BUFFER_TO_LIST, see help!')
end

bufnr = int32(bufnr); 
bufsize = int32(bufsize);
pf_offset = int32(pf_offset);              
data = int32(data);                

error_code = calllib('PCO_PF_SDK','ADD_BUFFER_TO_LIST', board_handle, bufnr, ...
                                                bufsize, pf_offset, data);
end
