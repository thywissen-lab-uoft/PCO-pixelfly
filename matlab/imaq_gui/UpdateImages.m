%------
%Author: David McKay
%Created: March 2011
%Summary: Update the image controls with new data
%Input: handles - handle to the gui
%------

function UpdateImages(handles)

%get the current scale factor (maybe put in autoscale?)
raw_scalefactor = 2^(getProperty('ImgBitSize',handles))*getProperty('ImgContrast',handles);
od_scalefactor = getProperty('MaxOD',handles)*getProperty('ImgContrast',handles);

%update the raw image controls
image(gray2ind(handles.Images{1}/raw_scalefactor),'Parent',handles.pic1);
image(gray2ind(handles.Images{2}/raw_scalefactor),'Parent',handles.pic2);
image(gray2ind(handles.Images{3}/raw_scalefactor),'Parent',handles.pic3);

%update the main OD image
ROI = getProperty('ROI',handles);
CTR = getProperty('CTR',handles);
imgOD = gray2ind(1E3*calcOD(handles.Images{1},handles.Images{2},handles.Images{3})/od_scalefactor);
if getProperty('UseROI',handles)
    if ~isempty(ROI)
        ROI = [sort(ROI(:,1)) sort(ROI(:,2))];
        if ( (ROI(1,1)>=1) && (ROI(1,2)>=1) && ...
            (ROI(2,1)<=size(imgOD,2)) && (ROI(2,2)<=size(imgOD,1)) && (ROI(2,1)>ROI(1,1)) && (ROI(2,2)>ROI(1,2)) )
            % cut OD image down to ROI
            imgOD = imgOD(ROI(1,2):ROI(2,2),ROI(1,1):ROI(2,1));
            if ~isempty(CTR); CTR = CTR - ROI(1,:); end
            % show white rectangles
            axes(handles.pic1); hold on; rectangle('Position',[ROI(1,:) ROI(2,:)-ROI(1,:)],'EdgeColor','w'); hold off;
            axes(handles.pic2); hold on; rectangle('Position',[ROI(1,:) ROI(2,:)-ROI(1,:)],'EdgeColor','w'); hold off;
            axes(handles.pic3); hold on; rectangle('Position',[ROI(1,:) ROI(2,:)-ROI(1,:)],'EdgeColor','w'); hold off;         
        end
    end
    image(imgOD,'Parent',handles.mainpic);
else
    image(imgOD,'Parent',handles.mainpic);
    % add white ROI box to image if not used
    if ~isempty(ROI)
        ROI = [sort(ROI(:,1)) sort(ROI(:,2))];
        if ( (ROI(1,1)>=1) && (ROI(1,2)>=1) && ...
            (ROI(2,1)<=size(imgOD,2)) && (ROI(2,2)<=size(imgOD,1)) && (ROI(2,1)>ROI(1,1)) && (ROI(2,2)>ROI(1,2)) )
            axes(handles.mainpic); hold on; rectangle('Position',[ROI(1,:) ROI(2,:)-ROI(1,:)],'EdgeColor','w'); hold off;
        end
    end
end
if ~isempty(CTR)
    axes(handles.mainpic); hold on; plot(CTR(1),CTR(2),'+w'); hold off;
end

colormap(handles.mainpic,jet)
colormap(handles.pic1,jet)
colormap(handles.pic2,jet)
colormap(handles.pic3,jet)

% Display fit results for the current image if they are available
fitstr = '';
if isfield(handles,'ImagePars')
    if isfield(handles.ImagePars,'fitresults')
        fitstr = array2string(flipud(handles.ImagePars.fitresults));
    end
end
set(handles.txt_FitResult,'String',fitstr);

image_hnds = [handles.pic1 handles.pic2 handles.pic3 handles.mainpic];

%remove ticks and labels from all the axes
for i = 1:4
    set(image_hnds(i),'XTickLabel','');
    set(image_hnds(i),'XTick',[]);
    set(image_hnds(i),'YTickLabel','');
    set(image_hnds(i),'YTick',[]);
    %set(image_hnds(i),'XLim',[1 1100]);
    %set(image_hnds(i),'YLim',[1 1100]);
end