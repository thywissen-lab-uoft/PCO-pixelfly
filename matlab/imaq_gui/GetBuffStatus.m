%------
%Author: David McKay
%Created: March 2011
%Summary: Check to see the buffer status (ie. is there an image ready?)
%------
function buff_status = GetBuffStatus(handles,buf_nr,flag)
% Checks the status of a buffer
%
%   handles     - the primary handles object
%   buf_nr      - the buffer number in handles to check (not the actual
%                   buffer number)
%   flag        - some kind of flag
%   buff_status - the status of the buffer
%                   1 queued
%                   2 not queued
%                   3 waiting with image
%                   4 getting image 
%                   -1 not allocated

% Assume the buffer is not allocated
buff_status = -1;

if nargin < 3
    flag = 0;
end    

if handles.buf_nums(buf_nr)~=-1    
    % Read the buffer
    [error_code,buff_status] = pfGETBUFFER_STATUS(...
        handles.board_handle,...
        handles.buf_nums(buf_nr),...
        0,4);
        
    % Process the error code if read fails
    if error_code 
        error_code = pco_uint32err(error_code);            
        error(['Could not determine buffer status. Error is ' ...
            '0x' dec2hex(error_code)]);
     	return;
    end
    
    % Convert it into readable value
    buff_status=pco_uint32(buff_status);    

    % Look at bits associated with the parts we want
    if (bitand(buff_status,4))
        buff_status = 1;
    elseif (bitand(buff_status,2))
        buff_status = 3;
    end
    
    if flag
        disp(['Buffer status is ',num2str(buff_status,'%08X')]);
    end
end
    
end