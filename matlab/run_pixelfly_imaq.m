% Runs the image acquisition GUI for the PCO Pixelfly cameras

% Get the full path of this directory
curpath = fileparts(mfilename('fullpath'));

% Add all subdirectories to this path
addpath(curpath);
addpath(genpath(curpath))

% Add the SDK MATLAB drivers to the path
sdk_dir=fullfile(fileparts(curpath), 'pixelfly_plugin_rev3_01_beta');
addpath(sdk_dir);

% Add the Fitter files to the path
fitterDir='Y:\_ImageProcessing\Fitter';
addpath(fitterDir);
addpath(genpath(fitterDir));

% Run the image acquisition GUI
image_acquisition;