function [err] = pco_uint32err(error_code)
 if(error_code<0)
  e=error_code*-1;
%  disp(['negativ 0x',num2str(e,'%08X')]);   
  err=uint32(e)-1;
%   err=bitcmp(err,32);
    err=bitcmp(err,'uint32'); %CJF 2020

%  disp(['als uint32 0x',num2str(e1,'%08X')]);   
 else
  err=uint32(error_code);   
 end
end
