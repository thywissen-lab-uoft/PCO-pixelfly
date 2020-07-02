%------
%Author: Stefan Trotzky
%Created: November 2013
%Summary: 
%------
function out = SeqParameterString(cmd,handles)
    out = '_';
    warning = 0;
    
    if iscell(cmd)&&(length(cmd)>0)
        
        % read control.txt file
        try
            ProcessCmds = ReadInOutputParamFile(1);
        catch
            ProcessCmds = [];
        end
        
        % break up cmd and prepare names and strings
        Names = {}; Strings = {};
        if ~iscell(cmd{1}) 
            cmd = {cmd}; % assume single pair
        end    
        
        for j = 1:length(cmd)
            
            this = cmd{j};
            try
                if (iscell(this) && length(this)==2 && ischar(this{1})&& ischar(this{2}))
                    Names{length(Names)+1} = this{1};
                    if isempty(strfind(this{2},'%'))
                        Strings{length(Names)} = [this{2} '=%g'];
                    else
                        Strings{length(Names)} = this{2};
                    end
                else
                    warning = 1;
                end
            catch
                warning = 1;
            end
            
        end
        
        % build parameter string
        for j = 1:length(Names)
            
            if isfield(ProcessCmds,Names{j}) % check for existence of field
                value = getfield(ProcessCmds, Names{j});
                out = [out sprintf(Strings{j}, value) '_'];
            else
                warning = 1;
            end
            
        end
    end
    
    if ( warning )
        disp('Warning: Warnings have been generated in SeqParameterString.m .');
    end
end