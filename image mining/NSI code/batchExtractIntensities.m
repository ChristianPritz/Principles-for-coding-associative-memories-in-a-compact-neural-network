function [] = batchExtractIntensities(workDir)
%this script re-reads intensities from tiff files. This function reads the
%proccessingPkg.mat file in the directory and within all subdirectory 
%specified by 'workDir'. Multiple folders can be process sequentially.
%Hence 'batchExtractInensities. 

rawList = indexWPs(workDir);

for i=1:length(rawList)
    % load and define variables--------------------------------------------
    load(rawList{i});
    
    %processed = 1; % debug aid
    [x,y,z] = fileparts(rawList{i});
    cd(x);
    if processed == 0;
        %Read-out----------------------------------------------------------
        %	Multiread,indexEllipse
        if noRead == 0 && offFacing == 0
            % DEBUG! Eyal.
            [ intensityMatrix,standardDist,cMass,ellipsParam,CPixel] = multireadNEW2( ...
                imageStack,filtMatrix,template,scaling,labels,debugM);
            
            
        end
        if noRead == 1
            [ intensityMatrix,standardDist,cMass,ellipsParam,CPixel] = multireadNEW2(...
                imageStack, filtMatrix,template,scaling,labels,'noRead',debugM);
        end
        if offFacing == 1 && noRead == 0
            [ intensityMatrix,standardDist,cMass,ellipsParam,CPixel] = multireadNEW2( ...
                imageStack,filtMatrix,template,scaling,labels,debugM,'offFacing',offNrns);
        end
        close all;
        % save the output into the according file....
        processed = 1;
        
        %Modified by Eyal: Moved the parfor the
        save(rawList{i},'intensityMatrix','standardDist','cMass','ellipsParam',...
           'CPixel','-append');
        

    end
    cd(workDir); % probably not necessary... just an overnight voodoo...
end

end



function [workPackages] = indexWPs(parentDir)
%imports and lists all the mat files
% This code uses Eyal Itskovits magnificent FileLister...

files = {};
fileLists = {};
dirList = FileLister(parentDir,'*\.');
workPackages = {};

for i=1:length(dirList.allFiles)
    nameOfFile =  dirList.allFiles(i,:).name;
    [x,y,z] = fileparts(nameOfFile);
    if strcmp(y,'processingPkg')
        workPackages = vertcat(workPackages,nameOfFile);
    end
    
end
cd(parentDir);
end