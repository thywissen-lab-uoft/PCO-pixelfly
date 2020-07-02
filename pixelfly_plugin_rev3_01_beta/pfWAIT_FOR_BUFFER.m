function [error_code,varargout] = pfWAIT_FOR_BUFFER(board_handle,waittime, varargin)
% [error_code] = pfWAIT_FOR_BUFFER(board_number,varargin);                                             
% pfWAIT_FOR_BUFFER waits until one or more buffers have valid image data.
% The WAIT_FOR_BUFFER
% input  : board_handle [libpointer] - board_handle from INITBOARD
%          waittime [int32]          - time to wait for the image in ms
%          varargin [int32]          - one or more buffer numbers returned
%                                      from Allocate_buffer
% output : error_code [int32] - zero on success, nonzero indicates failure,
%                               returned value is the errorcode
%          varargout [int32]  - all buffers which have valid image data 
% 2008 June - MBL PCO AG
% 2012 November - new pf_cam SDK (64Bit) MBL PCO AG

% check if library has been already loaded
if not(libisloaded('PCO_PF_SDK'))
 error('library must have been loaded with pfINITBOARD')
end

if nargin < 3
 error('...wrong number of arguments have been passed to pfWAIT_FOR_BUFFER, see help!')
end

%disp(['number of input ', int2str(nargin),'  number of output ', int2str(nargout)]);

nr_of_buffer = uint32(length(varargin));
if(nr_of_buffer>4)
 disp(['nr_of_buffer changed from' int2str(nr_of_buffer) 'to 4']);
 nr_of_buffer=4;   
end 

for n=1:nr_of_buffer
 bufnr=['bufnr',int2str(n)];
 buflist.(bufnr)=int32(varargin{n}(1)); 
 BufferStatus=['BufferStatus',int2str(n)];
 buflist.(BufferStatus)=int32(1); 
 counter=['counter',int2str(n)];
 buflist.(counter)=int32(0); 
 hBufferEvent=['hBufferEvent',int2str(n)];
 buflist.(hBufferEvent)=libpointer; 
end 

%bnr=['bufnr',int2str(1)];
%disp(['nr_of_buffer ', int2str(nr_of_buffer) ' first ' int2str(buflist.(bnr))]);


for n=nr_of_buffer+1:4
 bufnr=['bufnr',int2str(n)];
 buflist.(bufnr)=int32(-2); 
end 


c_buflist=libstruct('PCC_Buflist',buflist);

[error_code,out_ptr,buflist] = calllib('PCO_PF_SDK','PCC_WAITFORBUFFER',board_handle,nr_of_buffer,c_buflist,waittime); 

%BufferStatus=['BufferStatus',int2str(1)];
%bufnr=['bufnr',int2str(1)];

%image_status=buflist.(BufferStatus);
% if(image_status<0)
%  status=double(image_status)+hex2dec('80000000');   
%  status=status+hex2dec('80000000');   
% else
%  status=double(image_status);     
% end

%disp(['PCCWAITFORBUFFER returned error ' int2str(error_code)]);
%disp(['PCCWAITFORBUFFER returned bufnr ' int2str(buflist.(bufnr))]);
%disp(['PCCWAITFORBUFFER returned status ' int2str(buflist.(BufferStatus)) '  ' num2str(status,'%08X')]);

nr_out=min(nargout-1,nr_of_buffer);   
%disp(['nr_out is ' int2str(nr_out)]);

a=(zeros(nr_out,1,'int32'));

if(error_code==0)
 for n=1:nr_out
  BufferStatus=['BufferStatus',int2str(n)];
  bufnr=['bufnr',int2str(n)];
  if(bitand(buflist.(BufferStatus),2)==2)
   a(n)=int32(buflist.(bufnr));   
  else
   a(n)=int32(-2);   
  end
 end
 

%sort if necessary 
 for n=1:nr_out
  if(n+1<=nr_out)&&((a(n)<0)&&(a(n+1)>=0))
   varargout(n)={a(n+1)};
   a(n+1)=a(n);
  else 
   varargout(n)={a(n)};
  end
 end 
else
 for n=1:nr_out
  varargout(n)={int32(-3)};   
 end    
end
