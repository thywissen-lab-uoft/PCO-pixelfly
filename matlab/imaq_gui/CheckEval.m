%------
%Author: Stefan Trotzky
%Created: November 2013
%Summary: Checks whether an input string can be evaluated.
%------
function out = CheckEval(string)
    out = [];
    if ischar(string)
        try
            out = eval(string);
        catch
        end
    end
end