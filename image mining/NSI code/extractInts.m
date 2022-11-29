function [intensityMap] = extractInts(stack,data,scaling,kernelSize,template,labels,varargin)
     
    diagnostic = 0;
    outFace = 0;
    averageBckg = NaN;
    outFaceSetBack = 0;
    outFaceTemp = nan;
    bckgSub = 0;
    
    for i=1:length(varargin)
        if strcmp(varargin{i},'debug')
            diagnostic = 1;
        
        end
        if strcmp(varargin{i},'offFacing')
            outFace = 1;
            outFaceSetBack = 1;
            outFaceTemp = varargin{i+1};
        end
        if strcmp(varargin{i},'bckgSub')
            bckgSub  = 1;
            averageBckg = findbkg(stack,0.001); % call the right function here this is just place holder
        end
        
    end
    bckgSub  = 0;
    % define all the variable stems....
     % centerMasses 
       centerMass = cell2mat(data(:,[10:12]));
     % ellipse parameters
       ellipseSizes = cell2mat(data(:,[13:15]));
       ellipseRotations = cell2mat(data(:,[16:18]));
     % cut out all the chunks? 
     % precache  the intesity map variables
    numElip = size(data,1);
    intensityV = repmat(nan,numElip,1);
    intensityV09 = repmat(nan,numElip,1);
    intensityV07 = repmat(nan,numElip,1);
    intensityV05 = repmat(nan,numElip,1);
    intensityV03 = repmat(nan,numElip,1);
    intensityV01 = repmat(nan,numElip,1);
    % measure average background pixel intensity 
    
    for i=1:size(data,1)
        offFacing = 0;
        % chunk out the dataChunk------------------------------------------
         
        origin = centerMass(i,:);
        [dataCube,newRelativeCenterMass] = subSliceStack(stack,origin,scaling,...
            kernelSize);
        cSize = dataCube;
        if numel(dataCube) == 0
         intensityV(i) = nan; 
         intensityV09(i) = nan;
         intensityV07(i) = nan;
         intensityV05(i) = nan;
         intensityV03(i) = nan;
         intensityV01(i) = nan;
        else  
            % check if the ellipse is a half-read case-------------------------
            if outFace == 1; 
                [yn,loc] = ismember(labels{i},outFaceTemp(:,2));
                % IF required: make half-read cube-----------------------------
                if yn == 1
                    donor = outFaceTemp{loc,1};
                    [tf,loc] = ismember(donor,labels);
                    donorOri = centerMass(loc,:);
                    % get new coordinates of centerMass for the donor neuron
                    delta = origin - newRelativeCenterMass;
                    donorOri = donorOri - delta;
                    halfCube = painthalfcube(size(dataCube),newRelativeCenterMass,...
                        donorOri);
                    dataCube = dataCube.*halfCube;
                end
            end


         % make thresholding cube of varying diameters-------------------------
         sSize = size(dataCube);
         inOutCube = meshellipse(sSize,newRelativeCenterMass,ellipseSizes(i,:),...
             ellipseRotations(i,:));
         inOutCube09 = meshellipse(sSize,newRelativeCenterMass,ellipseSizes(i,:)*0.9,...
             ellipseRotations(i,:));
         inOutCube07 = meshellipse(sSize,newRelativeCenterMass,ellipseSizes(i,:)*0.7,...
             ellipseRotations(i,:));
         inOutCube05 = meshellipse(sSize,newRelativeCenterMass,ellipseSizes(i,:)*0.5,...
             ellipseRotations(i,:));
         inOutCube03 = meshellipse(sSize,newRelativeCenterMass,ellipseSizes(i,:)*0.3,...
             ellipseRotations(i,:));
         inOutCube01 = meshellipse(sSize,newRelativeCenterMass,ellipseSizes(i,:)*0.1,...
             ellipseRotations(i,:));
       
     % extract intensities: multiply the cubes-----------------------------
        res = inOutCube.*cast(dataCube,'double');
        intensityV(i) = mean(res(:)); 
        res09 = inOutCube09.*cast(dataCube,'double');
        intensityV09(i) = mean(res09(:));
        res07 = inOutCube07.*cast(dataCube,'double');
        intensityV07(i) = mean(res07(:));
        res05 = inOutCube05.*cast(dataCube,'double');
        intensityV05(i) = mean(res05(:));
        res03 = inOutCube03.*cast(dataCube,'double');
        intensityV03(i) = mean(res03(:));
        res01 = inOutCube01.*cast(dataCube,'double');
        intensityV01(i) = mean(res01(:));
      %background subtraction----------------------------------------------
           if bckgSub == 1
            
                intensityV(i) = intensityV(i)-averageBckg; 
                intensityV09(i) = intensityV09(i)-averageBckg; %this prevents another matrix multiplication
                intensityV07(i) = intensityV07(i)-averageBckg;
                intensityV05(i) = intensityV05(i)-averageBckg;
                intensityV03(i) = intensityV03(i)-averageBckg;
                intensityV01(i) = intensityV01(i)-averageBckg;
            
           end
        end
    end
    intensityMap = horzcat(intensityV,intensityV09,intensityV07,...
        intensityV05,intensityV03,intensityV01);
