function pco_imaqregister(reg)
%PCO_IMAQREGISTER Register/Unregister the PCOCameraAdaptor 
%
%   PCO_IMAQREGISTER or PCO_IMAQREGISTER('REGISTER')
%   First copies PCOCameraAdaptor.dll, SC2_Cam.dll, sc2_cl_me4.dll, 
%   sc2_cl_nat.dll and sc2_cl_mtx.dll from the folder of the current 
%   platform (x64 or win32) to the current folder if necessary and 
%   registeres the camera adaptor located in the current folder
%
%   PCO_IMAQREGISTER('UNREGISTER')
%   Unregisteres the PCOCameraAdaptor.dll from the registry location
%
%   See also IMAQREGISTER.

%(c) 2003-2015 PCO AG * Donaupark 11 * D-93309 Kelheim / Germany 

if(~exist('reg','var'))
    reg = 'register';
end

%get registered adaptors
adaptors = imaqregister;

if (strcmp(reg,'register'))
    %copy files
	%first check if toolbox majoir version is 5 or older
	if(verLessThan('imaq','5.0'))
	
		if(strcmp(computer('arch'),'win32'))
			
			if(~exist('./PCOCameraAdaptor.dll','file'))
				if(exist('./win32/PCOCameraAdaptor.dll','file'))
					copyfile('./win32/PCOCameraAdaptor.dll','./');
				end
			end
			
			if(~exist('./sc2_cam.dll','file'))
				if(exist('./win32/sc2_cam.dll','file'))
					copyfile('./win32/sc2_cam.dll','./');
				end
			end
			
			if(~exist('./sc2_cl_me4.dll','file'))
				if(exist('./win32/sc2_cl_me4.dll','file'))
					copyfile('./win32/sc2_cl_me4.dll','./');
				end
			end
			
			if(~exist('./sc2_cl_nat.dll','file'))
				if(exist('./win32/sc2_cl_nat.dll','file'))
					copyfile('./win32/sc2_cl_nat.dll','./');
				end
			end
			
			if(~exist('./sc2_cl_mtx.dll','file'))
				if(exist('./win32/sc2_cl_mtx.dll','file'))
					copyfile('./win32/sc2_cl_mtx.dll','./');
				end
			end
			
		elseif(strcmp(computer('arch'),'win64'))
			
			if(~exist('./PCOCameraAdaptor.dll','file'))
				if(exist('./x64/PCOCameraAdaptor.dll','file'))
					copyfile('./x64/PCOCameraAdaptor.dll','./');
				end
			end
			
			if(~exist('./sc2_cam.dll','file'))
				if(exist('./x64/sc2_cam.dll','file'))
					copyfile('./x64/sc2_cam.dll','./');
				end
			end
			if(~exist('./sc2_cl_me4.dll','file'))
				if(exist('./x64/sc2_cl_me4.dll','file'))
					copyfile('./x64/sc2_cl_me4.dll','./');
				end
			end
			
			if(~exist('./sc2_cl_nat.dll','file'))
				if(exist('./x64/sc2_cl_nat.dll','file'))
					copyfile('./x64/sc2_cl_nat.dll','./');
				end
			end
			if(~exist('./sc2_cl_mtx.dll','file'))
				if(exist('./x64/sc2_cl_mtx.dll','file'))
					copyfile('./x64/sc2_cl_mtx.dll','./');
				end
			end
			if(~exist('./sc2_clhs.dll','file'))
				if(exist('./x64/sc2_clhs.dll','file'))
					copyfile('./x64/sc2_clhs.dll','./');
				end
			end
			
		else
			error('This platform is not supported.');
		end
		
	else
	
		if(strcmp(computer('arch'),'win64'))
			
			if(~exist('./PCOCameraAdaptor.dll','file'))
				if(exist('./x64_R2016/PCOCameraAdaptor.dll','file'))
					copyfile('./x64_R2016/PCOCameraAdaptor.dll','./');
				end
			end
			
			if(~exist('./sc2_cam.dll','file'))
				if(exist('./x64_R2016/sc2_cam.dll','file'))
					copyfile('./x64_R2016/sc2_cam.dll','./');
				end
			end
			if(~exist('./sc2_cl_me4.dll','file'))
				if(exist('./x64_R2016/sc2_cl_me4.dll','file'))
					copyfile('./x64_R2016/sc2_cl_me4.dll','./');
				end
			end
			
			if(~exist('./sc2_cl_nat.dll','file'))
				if(exist('./x64_R2016/sc2_cl_nat.dll','file'))
					copyfile('./x64_R2016/sc2_cl_nat.dll','./');
				end
			end
			if(~exist('./sc2_cl_mtx.dll','file'))
				if(exist('./x64_R2016/sc2_cl_mtx.dll','file'))
					copyfile('./x64_R2016/sc2_cl_mtx.dll','./');
				end
			end
			if(~exist('./sc2_clhs.dll','file'))
				if(exist('./x64_R2016/sc2_clhs.dll','file'))
					copyfile('./x64_R2016/sc2_clhs.dll','./');
				end
			end
		
		else
			error('This platform is not supported.');
		end
	
	end
    
    %check if adaptor is already registered and unregister if necessary
    if (isempty(adaptors)== 0)
        for i= 1:length(adaptors)
            if(isempty(strfind(adaptors(i), 'PCOCameraAdaptor.dll')) == 0)
                imaqregister(char(adaptors(i)), 'unregister');
                warning('An adaptor with the same name was already registered. This adaptor is unregistered now.');
                break;
            end
        end
    end
    
    %Register adaptor
    path = [pwd '\PCOCameraAdaptor.dll'];
    imaqregister(path, 'register');
    
    
elseif (strcmp(reg,'unregister'))
    if isempty(adaptors)
        warning('No adaptors registered. There is nothing to unregister.');
    else
        %check if adaptor is registered at all, if so do unregister
        for i= 1:length(adaptors)
            if(isempty(strfind(adaptors(i), 'PCOCameraAdaptor.dll')) == 0)
                imaqregister(char(adaptors(i)), 'unregister');
                break;
            elseif (i==length(adaptors))
                warning('PCOCameraAdaptor was not found. There is nothing to unregister.');
            end
        end
    end
    
else
    warning('Wrong input string. Use register or unregister as valid inputs.');
end

end