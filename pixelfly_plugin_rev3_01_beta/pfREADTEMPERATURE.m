function [error_code,temp_ccd] = pfREADTEMPERATURE(board_handle)
% [error_code,temp_ccd] = pfREADTEMPERATURE(board_number)
% pfREADTEMPERATURE returns the actual CCD temperature. The measuring range
% is -55°C..+125°C. pixelfly SDK manual p.9.
% input  : board_handle [libpointer] - board_handle from INITBOARD
% output : error_code [int32] - zero on success, nonzero indicates failure,
%                               returned value is the errorcode
%          temp_ccd [int32]     - CCD temperature in °C
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
 error('...wrong number of arguments have been passed to pfREADTEMPERATURE, see help!')
end

temp_ccd = int32(-1);
temp_ccd_ptr = libpointer('int32Ptr', temp_ccd);
error_code =calllib('PCO_PF_SDK', 'READTEMPERATURE', board_handle, temp_ccd_ptr);
temp_ccd = int32(get(temp_ccd_ptr, 'Value'));

end
