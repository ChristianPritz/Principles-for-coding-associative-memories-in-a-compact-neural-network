function [ intensityMatrix,standardDist,cMass,ellipsParam1f,cPixel] = multireadNew( stack, filtMatrix,template,scaling,labels,varargin )
%This function re-reads the intensities as specified by user-input. 

    warning('off');
    noRead = 0;
    debugM = 'nodebug';
    offFacing = 0;
    
    for i=1:length(varargin)
        if strcmp('noRead',varargin{i})%deprecated feature
            noRead = 1;
        end
        if strcmp('debug',varargin{i})%deprecated feature
            debugM = 'debug';
        end
        if strcmp(varargin{i}, 'offFacing')
            offFacing = 1;
            offNrns = varargin{i+1};
        end
    end
   
% filtering the candidates

% retrieve the center mass objects
    [cMass,cPixel,standardDist,ellipsParam1f] = centermass(filtMatrix,scaling);
    % OPTIONAL intensity correction

    intensityMatrix = [];
    disp('--------------------------------------------------------------');
    disp(['Re-reading ',stack]);
% intensity read
    if offFacing == 0
        [intensityMatrix] = readIntArray(filtMatrix,stack,cMass,scaling,template,noRead,labels,debugM);
    end
    if offFacing == 1
        [intensityMatrix] = readIntArray(filtMatrix,stack,cMass,scaling,template,noRead,labels,debugM,'offFacing',offNrns);
    end
    warning('on');
end



function [cMass,cPixel,distMat,ellipsParam1f] = centermass(filtData,scaling)
    cPixel = {};
    cMass = {};
    distMat = [];
    ellipsParam1f = [];
    for i=1:1:length(filtData)
        item = filtData{i};
        subMat = cell2mat(item(:,[10,11,12]));
        lines = size(subMat,1);
        scalingMatrix = [];
        for j=1:lines
            scalingMatrix = [scalingMatrix;scaling];
        end
        mass = subMat.*scalingMatrix;
        cPixel = vertcat(cPixel,{subMat});
        cMass = vertcat(cMass,{mass});
        D = pdist(cMass{i});
        D2 = squareform(D);
        D2 = D2/max(D2(:));
        distMat(:,:,i) = D2;
        if i == 1
           distMat2 = D2;
        end
        if i > 1
            distMat2 = distMat2+ D2;
        end
        
        if i == 1
            ellipsParam1f = cell2mat(item(:,[13,14,15,16,17,18]));
            ellipsParam1f(:,1) = ellipsParam1f(:,1)*scaling(1);
            ellipsParam1f(:,4) = ellipsParam1f(:,4)*scaling(2);
            ellipsParam1f(:,6) = ellipsParam1f(:,6)*scaling(3);
        end
        
        
    end
    distMat2 = distMat2/i;
    stDistM = std(distMat(:,:,:), [], 3);
    distMat(:,:,1) = distMat2;
    distMat(:,:,2) = stDistM;
end

function [intensityMatrix] = readIntArray(data,stack,centerMass,scaling,template,noRead,labels,debugM,varargin)
    offFacing = 0;
    offNrns = {};
    for i=1:length(varargin)
        if strcmp(varargin{i}, 'offFacing')
            offFacing = 1;
            offNrns = varargin{i+1};
        end
    end
%retrieving the maximum number of frames
    maxFrames = numel(data);
    intensityMatrix =[];
