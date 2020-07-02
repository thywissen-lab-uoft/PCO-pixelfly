function [error_code] = pfCLOSEBOARD(board_handle,unload_lib)
% [error_code] = pfCLOSEBOARD(board_number);
% pfCLOSEBOARD resets the PCI-Controller-Board and closes the driver.
% pixelfly SDK manual p.5.
% input  : board_handle [libpointer] - board_handle from INITBOARD
%          unload_lib [int]   - zero do not unload library             
% output : error_code [int32] - zero on success, nonzero indicates failure,
%                               returned value is the errorcode
% date: 03.2003 / written by S. Zhao, The Cooke Corporation,
% www.cookecorp.com
% revision history:
% 2005 March - first release
% 2005 March - added help comments GHo, PCO AG
% 2008 June - switch to work with handles MBL PCO AG
% 2012 November - new pf_cam SDK (64Bit) MBL PCO AG

if not(libisloaded('PCO_PF_SDK'))
 error('library must have been loaded with pfINITBOARD')
end

if nargin < 1
 error('...wrong number of arguments have been passed to pfCLOSEBOARD, see help!')
end

if nargin == 1
 unload=1;
else
 unload=unload_lib;
end 

error_code = calllib('PCO_PF_SDK', 'CLOSEBOARD', board_handle);
if(unload)
 unloadlibrary('PCO_PF_SDK');
 disp('unloadlibrary PCO_PF_SDK done'); 
end    

end

