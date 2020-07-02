%------
%Author: David McKay
%Created: March 2011
%Summary: Check for hardware triggers and if all the buffers are loaded
%then read in the images and process (ie. run fit) | ST-2013-11 added save
%and autosave features.
%------
function CheckforTriggers(tmrobj,event,hObject)

handles = guidata(hObject);

if ~handles.RunCam
    return;
end

NumImages = getProperty('NumImages',handles);
AllImagesLoaded = 0;

% Get the status of the first buffer
if (GetBuffStatus(handles,1,0)==3)
    disp('First Image Loaded')
end

% Get the status of the second buffer
if (GetBuffStatus(handles,2,0)==3)
    disp('Second Image Loaded')
    if NumImages == 2
        AllImagesLoaded = 1;
    end
end

% Get the status of the third buffer if necessary
if NumImages==3 && (GetBuffStatus(handles,3,0)==3) 
    disp('Third Image Loaded')
    AllImagesLoaded = 1;
end
    
if AllImagesLoaded    
    % get time at which image was taken
    stamp = now;
    
    % stop looking for triggers
    stop(tmrobj);

    % read in new images
    handles = ReadInImages(hObject,handles);

    % update the displayed images
    UpdateImages(handles);

    %re-queue
    CamQueueBuffers(hObject,handles);
    
    % create new image-parameters structure
    pars = struct('cam','PixelFly');
    
      
    % Perform fit and add fit result to image-parameter structure
    if getProperty('RunFit',handles)
        %set this flag for different images
        %0: absorption
        %1: fluorescence with reference
        %2: averaged fluorescence of two images
        %3: fluor first picture only
        %4: high-field imaging
        pars.image_type = 0;
        pars.fit_type = get(handles.txtFitType,'String');
        pars.cam = 'Pixelfly';
        mag = cellstr(get(handles.popMag,'String'));
        pars.magnification = str2double(mag{get(handles.popMag,'Value')});
        
        % Process the images
        [pars.fitresults, pars.processcmd] = ...
            process_images({handles.Images{1} handles.Images{2} handles.Images{3}},pars);
        % display last fitresult saved with file
        fitstr = array2string(flipud(pars.fitresults));
        set(handles.txt_FitResult,'String',fitstr);
    end

    % add information
    pars.time = stamp;
    pars.numimages = getProperty('NumImages',handles); % numbers of images
    pars.ROI = getProperty('ROI',handles); % ROI as currently set in GUI
    pars.CTR = getProperty('CTR',handles);
    
    % start looking for triggers again (do this before saving images to
    % in case problems occur in the parts below.
    start(tmrobj);
    
    % Save images
    if getProperty('SaveImages',handles)
        % Get directory and filename from gui properties
        directory = getProperty('SaveDirectory',handles);
        cnt = getProperty('SaveCount',handles);
        cntstr = sprintf('%0.4f',cnt/10000); cntstr = cntstr(end-3:end);
        filename = [getProperty('SavePrefix',handles) ...
            SeqParameterString(getProperty('SaveParameters',handles)) ...
            cntstr '.mat'];
        logfilename = [getProperty('SavePrefix',handles) '_results' '.log'];
        try ProcessCmds = ReadInOutputParamFile(1); catch; ProcessCmds.scanparams = []; end
        pars.autosavename = [directory filesep filename];
        dlmwrite([directory filesep logfilename],[cnt ProcessCmds.scanparams pars.fitresults(end,:)],'-append')
        % Save image 
        ret = ImageSave({handles.Images{1} handles.Images{2} handles.Images{3}}, ...
            [directory filesep filename], pars, 1);
        if ( ret );
            handles = setProperty(hObject,'SaveCount',cnt+1,handles);
            handles = setProperty(hObject,'ImageFile',pars.autosavename,handles);
            set(handles.txt_ImageCount,'String',sprintf('%g',getProperty('SaveCount',handles)));
            pars.saved = 1;
            disp(['Saved file ' pars.autosavename '.'])
        end
    else
        handles = setProperty(hObject,'ImageFile','',handles);
    end
    
    % Autosave images for history
    if getProperty('AutoSaveImages',handles)
        % Get directory and filename from gui properties
        directory = getProperty('AutoSaveDirectory',handles);
        
        % Build filename from time stamp
        filename = ['PixelFlyImage_' ...
            regexprep((regexprep(datestr(stamp,31),':','-')),' ','_') '.mat'];
        % Save image
        ImageSave({handles.Images{1} handles.Images{2} handles.Images{3}}, ...
            [directory filesep filename], pars, 1, getProperty('NumHistory',handles));
        handles = setProperty(hObject,'ImageHistoryFile',[directory filesep filename],handles);
    else
        handles = setProperty(hObject,'ImageHistoryFile','',handles);
    end
    
    % store image properties and update display
    handles.ImagePars = pars;
    guidata(hObject,handles);
    UpdateImages(handles);
    
    % reset history slider and displays
    set(handles.sld_History,'Value',0);
    set(handles.txt_History,'String','');
    set(handles.txt_HistoryFile,'String','');
    setProperty(hObject,'IsHistory',0,handles);
    setProperty(hObject,'IsFresh',1,handles);

end
    
end