function [error_code] = pfSET_EXPOSURE(board_handle, exptime)
% [error_code] = pfSET_EXPOSURE(board_handle,exptime);
% pfSET_EXPOSURE is only available with the latest PCO-board-Software
% revisions and only in single asynchronous shutter mode (mode in pfSETMODE
% is either 0x10 d16 or 0x11 d17). It can be called while the camera is
% running. The exposure time is changed at the next possible frame.
% pixelfly SDK manual p.8.
% input  : board_handle [libpointer] - board_handle from INITBOARD
%          exptime [int32]      - exposure time in [µs], range: 10..65535
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

if nargin ~= 2
 error('...wrong number of arguments have been passed to pfSET_EXPOSURE, see help!')
end

exptime = int32(exptime);
error_code =calllib('PCO_PF_SDK', 'SET_EXPOSURE', board_handle, exptime);

end


