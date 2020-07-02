%------
%Author: Stefan Trotzky
%Created: November 2013
%Summary: Retrieves seqdata saved in the communications directory
%------
function out = GetSeqData(path,timestamp,tolerance)

    % default max. deviation of timestamp: 0s earlier, 30s later.
    if nargin == 2; tolerance = [0 30]; end
    if length(tolerance) == 1; tolerance = tolerance*[1 1]; end;
    
    % tolerance = tolerance + 

    % valid names of seqdata files
    validnames = {'currseq.mat','lastseq.mat'};

    if exist(path, 'dir');
        j = 1; s = []; diff = [];
        % walk through valid filenames
        for i = 1:length(validnames)
            % move on if file exists in directory
            if exist([path filesep validnames{i}], 'file')
                p = load([path filesep validnames{i}],'-mat');
                % move on if file contains valid seqdata structure with
                % field seqend
                if isfield(p,'seqdata')
                if isfield(p.seqdata,'seqend')
                        s = [s p];
                end
                end
            end
        end
        
        % compare sequence end times to timestamp (within tolerance?)
        for i = 1:length(s)
            diff(i) = (timestamp - s(i).seqdata.seqend)*1e5;
            
                        %[311e5 2592e3 864e2 36e2 60 1]*...
             %    (datevec(timestamp) - datevec(s(i).seqdata.seqend))';
        end
        [diff2,idx] = sort(diff*(-diff<=tolerance(1))*(diff<=tolerance(2)));
        
        % if one is left, take the one with the smallest difference
        if ((diff2(1)~=0) || ((diff2(1)==0) && (diff(idx(1))==0)))
            out = s(idx(1)).seqdata;
        else
            disp('Warning: did not find matching seqdata file.')
            out = 0;
        end
        
    end
end