% going through the stacks frame-by-frame using streamstack 
%   
    currentIteration = 0;
    intensityMatrix = [];
    intensityMatrix09 = [];
    intensityMatrix07 = [];
    intensityMatrix05 = [];
    intensityMatrix03 = [];
    intensityMatrix01 = [];
    ch_I_intMat = repmat(nan,size(centerMass{1},1),maxFrames);
    ch_II_intMat = repmat(nan,size(centerMass{1},1),maxFrames);
   
    parfor_progress(maxFrames);
    %disp(maxFrames);
    %% Dumm
    tic;
    
    for i=1:maxFrames %iterating frame by frame
        pause(0.01);
        
        
        %loading the nuclei coordinates and the stack for each time point
        if noRead == 0    
            %if strcmp(gpuStat,'gpuArray')
                %[ partStack ] = streamstack( stack,i,stackSize,1,1,'read','gpuArray' );
            %end
            %if strcmp(gpuStat,'noGpu')
                %[ partStack ] = streamstack( stack,i,stackSize,1,1,'read' );
            %end
            % use of toyoshimas getImageMiji and MIJI%
            [partStack] = getImageMiji([cd,'\',stack],[],[1],[i]);%
            partStack = permute(partStack,[2,1,3]);
            % allocating a vector holds all the intensities for 
            %reading the values from the ROI and averaging them 
            if offFacing == 0
                %[intenstiyMap] = indexellipseNEW2(partStack,data{i},scaling,8,template,labels,debugM);
                [intenstiyMap] = extractInts(partStack,data{i},scaling,8,template,labels,debugM,'bckgSub');
            end
            if offFacing == 1
                %[intenstiyMap] = indexellipseNEW2(partStack,data{i},scaling,8,template,labels,debugM,'offFacing',offNrns);
                [intenstiyMap] = extractInts(partStack,data{i},scaling,8,template,labels,debugM,'offFacing',offNrns,'bckgSub');
            end    
            %write the Roi in the intensity vector
            intensityMatrix = [intensityMatrix,intenstiyMap(:,1)];
            intensityMatrix09 = [intensityMatrix09,intenstiyMap(:,2)];
            intensityMatrix07 = [intensityMatrix07,intenstiyMap(:,3)];
            intensityMatrix05 = [intensityMatrix05,intenstiyMap(:,4)];
            intensityMatrix03 = [intensityMatrix03,intenstiyMap(:,5)];
            intensityMatrix01 = [intensityMatrix01,intenstiyMap(:,6)];
        end
            if size(data{i},2) >= 22;
                ch_I_intMat(:,i) = cell2mat(data{i}(:,22));
            end
            if size(data{i},2) == 23;
                ch_II_intMat(:,i) = cell2mat(data{i}(:,23));
            end
        parfor_progress; % Count 
       
    end
    toc;
    parfor_progress(0); % Clean up
    
    intensityMatrix(:,:,1) = intensityMatrix;
    intensityMatrix(:,:,2) = intensityMatrix09;
    intensityMatrix(:,:,3) = intensityMatrix07;
    intensityMatrix(:,:,4) = intensityMatrix05;
    intensityMatrix(:,:,5) = intensityMatrix03;
    intensityMatrix(:,:,6) = intensityMatrix01;

    

    if noRead == 1
        intensityMatrix = [];
        intensityMatrix(:,:,1) = repmat(nan,size(ch_I_intMat));
        intensityMatrix(:,:,2) = repmat(nan,size(ch_I_intMat));
        intensityMatrix(:,:,3) = repmat(nan,size(ch_I_intMat));
        intensityMatrix(:,:,4) = repmat(nan,size(ch_I_intMat));
        intensityMatrix(:,:,5) = repmat(nan,size(ch_I_intMat));
        intensityMatrix(:,:,6) = repmat(nan,size(ch_I_intMat));
    end 


    intensityMatrix(:,:,7) = ch_I_intMat;
    intensityMatrix(:,:,8) = ch_II_intMat;
 end

%deprecated function don't use!
function [ arrayOfPixels,intensityAverage ] = sphereIndexin( stack,coordinate,radius )
% coordinate is an array with 3 elements
% radius is a scalar in pixels
    

% calculation of the sphere
    arrayOfPixels = [];
    arrayOfIntensity = [];
    for i=1:1:numel(stack);
        [x,y,z] = ind2sub(size(stack),i);
        distance = sqrt((x-coordinate(1))^2+(y-coordinate(2))^2+(z-coordinate(3))^2);
        if distance <= radius
            arrayOfPixels = [arrayOfPixels,i];
            arrayOfIntensity = [arrayOfIntensity,stack(i)];
        end
    end
    intensityAverage = mean(arrayOfIntensity);
    
   % slow approach: decide for each pixel if d <= radius
   
% indexing of the pixels 

% 

end