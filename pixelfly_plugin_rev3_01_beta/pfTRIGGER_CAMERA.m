function [error_code] = pfTRIGGER_CAMERA(board_handle)
% [error_code] = pfTRIGGER_CAMERA(board_handle);
% pfTRIGGER_CAMERA releases a single exposure in the software trigger mode.
% pixelfly SDK manual p.8.
% input  : board_handle [libpointer] - board_handle from INITBOARD
% output : error_code [int32] - zero on success, nonzero indicates failure,
%                               returned value is the errorcode
% date: 03.2003 / written by S. Zhao, The Cooke Corporation,
% www.cookecorp.com
% revision history:
% 2005 March - first release
% 2005 March - added help comments GHo, PCO AG
% 2008 June - switch to work with handles MBL PCO AG
% 2012 November - new pf_cam SDK (64Bit) MBL PCO AG

% check if library has been already loaded
if not(libisloaded('PCO_PF_SDK'))
 error('library must have been loaded with pfINITBOARD')
end

if nargin ~= 1
 error('...wrong number of arguments have been passed to pfTRIGGER_CAMERA, see help!')
end

error_code = calllib('PCO_PF_SDK', 'TRIGGER_CAMERA', board_handle);

end
