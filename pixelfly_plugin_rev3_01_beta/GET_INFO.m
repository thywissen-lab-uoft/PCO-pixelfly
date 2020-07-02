function GET_INFO()
% pfGET_INFO();
% pfGET_INFO does display some information of all connected cameras 
% it does load the library, open a camera, read information and close the
% camera 
% 2008 June -  MBL PCO AG
% 2012 November - new pf_cam SDK (64Bit) MBL PCO AG

%load our defines 
 fid = fopen('pf_def.txt','rt');
 if( fid == -1 )
  pf_create_deffile();   
  fid = fopen('pf_def.txt','rt');
  if( fid == -1 )
   error('Unable to create and open file: pf_def.txt');
  end 
 end
 while( true )
  tline = fgetl(fid);
  if(tline == -1)
   break;
  end
  tline=strcat(tline,';');
  eval(tline);
 end
 fclose(fid);

 if not(libisloaded('PCO_PF_SDK'))
 loadlibrary('pf_cam','PfcamMatlab.h' ...
              ,'addheader','PfcamExport.h' ...
              ,'alias','PCO_PF_SDK');
 end


 for n=1:4
  board_number = int32(n-1);
  disp(['call INITBOARD(',int2str(board_number),')']);
  %try to initialize camera
  [error_code,board_handle]=pfINITBOARD(board_number);
  pco_errdisp('pfINITBOARD',error_code);
  e=pco_uint32err(error_code);
  if((bitand(e,(hex2dec('0F000FFFF'))))==PCO_ERROR_DRIVER_HEAD_LOST)    
   init=2;
  elseif(error_code~=0) 
   disp('no more cameras connected');
   break;
  else
   init=1;   
  end 
  
  if(init==2)
   disp('Camera head not connected');
  else
   disp(['Camera connected to board ',int2str(board_number)]);

   [error_code, value] = pfGETBOARDVAL(board_handle,'PCC_VAL_CCDTYPE');
   if(error_code)
    pco_errdisp('pfGETBOARDVAL',error_code);   
   else
    if(bitand(value,hex2dec('01'))==hex2dec('01'))
     disp('Camera Head has a Color CCD')     
    else 
     disp('Camera Head has a BW CCD')     
    end 
   end
 
   [error_code, value] = pfGETBOARDVAL(board_handle,'PCC_VAL_EXTMODE');
   if(error_code)
    pco_errdisp('pfGETBOARDVAL',error_code);   
   else
    if(bitand(value,hex2dec('01'))~=0)
     disp('Camera Head has DOUBLE feature')     
    end 
    if(bitand(value,hex2dec('FF00'))~=0)
     disp('Camera Head has PRISMA feature')     
    end
    if(bitand(value,hex2dec('010000'))~=0)
     disp('Camera Head has LOGLUT feature')     
    end
   end
  
   [error_code,ccd_width,ccd_height,image_width,image_height]=pfGETSIZES(board_handle);
   if(error_code)
    pco_errdisp('pfGETSIZES',error_code);   
   else
    disp(['Max. Resolution is: ', int2str(ccd_width), 'x' int2str(ccd_height)]);
    disp(['Act. Resolution is: ', int2str(image_width), 'x' int2str(image_height)]);
   end 
  end
  
  disp(' ');
  
%read HEAD version     
  text=blanks(100);
  [error_code,out_ptr, text]= calllib('PCO_PF_SDK','READVERSION',board_handle,5,text,100);
  if(error_code)
   pco_errdisp('READVERSION',error_code);   
  else
   disp(strtrim(text));   
  end  
  clear(text);

%read HW version     
  text=blanks(100);
  [error_code,out_ptr, text]= calllib('PCO_PF_SDK','READVERSION',board_handle,4,text,100);
  if(error_code)
   pco_errdisp('READVERSION',error_code);   
  else
   disp(strtrim(text));   
  end  
  clear(text);
 
%read CPLD version     
  text=blanks(100);
  [error_code,out_ptr, text]= calllib('PCO_PF_SDK','READVERSION',board_handle,6,text,100);
  if(error_code)
   pco_errdisp('READVERSION',error_code);   
  else
   disp(strtrim(text));   
  end  
  clear(text);
 
%read PLUTO version     
  text=blanks(100);
  [error_code,out_ptr, text]= calllib('PCO_PF_SDK','READVERSION',board_handle,1,text,100);
  if(error_code)
   pco_errdisp('READVERSION',error_code);   
  else
   disp(strtrim(text));   
  end  
  clear(text);
 
%read CIRCE version     
  text=blanks(100);
  [error_code,out_ptr, text]= calllib('PCO_PF_SDK','READVERSION',board_handle,2,text,100);
  if(error_code)
   pco_errdisp('READVERSION',error_code);   
  else
   disp(strtrim(text));   
  end  
  clear(text);
 
%read ORION version     
  text=blanks(100);
  [error_code,out_ptr, text]= calllib('PCO_PF_SDK','READVERSION',board_handle,3,text,100);
  if(error_code)
   pco_errdisp('READVERSION',error_code);   
  else
   disp(strtrim(text));   
  end  
  clear(text);
 
 text=blanks(100);
 text1=blanks(100);
 [error_code,out_ptr, text,text1]= calllib('PCO_PF_SDK','PCC_GET_VERSION',board_handle,text,text1);
  if(error_code)
   pco_errdisp('PCC_GET_VERSION',error_code);   
  else
   disp(['DLL Version: ',text]);   
   disp(['SYS Version: ',text1]);
  end  
  clear(text);
  clear(text1);
  [error_code] = pfCLOSEBOARD(board_handle,0); 
  if(error_code)
   pco_errdisp('pfCLOSEBOARD',error_code);   
  else
   disp(['camera ',int2str(board_number),' closed']);     
  end 
  disp(' '); 
 end
 if(libisloaded('PCO_PF_SDK'))
  unloadlibrary('PCO_PF_SDK');
 end 
end   
