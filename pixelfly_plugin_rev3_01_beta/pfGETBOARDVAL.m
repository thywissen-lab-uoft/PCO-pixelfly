function [error_code, value] = pfGETBOARDVAL(board_handle, param)
% [error_code, value] = pfGETBOARDVAL(board_number, param)
% pfGETBOARDPAR returns one value out of the BOARDVAL structure of the
% board. In the header file pccamdef.h there are definitions of the
% parameters,  which can be extracted.
% input  : board_handle [libpointer] - board_handle from INITBOARD
%          param [text]             - which parameter to read
% output : error_code [int32] - zero on success, nonzero indicates failure,
%                               returned value is the errorcode
%          value [uint32]     - value returned from function
% revision history:
% 2008 June - function added, switch to work with handles MBL PCO AG
%             values of param_off must conform to the definitions in
%             pccamdef.h
% 2012 November - new pf_cam SDK (64Bit) MBL PCO AG

% check if library has been already loaded
if not(libisloaded('PCO_PF_SDK'))
 error('library must have been loaded with pfINITBOARD')
end

if nargin ~= 2
 error('...wrong number of arguments have been passed to pfGETBOARDVAL, see help!')
end


switch upper(param)
    case {'PCC_VAL_BOARD_INFO'}   
     param_off=0;
    case {'PCC_VAL_BOARD_STATUS'}
     param_off=1;
    case {'PCC_VAL_CCDXSIZE'}
     param_off=2;
    case {'PCC_VAL_CCDYSIZE'}
     param_off=3;
    case {'PCC_VAL_MODE'}
     param_off=4;
    case {'PCC_VAL_EXPTIME'}
     param_off=5;
    case {'PCC_VAL_EXPLEVEL'}
     param_off=6;
    case {'PCC_VAL_BINNING'}
     param_off=7;
    case {'PCC_VAL_AGAIN'}
     param_off=8;
    case {'PCC_VAL_BITPIX'}
     param_off=9;
    case {'PCC_VAL_SHIFT'}
     param_off=10;
    case {'PCC_VAL_OFFSET'}
     param_off=11;
    case {'PCC_VAL_LASTEXP'}
     param_off=12;
    case {'PCC_VAL_EXTMODE'}
     param_off=13;
    case {'PCC_VAL_CCDTYPE'}
     param_off=14;
    case {'PCC_VAL_LINETIME'}
     param_off=15;

    case {'PCC_VAL_TIMEOUT_PROC'}
     param_off=32;
    case {'PCC_VAL_TIMEOUT_DMA'}
     param_off=33;
    case {'PCC_VAL_TIMEOUT_HEAD'}
     param_off=34;

    case {'PCC_VAL_DMACOUNT'}
     param_off=48;
    case {'PCC_VAL_ERRORCOUNT'}
     param_off=49;
    case {'PCC_VAL_FIFOCOUNT'}
     param_off=50;
    case {'PCC_VAL_DMATIMEOUTCOUNT'}
     param_off=51;

    case {'PCC_VAL_FRAMETIME'}
     param_off=64;
    case {'PCC_VAL_READOUTTIME'}
     param_off=65;
    case {'PCC_VAL_VBIN'}
     param_off=66;
    case {'PCC_VAL_HBIN'}
     param_off=67;
    case {'PCC_VAL_WIDE'}
     param_off=68;
end    

value = uint32(0);
val_ptr = libpointer('uint32Ptr', value);
error_code =calllib('PCO_PF_SDK', 'GETBOARDVAL', board_handle, param_off, val_ptr);
value = uint32(get(val_ptr, 'Value'))';

end

