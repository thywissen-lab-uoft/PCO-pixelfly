%------
%Author: David McKay
%Created: March 2011
%Summary: Close the camera (mostly deallocate the buffers)
%------
function CamClose(hObject,handles)

if handles.RunCam
    [error_code] = pfREMOVE_ALL_BUFFER_FROM_LIST(handles.board_handle);

    %deallocate buffers
    if isfield('bufnums',handles)
    for i = 1:length(handles.bufnums)
%         if handles.buf_nums(i)~=-1 %check the buffer was allocated
%             
%             %unmap the buffers
%             if ~handles.buf_ptrs(i).isNull 
%                 [error_code] = pfUNMAP_BUFFER(handles.board_handle,handles.buf_nums(i));
%                 if(error_code~=0) 
%                  error(['Error unmapping buffer. Error is ',int2str(error_code)]);
%                  return;
%                 end 
%             end
%             
%             %deallocate the buffers
%             [error_code] = pfFREE_BUFFER(handles.board_handle,handles.buf_nums(i));
%             if(error_code~=0) 
%              error(['Error freeing buffer. Error is ',int2str(error_code)]);
%              return;
%             end 
%         end        
        
        [error_code] = pfFREE_BUFFER(handles.board_handle, handles.bufnums(i));
    end
    
    end
    
    [error_code] = pfCLOSEBOARD(handles.board_handle);
    if(error_code~=0) 
     error(['Error closing camera. Error is ',int2str(error_code)]);
     return;
    end 

    handles.board_handle = libpointer;
    guidata(hObject,handles);
end