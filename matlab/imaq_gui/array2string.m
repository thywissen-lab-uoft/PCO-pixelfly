%------
%Author: Stefan Trotzky
%Created: November 2013
%Summary: Builds a string out of a numeric array to display in a text field
%------
function out = array2string(in)
    out = ''; 
    if (isnumeric(in) && (~isempty(in)))
        s = size(in);
        if s(1) > s(2); in = in'; end % change column vector into row vector
        in = in(1,:); % take first row only
        if length(in) == 1;
            out = sprintf('[ %g ]',in);
        elseif length(in) > 1;
            out = ['[ ' sprintf('%g   ',in(1:end-1)) sprintf('%g ]',in(end))];
        end
    end
end