%------
%Author: David McKay
%Created: March 2011
%Summary: Set a guidata property
%------

function handles = setProperty(hObject,propname,propvalue,handles)
% hObject    handle of object on GUI
% propname   name of property to get
% handles    structure with handles and user data (see GUIDATA)

for i = 1:length(handles.PropertyDefs)
    if strcmpi(propname,handles.PropertyDefs{i,1})
        if handles.PropertyDefs{i,2}(propname,propvalue,handles)
            handles.PropertyDefs{i,3} = propvalue;
            break;
        end
    end
end

%update guidata
guidata(hObject,handles);