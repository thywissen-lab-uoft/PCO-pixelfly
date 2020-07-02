function [error_code,board_handle] = pfINITBOARDP(board_number)
% [error_code,board_handle] = pfINITBOARDP(board_number);
% pfINITBOARD resets the PCI interface board hardware as well as the camera
% to default values. It checks whether a camera is connected and a PCI
% interface board is installed. Please read pixelfly SDK Manual for parameter 
% descriptions, in brackets the Matlab type is given...
%  
% input  : board_number [int32] - board_number of PCI board
% output : error_code [int32] - zero on success, nonzero indicates failure,
%                               returned value is the errorcode
%          board_handle[libpointer] - board_handle, to be used with all other functions 
%
% date: 03.2003 / written by S. Zhao, The Cooke Corporation,
% www.cookecorp.com
% revision history:
% 2005 March - first release
% 2005 March - changed bit_pix to bit_pix_ptr in calllib, GHo, PCO AG
% 2008 June - switch to work with handles MBL PCO AG
% 2012 November - new pf_cam SDK (64Bit) MBL PCO AG

if nargin ~= 1
    error('...wrong number of arguments have been passed to pfINITBOARD, see help!')
end

% check if library has been already loaded
if not(libisloaded('PCO_PF_SDK'))
 loadlibrary('pf_cam','PfcamMatlab.h' ...
              ,'addheader','PfcamExport.h' ...
              ,'alias','PCO_PF_SDK');
end

board_number = int32(board_number);
ph_ptr=libpointer('voidPtrPtr');

% init camera
[error_code,board_handle] = calllib('PCO_PF_SDK', 'INITBOARD', board_number,ph_ptr);

end   
