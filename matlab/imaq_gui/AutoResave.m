%------
%Author: Stefan Trotzky
%Created: November 2013
%Summary: Resaving the current image (if it was saved before) ... needs
%some TLC
%------
function AutoResave(handles)
    file = getProperty('ImageFile',handles);
    historyfile = getProperty('ImageHistoryFile',handles);
    
    if ~isempty(file);
%         disp(['Resaving ' file '.'])
%         ImageSave(handles.Images,file,handles.ImagePars,0,0);
    end
    
    if ~isempty(historyfile);
%         disp(['Resaving ' historyfile '.'])
        ImageSave(handles.Images,historyfile,handles.ImagePars,0,0);
    end
end