end

function [subStack,newRelativeCenterMass] = subSliceStack(stack,origin,scaling,kernelSize,varargin)
    % ATTENTION kernelSize and origin are in microMeter (real-world-units)
    % newRelativeCenterMass is in pixel index for the convenience of
    % indexing
    
    % origin is in pixels... 
    
    mode=1;
    
    for i=1:1:length(varargin);
        if strcmp(varargin{i},'micrometer')
            mode = 2;
        end
    end 
    
    xo = origin(1);
    yo = origin(2);
    zo = origin(3);

    if mode == 1
        xUp = round(xo) - round((kernelSize/scaling(1))/2);
        xDown = round(xo) + round((kernelSize/scaling(1))/2);
        yUp = round(yo) - round((kernelSize/scaling(2))/2);
        yDown = round(yo) + round((kernelSize/scaling(2))/2);
        zUp = round(zo) - round((kernelSize/scaling(3))/2);
        zDown = round(zo) + round((kernelSize/scaling(3))/2);

        
        newOrigin = [xUp,yUp,zUp]-[1,1,1]; %in old pixel coordinates
        if (zUp <= 0) 
            newOrigin(3) = 0;
        end
        if (yUp <= 0) 
            newOrigin(2) = 0;
        end
        if (xUp <= 0) 
            newOrigin(1) = 0;
        end
        
        
        newRelativeCenterMass = [(xo),(yo),(zo)]-newOrigin;
      end
    
    if mode == 2
        xUp = round(xo/scaling(1)) - round((kernelSize/scaling(1))/2);
        xDown = round(xo/scaling(1)) + round((kernelSize/scaling(1))/2);
        yUp = round(yo/scaling(2)) - round((kernelSize/scaling(2))/2);
        yDown = round(yo/scaling(2)) + round((kernelSize/scaling(2))/2);
        zUp = round(zo/scaling(3)) - round((kernelSize/scaling(3))/2);
        zDown = round(zo/scaling(3)) + round((kernelSize/scaling(3))/2);
        newOrigin = [xUp,yUp,zUp]-[1,1,1]; %in old pixel coordinates
        if (zUp <= 0) 
            newOrigin(3) = 0;
        end
        if (yUp <= 0) 
            newOrigin(2) = 0;
        end
        if (xUp <= 0) 
            newOrigin(1) = 0;
        end
        newRelativeCenterMass = [(xo/scaling(1)),(yo/scaling(2)),(zo/scaling(3))]-newOrigin;
    end
    
    %This part corrects the new center mass when limits are out-of-bounds limits (
    % having negative indices -1)

    
    
    [ arraysOut ] = inboundries3D( size(stack),[xUp:xDown],[yUp:yDown],[zUp:zDown] );
    %in Matlab indexing x and y
    if size(arraysOut,1) == 3
        subStack = stack(arraysOut{2},arraysOut{1},arraysOut{3});
    else 
        subStack = [];
    end
end