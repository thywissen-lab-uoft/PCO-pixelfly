%------
%Author: Stefan Trotzky
%Created: November 2013
%Summary: Automatically saving new images (called from CheckforTriggers.m)
%------
function [images, pars] = ImageLoad(file)
  % default: do not save as history (i.e. limiting number of images in
  % directory)
  
  images = {0}; pars = 0;
  
  % break up filename
  [path, filename, ext] = fileparts(file);
  
  % Check file extension
  if ~strcmpi(ext,'.mat')
      disp(['Warning: loading file with extension ' ext '.'])
  end
  
  % Proceed if path, file and image exists
  if exist(path, 'dir')
      if exist(file,'file')
          p = load(file);
          if isfield(p,'images')
              images = p.images;
              if isfield(p,'par'); pars = p.par; end
              if isfield(p,'pars'); pars = p.pars; end              
          else
              disp('Failure: File does not appear to contain an image.');
          end
      else
          disp(['Failure: Could not load image, file ' file ' not found.']);
      end
  else
      disp(['Failure: Could not load image, directory ' path ' not found.']);
  end
  
end