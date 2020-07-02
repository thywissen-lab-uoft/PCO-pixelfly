%------
%Author: Stefan Trotzky
%Created: November 2013
%Summary: Automatically saving new images (called from CheckforTriggers.m)
%------
function out = ImageSave(images,file,pars,isfresh,ishist)
  % default: do not save as history (i.e. limiting number of images in
  % directory)
  if ~exist('ishist','var'); ishist = 0; end   % whether to save to history
  if ~exist('isfresh','var'); isfresh = 0; end % whether saving a freshly taken image
  
  out = 0;
  
  % Communication file directory
  ComPath = 'Z:\Experiments\Lattice\_communication';
  ComPath = regexprep(ComPath, '\', filesep);
  
  % Maximum number of files in history
  histmax = ishist;
  
  % break up filename
  [path, filename, ext] = fileparts(file);
  
  % Check file extension
  if ~strcmpi(ext,'.mat')
      disp(['Warning: saving file with extension ' ext '.'])
  end
  
  % Proceed if path exists
  if exist(path, 'dir')
      % save image (bit maps, timestamp, ...)
      %par.seqdata = GetSeqData(ComPath, timestamp); ---- does not work yet.
      %                                               Need better way of
      %                                               synchronization.
      %                                               (hand shake?)
      pars.seqdata = [];
      save(file, 'images', 'pars');
%       disp(['Saved file: ' file]);
      out = 1;
      % check whether to delete oldest file from history
      if ( ishist ) 
          filelist = dir([path filesep strtok(filename,'_') '*' ext]);
          if ( length(filelist) > histmax )
              dates = zeros(length(filelist));
              for j=1:length(filelist)
                  dates(j) = datenum(filelist(j).date);
              end
              [void, idx] = sort(dates(:,1));
              idx(end-histmax+1:end) = [];
              for j=1:length(idx) % delete oldest images leaving histmax images left
                  delete([path filesep filelist(idx(j)).name])
              end
          end
      end
  else
      disp(['Failure: Could not save image, directory ' path ' not found.']);
  end
end