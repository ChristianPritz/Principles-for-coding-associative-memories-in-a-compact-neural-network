function [] = identifyNrns5(profileName,originalStack,varargin)
%--------------------------------------------------------------------------
%this script allows to display neuronal geometries in 3D for naming and
%and correction. Since the guassian fitting on which these geometries are 
%based on are often not optimal.Neuronal read out geometries can be corr-
%ected. This script creates a 'processingPkg.mat' file in images basefolder
%that is subsequently used to re-read the neuronal activation data. 
%--------------------------------------------------------------------------

%profileName: string specifying name of experiment or animal identifier
%originalStack: filename of the original image 

% definition of variables and input arguments -----------------------------
    readType = 1; %deprecated feature
    noRead = 0; % deprecated feature
    [scaling,data] = selectYToutput();
    data(:,1) = num2cell(repmat(1,size(data,1),1)); %eliminates ticking issues: 
    [a,b,c] = fileparts(originalStack);
    imageStack = [b,'_aligned',c];
    
    [~,info] = getImageMiji([cd,'\',originalStack],false);  %maybe move this into the according function
    stackProp.name = imageStack;  %maybe move this into the according function
    stackProp.size = info.getNSlices;  %maybe move this into the according function    
    props = info.getProperties;
    charProps = char(props);
     
    % this reads the frame 2 frame interal. This feature works only with 
    % Nikkon A1 data. For other data sources us the input argument
    % 'dt' followed by stack 2 stack time interval e.g.: 'dt',0.1
        [f2fInt] = extractInterval(charProps); %estimates the interval between frames
    flowMode = 0; %deprecated feature 
    autoFlowMode = 0; %deprecated feature
    fileMode = 1; %deprecated feature
    vertexN = 0;
    interpolateP = 0; % deprecated feature
    continueP = 0;
    crashLabels = 0;
    crashTemplate = 0;
    crashFilter = 0;
    debugM = 'nodebug'; %deprecated feature
    offFacing = 0; 
    offNrns = '';
    removeNeurons = 0; %deprecated feature
    autoName = 0; 
    reboot = 0; 
    manualDtFlag = false; 
    setColsFlag = false;
    duration = info.getNFrames*info.getNSlices*f2fInt;
    
    for i=1:1:length(varargin)
       if strcmp(varargin{i},'interval') %deprecated feature 
            interval = frameRate;
       end
       if strcmp(varargin{i}, 'flow')
            fileMode = 0;
            flowMode = 1;
            flowDataObj = varargin{i+1};
        end
        if strcmp(varargin{i}, 'autoflow') %deprecated feature
            fileMode = 0;
            autoFlowMode = 1;
        end
        if strcmp(varargin{i}, 'interpolate') %deprecated feature
            interpolateP = 1;
        end

        if strcmp(varargin{i}, 'crashLabels')
            crashLabels = 1;
            cLabels = varargin{i+1};
            
        end
        if strcmp(varargin{i}, 'reboot') %allows to restart identifcation when crashed by adding 'reboot',crashProfile to the arguments
            reboot = 1;
            proformaObject = varargin{i+1};
            
        end
        if strcmp(varargin{i}, 'changedFiltMatrix')
            crashFilter = 1;
            cFilters = varargin{i+1};
            
        end
        if strcmp(varargin{i}, 'crashTemplate')
            crashTemplate = 1;
            cTemplate = varargin{i+1};
            
        end
        if strcmp(varargin{i}, 'debug') %deprecated featrue
            debugM = 'debug';
        end
        if strcmp(varargin{i}, 'offFacing')
            offFacing = 1;
            offNrns = varargin{i+1};
        end
        if strcmp(varargin{i}, 'removeNeurons') %deprecated feature
            removeNeurons = 1;
            remNrnIdx = varargin{i+1};
        end
        
        if strcmp(varargin{i}, 'noRead') % deprecated
            noRead = 1;
        end
        if strcmp(varargin{i}, 'readType') % deprecated
            readType = varargin{i+1};
        end
        if strcmp(varargin{i}, 'dt') %overwrites the interval and frame rate read from the image stack..............
            manualDtFlag = true;
            interval = varargin{i+1};
            frameRate = 1/interval;
            duration = info.getNFrames*interval;
        end
        if strcmp(varargin{i}, 'setCols') %deprecated feature...
            setColsFlag = true;
            colsCellArray = varargin{i+1};
        end
        if strcmp(varargin{i}, 'vertexN') %display tweak
            vertexN = varargin{i+1};
        end
    end
    if noRead == 1  %deprecated feature.
        readType = 2;
    end
  
 %setting frameRate and interval------------------------------------------- 
    frameRate = info.getNFrames/duration;
    interval = 1/frameRate;
    if manualDtFlag == false
          duration = info.getNFrames*info.getNSlices*f2fInt;
          interval = duration/info.getNFrames;
          frameRate = 1/interval;
    end
    
    
% Sort and convert data----------------------------------------------------
%   	Reading template, filtMatrix, mvg2Ellipse
    if removeNeurons == 1
        [template,labels,filtMatrix,cMass,cPixel,distMat,ellipsParam1f,proformaInt] = ...
        compileReadingTemp(data,scaling,1,'removeNeurons',remNrnIdx);
    end
    if removeNeurons == 0
        [template,labels,filtMatrix,cMass,cPixel,distMat,ellipsParam1f,proformaInt] = ...
        compileReadingTemp(data,scaling,1);

    end
        assignin('base','crashTemplate',template);
    if crashLabels == 1
       ancientLabels = labels;
       labels = cLabels;
    end
    if crashFilter == 1
       filtMatrix = cFilters; 
    end
    %showLibrary();
    %this forms a struct that holds all the variables describing the
    %experimental data. This struct is passed onto the neuron identifier UI
    %for visualsation
    if reboot == 0
        %this is a previewObject with intensityReads from the japanese code
        proformaObject.multipleYDataCorr = proformaInt;
        proformaObject.multipleLabels = labels; %redundant resolve with multikymno, remove in future versions
        proformaObject.frameRate = frameRate;
        proformaObject.time = [1/frameRate:1/frameRate:duration];
        proformaObject.imageStack = imageStack;
        proformaObject.interpolateP = interpolateP;
        proformaObject.labels = labels;
        proformaObject.scaling = scaling;
        proformaObject.ellipseData = filtMatrix;
        proformaObject.namefield = profileName;
        proformaObject.naive = 1;
        proformaObject.corrColors = repmat([0.5 0.5 0.5],size(proformaObject.ellipseData{1},1),1);
        proformaObject.backgroundData.data_edited = data;
        proformaObject.backgroundData.scaling = scaling;
        if vertexN > 0
           proformaObject.vertexN = vertexN; 
        end
        if setColsFlag
            proformaObject.currentColors = cell2mat(colsCellArray);
            proformaObject.userColors = cell2mat(colsCellArray);
        else
            proformaObject.currentColors = repmat([0 0.8 0],size(proformaObject.ellipseData{1},1),1); % remove this
            proformaObject.userColors = repmat([0 0.8 0],size(proformaObject.ellipseData{1},1),1);
        end
    end
        
    %manual identificaiton/modification of neurons-------------------------
%    showLibrary();
    IdentifyNrnsFig(proformaObject);
end

function [] = showLibrary();
    %load libraries.... 
    homeP = cd;
    str = which('identifyNeurLRC');
    [x,y,z] = fileparts(str);
    str = [x,'\Training Sets'];
    listing = dir(str);
    theList = {};
    for i=1:length(listing);
        [x,y,z]=fileparts(listing(i).name);
        if strcmp(z,'.mat')
            load([y,z]);
            eval(['theList = vertcat(theList,',y,');']);
        end
    end
    showTemplates(theList);
end

function [interval] = extractInterval(str)

    a = regexp(str,'timestamp #');
    subString = str(a(1):a(3));
    %a = regexp(subString,'timestamp #');
    b = regexp(subString,'[\n]');
    c = regexp(subString,'[=]');
    interval = str2num(subString(c(2)+2:b(2))) -...
        str2num(subString(c(1)+2:b(1)));
end

function [scaling,data_edited] = selectYToutput()
    filename = uigetfile('*.mat','Select the gaussian fitting output mat file');
    d = load(filename,'data_edited');
    s = load(filename,'scaling');
    data_edited = d.data_edited;
    scaling = s.scaling;
end