function handles = calcROIStats(handles)

    ROI = getProperty('ROI',handles);
    XSize = size(handles.Images{1},2);
    YSize = size(handles.Images{1},1);
    
    % calculate OD (assuming order {at, ref, bg})
    ODimg = calcOD(handles.Images{1},handles.Images{2},handles.Images{3});
    
    % check ROI and its limits
    if (size(ROI,1)~=2 || size(ROI,2)~=2); ROI = [ [1 1] ; [XSize YSize] ]; end
    ROI = [ sort(ROI(:,1)) sort(ROI(:,2)) ];
    ROI = [ max(ROI(1,:),[1 1]) ; min(ROI(2,:),[XSize YSize]) ];
    
    % crop images to ROI
    imgROI = {[],[],[]};
    for j = 1:length(handles.Images);
        img = handles.Images{j};
        imgROI{j} = img(ROI(1,2):ROI(2,2),ROI(1,1):ROI(2,1));
    end
    ODimgROI = ODimg(ROI(1,2):ROI(2,2),ROI(1,1):ROI(2,1));
    [x y] = meshgrid(ROI(1,1):ROI(2,1),ROI(1,2):ROI(2,2));    
    
    PixelSum = sum(sum(ODimgROI));
    X1 = sum(sum(x.*ODimgROI))/PixelSum;
    X2 = sum(sum(x.^2.*ODimgROI))/PixelSum;
    Y1 = sum(sum(y.*ODimgROI))/PixelSum;
    Y2 = sum(sum(y.^2.*ODimgROI))/PixelSum;
    RMS = sqrt([X2 Y2]-[X1 Y1].^2)
    
    handles = setProperty(handles.mainfigure,'CTR',round([X1 Y1]),handles);
    guidata(handles.mainfigure,handles);
    UpdateImages(handles);
    
end