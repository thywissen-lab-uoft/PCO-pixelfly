%------
%Author: David McKay
%Created: March 2011
%Summary: Put the buffers back into the queue (ie. get them ready to be
%reloaded)
%------

function CamQueueBuffers(hObject,handles)
disp('Adding the buffers to the write list');

bufsize = getProperty('XSize',handles)*getProperty('YSize',handles)*2;

bit_pix=12;
act_width=getProperty('XSize',handles);
act_height=getProperty('YSize',handles);        
imasize=act_width*act_height*floor((bit_pix+7)/8);  
bufsize=imasize;

for i = 1:getProperty('NumImages',handles)
    disp(['Adding buffer ' num2str(i) ' with buf num of ' ...
        num2str(handles.buf_nums(i)) ' to write list']);        
    [error_code] = pfADD_BUFFER_TO_LIST(...
        handles.board_handle,handles.buf_nums(i),bufsize,0,0);
    if(error_code~=0) 
        pco_errdisp('pfADD_BUFFER_TO_LIST',error_code);
        error(['Could not add buffer to queue. Error is ',int2str(error_code)]);
        return;
    end         
end