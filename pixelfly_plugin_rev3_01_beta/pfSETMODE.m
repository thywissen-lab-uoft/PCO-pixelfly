function [error_code] = pfSETMODE(board_handle, mode, explevel, ...
                     exptime, hbin, vbin, gain, pf_offset, bit_pix, shift)
% [error_code] = pfSETMODE(board_handle, mode, explevel, exptime, ...
%                                hbin, vbin, gain, offset, bit_pix, shift); 
% pfSETMODE sets the parameters for the next image uptake. It can't be
% called if the camera is running. All parameters are checked. pixelfly SDK
% manual p. 6.
% input  : board_handle [libpointer] - board_handle from INITBOARD
%         mode [int32]     - set mode of the camera:
%                            0x10 d16 single asynchron shutter, hardware trigger
%                            0x11 d17 single asynchron shutter, software trigger
%                            0x20 d32 double asynchron shutter, hardware trigger
%                            0x21 d33 double asynchron shutter, software trigger
%                            0x30 d48 video mode, hardware trigger
%                            0x31 d49 video, software trigger
%                            0x40 d64 single auto exposure, hardware trigger
%                            0x41 d65 single auto exposure, software trigger
%         explevel [int32] - sets level in [%] which time to stop the auto
%                            exposure mode, only valid if auto exposure mode is set
%         exptime [int32]  - sets exposure time:
%                            mode 0x10 or 0x11: 10..10000 [us]
%                            mode 0x30 or 0x31: 1..10000 [ms]
%         hbin [int32]     - sets horizontal binning and region of camera
%                            0x00000 d0 hor x1 normal readout
%                            0x00001 d1 hor x2 normal readout
%                            0x10000 d0 hor x1 extended readout
%                            0x10001 d1 hor x2 extended readout
%         vbin [int32]     - sets vertical binning of the camera
%                            0 vertical x1
%                            1 vertical x2
%                            2 vertical x4 (only VGA)
%         gain [int32]     - sets gain value of the camera:
%                            0 = low gain, 1 = high gain
%         pf_offset [int32]- not used
%         bit_pix [int32]  - set how many bits per pixel are transferred
%                            bit_pix = 12: 12bits per pixel, no shift possible.
%                            Two bytes with the upper four bits set to zero are
%                            sent. Therefore two pixel values are moved with one
%                            PCI (32bit) transfer.
%                            bit_pix = 8 : 8bits per pixel, shift possible.
%                            8bit values are generated with a programmable barrel
%                            shifter from the 12bit A/D values. Therfore four pixel
%                            are moved in one PCI transfer. This reduces the amount
%                            of pixel data per image by 50% and frees the PCI bus.
%         shift [int32]    - sets the digital gain value, only available in the
%                            8bit per pixel mode (see above)
%                            shift: 0 - 8bit (D11..D4), digital gain x1
%                                   1 - 8bit (D10..D3), digital gain x2
%                                   2 - 8bit (D09..D2), digital gain x4
%                                   3 - 8bit (D08..D1), digital gain x8
%                                   4 - 8bit (D07..D0), digital gain x16
%                                   5 - 8bit (D06..D0), digital gain x32
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

if nargin ~= 10
 error('...wrong number of arguments have been passed to pfSETMODE, see help!')
end

mode = uint32(mode); 
explevel = int32(explevel);
bit_pix = int32(bit_pix); 
exptime = int32(exptime);
gain = int32(gain);
hbin = int32(hbin);
vbin = int32(vbin);
if(pf_offset~=0)
 pf_offset = int32(0);
end 
bit_pix = int32(bit_pix);
shift = int32(shift);

error_code =calllib('PCO_PF_SDK', 'SETMODE', board_handle, mode, explevel, exptime, ...
         hbin, vbin, gain, pf_offset, bit_pix, shift);

%after the setting is done, offset regulation of older cameras does need some time
%therefore this wait is included here
if(error_code~=0)
 return;
end

text=blanks(100);
[error_code,out_ptr, text]= calllib('PCO_PF_SDK','READVERSION',board_handle,5,text,100);
if(error_code~=0)
 disp('error in READVERSION');
else
 txt='HEAD: 4.';
 tim=1.5;
 [error_code, value] = pfGETBOARDVAL(board_handle,'PCC_VAL_CCDTYPE');
 if(error_code == 0)
  value=bitand(value,hex2dec('FE'));
  switch(value)
     case {hex2dec('00'),hex2dec('08'),hex2dec('0A'),hex2dec('80')}
      tim=0.5;
         
     case hex2dec('10')
      tim=1.0;
      
     case {hex2dec('20'),hex2dec('30'),hex2dec('40'),hex2dec('42'),hex2dec('48'),...
           hex2dec('4A'),hex2dec('50'),hex2dec('60')}
      tim=1.5;
  end
 end
 if(strncmp(text,txt,8)==0)
  pause(tim);
 end
end 

disp(text)
     
end
