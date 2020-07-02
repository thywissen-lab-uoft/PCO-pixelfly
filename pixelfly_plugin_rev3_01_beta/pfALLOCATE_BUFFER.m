function [error_code, ret_bufnr, ret_bufev] = ...
                      pfALLOCATE_BUFFER(board_handle, bufnr, bufsize)
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
% output : error_code [int32]   - zero on success, nonzero indicates failure,
%                               returned value is the errorcode
%          ret_bufnr [int32]    - number of buffer, which has been
%                                 allocated
%          ret_bufsize [int32]  - size of buffer, which has been allocated
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

if nargin ~= 3
 error('...wrong number of arguments have been passed to pfALLOCATE_BUFFER, see help!')
end

bufnr_ptr = libpointer('int32Ptr', bufnr);
bufsize_ptr = libpointer('int32Ptr', bufsize);
error_code = calllib('PCO_PF_SDK', 'ALLOCATE_BUFFER',board_handle, ...
                                                bufnr_ptr, bufsize_ptr);
if(error_code~=0)
 ret_bufnr=-1;
 return;
end 

ret_bufnr = int32(get(bufnr_ptr, 'Value'));
%ret_bufsize = int32(get(bufsize_ptr, 'Value'));  

%if(nargout>2)
ev_ptr=libpointer('voidPtrPtr');
[error_code,out_ptr,ret_bufev] = calllib('PCO_PF_SDK', 'SETBUFFER_EVENT',board_handle,ret_bufnr,ev_ptr);
 if(error_code~=0)
  disp(['error in SETBUFFER_EVENT for bufnr ',int2str(ret_bufnr)]);    
 end 
%end

end