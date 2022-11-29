function formprocpkg(profileObject)
    labels = profileObject.outputData(:,4);
    interval = 1/profileObject.frameRate;
    profileObject.interval = interval;
    filtMatrix = profileObject.ellipseData;
    if ~isfield(profileObject,'backgroundData')
        data = evalin('base',['data_edited']);
        scaling = evalin('base',['scaling']);
    else
        data = profileObject.backgroundData.data_edited;
        scaling = profileObject.backgroundData.scaling;  
    end
    %legacy variables 2 be removed: 
    frameRate = profileObject.frameRate;
    proformaObject = profileObject;
    readType = 1;
    noRead = 0;
    flowMode = 0; 
    autoFlowMode = 0;
    fileMode = 1;
    
    interpolateP = 0;
    continueP = 0;
    crashLabels = 0;
    crashTemplate = 0;
    crashFilter = 0;
    debugM = 'nodebug';
    offFacing = 0;
    offNrns = '';
    removeNeurons = 0;
    autoName = 0;

    
    
    
    %	Initiate struct and add labels-----------------------------------------
    profileObject.originalLabels = profileObject.outputData(:,[4,5]);
    profileObject.remark = profileObject.comment; %this is redundant remove remark in future... 
    if ~isfield(profileObject,'backgroundData')
        profileObject.backgroundData.data_edited = data;
        profileObject.backgroundData.scaling = scaling;
    end
    profileObject.backgroundData.changedFiltMatrix = profileObject.ellipseData; %redundant with S.ellipseData remove in future;
    profileObject.backgroundData.oldIntensities = profileObject.multipleYDataCorr;
    if offFacing == 1
            profileObject.backgroundData.offSites = offNrns;
    end
    if crashLabels == 1
            profileObject.backgroundData.crashLabels = cLabels;
    end


    processed = 0;
    %legacy var names - 2 removed in future:
    filtMatrix = profileObject.ellipseData;
    imageStack = profileObject.imageStack; %add into S! 
    template = '';
    profileName = profileObject.namefield;
    interpolateP = profileObject.interpolateP; % add into S! 
% save the crap and assign the variables in the Workspace
    
    
    save('processingPkg.mat','filtMatrix','imageStack','template',...
        'scaling','labels','debugM','offFacing','offNrns','flowMode',...
        'autoFlowMode','fileMode','noRead','readType','profileName','interpolateP',...
        'interval','frameRate','profileObject','data',...
        'crashLabels','proformaObject','processed');


end