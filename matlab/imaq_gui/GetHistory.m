%------
%Author: Stefan Trotzky
%Created: November 2013
%Summary: Browse in history of files
%------
function GetHistory(num, handles)
    
    path = getProperty('AutoSaveDirectory', handles);
    
    % get list of history files and sort by time & date
    filelist = dir([path filesep 'PixelFlyImage_' '*' '.mat']);
    dates = zeros(length(filelist));
    for j=1:length(filelist)
        dates(j) = datenum(filelist(j).date);
    end
    [void, idx] = sort(dates(:,1),'descend');
    
    % retrieve image from history 
    if num <= length(filelist)
        [img, pars] = ImageLoad([path filesep filelist(idx(num)).name]);
        name = filelist(idx(num)).name;
        % updating images
        numimg = getProperty('NumImages',handles);
        if length(img) ~= (numimg + 1);
            disp('Wrong number of subimages. Doing nothing.');
        else
            % update image display
            handles.Images = img; 
            handles.ImagePars = pars;
            guidata(handles.mainfigure,handles); 
            UpdateImages(handles);
            
            % update properties
            handles = setProperty(handles.mainfigure,'IsHistory',1,handles);
            handles = setProperty(handles.mainfigure,'ImageHistoryFile',...
                [path filesep filelist(idx(num)).name],handles);
            if isfield(pars,'autosavename')
                handles = setProperty(handles.mainfigure,'ImageFile',...
                    pars.autosavename,handles);
            end
            handles = setProperty(handles.mainfigure,'IsFresh',0,handles);
            
            % update controls
            set(handles.txt_History,'String',sprintf('%g',1-num));
            set(handles.txt_HistoryFile,'String',name);
        end
    else
        img = 0;
        pars.failed = 1;
        name = 'Does not exist (yet)!';
    end
    


end