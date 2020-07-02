function [error_code, ret_bufnr, ret_bufadr] = ...
                      pfALLOCATE_BUFFER_EX(board_handle, bufnr, bufsize, ima_ptr)
% [error_code, ret_bufnr, ret_bufsize] = 
%                     pfALLOCATE_BUFFER(board_number, bufnr, bufsize);
% pfALLOCATE_BUFFER allocates a buffer for the camera in the PC main
% memory. The value of bufsize has to be set to the number of bytes which
% should be allocated. The return value ret_bufsize might be larger because
% the buffer is allocated with a certain block size. To allocate a new
% buffer, the value of bufnr has to be set to: -1.
% The return value ret_bufnr must be used in the calls to the other memory
% control functions. If a buffer should be reallocated bufnr must be set to
% its buffer number and size to the new size. If the function fails, the
% return values ret_bufnr and ret_bufsize are not valid and must not be
% used. pixelfly SDK manual p.10.
% input  : board_handle [libpointer] - board_handle from INITBOARD
%          bufnr [int32]        - buffer number to be allocated
%                                 => -1 for a new buffer
%          bufsize [int32]      - size of buffer, which should be allocated
%          ima_ptr [libpointer] - MATLAB allocated buffer  
% output : error_code [int32]   - zero on success, nonzero indicates failure,
%                               returned value is the errorcode
%          ret_bufnr [int32]    - number of buffer, which has been
%                                 allocated
%          ret_bufadr [libpointer????]   - address of buffer (added by Rhys)
% revision history:
% 2012 November - new pf_cam SDK (64Bit) MBL PCO AG

% check if library has been already loaded
if not(libisloaded('PCO_PF_SDK'))
 error('library must have been loaded with pfINITBOARD')
end

if nargin ~= 4
 error('...wrong number of arguments have been passed to pfALLOCATE_BUFFER_EX, see help!')
end

bufnr_ptr = libpointer('int32Ptr', bufnr);
ev_ptr=libpointer('voidPtrPtr');

%(HANDLE hdriver,int *bufnr,int size,HANDLE *hPicEvent,void** adr);
[error_code, bufnr_ptr_temp, hPicEvent, ret_bufadr] = ...
  calllib('PCO_PF_SDK', 'ALLOCATE_BUFFER_EX',board_handle,bufnr_ptr, bufsize,ev_ptr,ima_ptr);
if(error_code~=0)
 ret_bufnr=-1;
 return;
end 

ret_bufnr = int32(get(bufnr_ptr, 'Value'));

end