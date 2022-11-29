function [template,labels,filtMatrix,cMass,cPixel,distMat,ellipsParam1f,proformaInt] = compileReadingTemp(dataMatrix,scaling,radiusPercent,varargin)
    %transforms output from Toyoshima algorithm into radius and rotation notation
    %required for display of neuronal geometries. 
    %his is overly complicated, replace by better code 
    inputMat = 0;
    removeNeurons = 0;
    removeIdx = 0;
    relScaling = scaling/scaling(1);
    for i=1:1:length(varargin)
        if strcmp('inputMat',varargin{i})
            inputMat = 1;
            filtMatrix = varargin{i+1} ;
        end
        if strcmp('removeNeurons',varargin{i})
            removeNeurons = 1;
            removeIdx = varargin{i+1} ;
        end
    end
    if inputMat == 0
        
        [filtMatrix] = filterC(dataMatrix,radiusPercent,removeNeurons,removeIdx);
        
    end
    labels = cell2mat(filtMatrix{1}(:,3));
    labels = cellstr(char(labels));
    template = horzcat(labels,num2cell(repmat(1,length(labels),1)),...
        repmat({'noElong'},length(labels),1),....
        num2cell(repmat(1,length(labels),1)));
    
    [cMass,cPixel,distMat,ellipsParam1f,proformaInt] = centermass(filtMatrix,scaling);
  
end

function [filtMatrixOut] = filterC(data,radiusPercent,removeNeurons,removeIdx)
    lines = numel(cell2mat(data(:,3)));
    maxFrames = max(cell2mat(data(:,4)));
    listOfNeurons = isCheckedFF(data);
    filtMatrix = cell(maxFrames,1);
    
    for i=1:1:lines
        line = data(i,:);
        [ ~,elD ] = mvg2Ellipse( cell2mat(line(13:18)),cell2mat(line(10:12)),radiusPercent );
        %because I'm too stupid for proper indexing and too lazy to look it
        %up:
        line{13} = elD.radii(1);
        line{14} = elD.radii(2);
        line{15} = elD.radii(3);
        line{16} = elD.eulAngles(1);
        line{17} = elD.eulAngles(2);
        line{18} = elD.eulAngles(3);
        neuronNumber = str2num(line{3});
        frameNumber = line{4};
        if  ismember(neuronNumber,listOfNeurons);
            if ~isempty(filtMatrix{frameNumber,:})
                filtMatrix{frameNumber} = vertcat(filtMatrix{frameNumber,:},line);
            end
            
            if isempty(filtMatrix{frameNumber,:})
                
                filtMatrix{frameNumber} = line;
            end
            
            
        end
        
    end
    cleanMatrix = {};
    for i=1:1:maxFrames
        
        if ~isempty(filtMatrix{i,:})
            cleanMatrix = vertcat(cleanMatrix,{filtMatrix{i}});
        end    
    end
    if removeNeurons == 1
    filtMatrixOut = {};
        for i=1:length(cleanMatrix)
            frameI = cleanMatrix{i};
            frameI(removeIdx,:) = [];
            filtMatrixOut = vertcat(filtMatrixOut,frameI);
        end
    end
    if removeNeurons == 0
        filtMatrixOut = cleanMatrix;
    end
end

function [listOfNeurons] = isCheckedFF(data)
    listOfNeurons = [];
    for i=1:1:numel(cell2mat(data(:,3)));
        line = data(i,:);
        if  line{1} ~= 0
            listOfNeurons = [listOfNeurons; str2num(line{3})];
        end
    end
end
function [cMass,cPixel,distMat,ellipsParam1f,proformaInt] = centermass(filtData,scaling)
    cPixel = {};
    cMass = {};
    distMat = [];
    ellipsParam1f = [];
    proformaInt = repmat(nan,size(filtData{1},1),length(filtData));
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
            %ellipsParam1f(:,1) = ellipsParam1f(:,1)*scaling(1);
            %ellipsParam1f(:,4) = ellipsParam1f(:,4)*scaling(2);
            %ellipsParam1f(:,6) = ellipsParam1f(:,6)*scaling(3);
        end
        proformaInt(:,i) = cell2mat(item(:,22));
        
    end
    distMat2 = distMat2/i;
    stDistM = std(distMat(:,:,:), [], 3);
    distMat(:,:,1) = distMat2;
    distMat(:,:,2) = stDistM;
    
    intMeans = repmat(nanmean(proformaInt,2),1,size(filtData,1)); 
    proformaInt = proformaInt./intMeans;
end