%------
%Author: David McKay
%Created: March 2011
%Summary: Get Property from the GUI Data
%------

function propvalue = getProperty(propname,handles)
% propname   name of property to get
% handles    structure with handles and user data (see GUIDATA)

for i = 1:length(handles.PropertyDefs)
    if strcmpi(propname,handles.PropertyDefs{i,1})
        propvalue = handles.PropertyDefs{i,3};
        break;
    end
end