%------
%Author: David McKay
%Created: March 2011
%Summary: Read images from the buffer
%------
function handles = ReadInImages(hObject,handles)

%Assume this has been called by something that checks there are actually
%images in the buffers

for i = 1:getProperty('NumImages',handles) 
    handles.Images{i}=double(get(handles.buf_ptrs(i),'Value'));
end

guidata(hObject,handles);
    
end