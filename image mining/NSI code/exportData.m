function [data,labels,time] = exportData(varargin)
% this function is exporting the neuronal activation data (data), the
% labels of the identified neurons (labels), and a time vector (time).
% Input arguments are provided by selecting the processingPkg.mat file
% using an UI prompt. This also function also allows exporting a struct
% that contains all the data and legacy data for displaying the neuronal
% geometry by adding the agrument 'savePO'. 

    interP = false;
    savePO = false;
    for i = 1:numel(varargin)
        if strcmp('interpolate',varargin{i})
            interP = true; %enables interpolation
            finalFrameRate = varargin{i+1}; %this specifies the final frame rate the data will be interpolated to. 
            finalDuration = varargin{i+2}; %this specifies the duration in seconds of the entire recording
        end
        if strcmp('savePO',varargin{i})
            savePO =true; 
        end
    end
    [fileObject,FileName] = selectFileName('*.mat');
    load(fileObject);
    
    %find duplicates and their indices
    [UniqueC,~,k] = unique(labels);
    
    [N,bins] = histc(k,1:numel(UniqueC));
    [loc] = find(N>1);
    %loc = bins(loc);
    %disp(labels);
 
    
    if ~isempty(loc)
        specialNrns = 0;
        orgData = 0;
        extraIdx = [];
        switchOff = 0;
    
        object = struct();
        relScaling = [1, 1, scaling(1)/scaling(3)];
        displayType = 'isoSurf'
        displayMode = 'displaySpheres';
        opMode = 'apriori'; %obsolete... remove that...............
        [searchData,lightHandle] = displayNeurons(labels,displayMode,displayType,relScaling,filtMatrix{1},'postHoc',object,nan);
       
       for i=1:length(loc)
           xLocs = strmatch(UniqueC(loc(i)),labels);
           for j=1:length(xLocs)
                iPrompt = ['Please input the new label for ',labels{xLocs(j)},'>>'];
                str = input(iPrompt);
                labels{xLocs(j)} = str; 
                profileObject.originalLabels{xLocs(j),1} = str;
                profileObject.originalLabels{xLocs(j),2} = str;
           end
       end
    end
     
    [matrix] = selectIntensityProfile(intensityMatrix,readType);
    % here smaller read-out radii can be selected----------------------
    str = input('Do you want to choose a different radius?(n/y)>>','s');
    if strcmp('y',str) || strcmp('z',str)
        [matrix] = selectReadManual(matrix,intensityMatrix,labels);
    end
    
    profileObject.multipleY = matrix; 
    matrix = proformaNorm(matrix,2);
    profileObject.multipleYDataCorr = matrix; 
    assignin('base',profileName,profileObject);
    profileObject.backUpLabels = profileObject.originalLabels;
    profileObject.backUpData = intensityMatrix;
    profileObject.nuclearTag = intensityMatrix(:,:,8);
    profileObject.backUpnuclearTag = intensityMatrix(:,:,8);
       
    if savePO 
        assignin('base',profileName,profileObject);
    end

    profileObject.YDataCorr = profileObject.multipleYDataCorr(1,:);
    profileObject.YData = profileObject.multipleY(1,:);
    profileObject.movementVector = repmat(nan,1,length(profileObject.multipleYDataCorr(1,:)));
    profileObject.namefield = profileName;  
    profileObject.aquisitionFrameRate = frameRate;
    profileObject.neuron = 'multiple';
    str = input('please enter remarks here!>>','s');
    if isfield(profileObject,'remark');
            profileObject.remark = [profileObject.remark,str];
    else
       profileObject.remark = str;
    end
    if interP == 1
         fields = {'YData';'YDataCorr';'movementVector';...
              'multipleY';'multipleYDataCorr'};
         finalDuration = roundn(size(profileObject.multipleYDataCorr,2)*interval,1);
         profileObject = interpolateFields( profileObject,fields,finalFrameRate,finalDuration);
            
          profileObject.frameRate = finalFrameRate;
      
    end
    if savePO 
       assignin('base',profileName,profileObject);
    end
    time = profileObject.time;
    data = profileObject.multipleYDataCorr;
    labels = profileObject.labels;
end

function [fileObect,FileName] = selectFileName(extension);
    [FileName,PathName,FilterIndex] = uigetfile(extension);
    fileObect = [PathName,FileName];
end


function [matrix] = selectIntensityProfile(intensityProfile,readType)
    
    figure(),
    subplot(2,2,1),imagesc(intensityProfile(:,:,1));
    %t = text(1,5,'1) - varied read');
    title('1) modified read');
    subplot(2,2,2),imagesc(intensityProfile(:,:,7));
    %t = text(1,5,'2) - original read');
    title('2) orignial read');
    subplot(2,2,3),imagesc(intensityProfile(:,:,1)./intensityProfile(:,:,8));
    %t = text(1,5,'3) - varied read/nuclear exp');
    title('3) Modified read out/nuclear tag exp.');
    subplot(2,2,4),imagesc(intensityProfile(:,:,2)./intensityProfile(:,:,8));
    %t = text(1,5,'4) - original read/nuclear exp');
    title('4) orignial read/nuclear tag exp.');
    fig = gcf; 
    fig.Position = [100 100 1000 1000];
    numb = input(['Your original choice is matrix ' ,num2str(readType), '? Please confirm the choice!>>']);
    
    switch numb
        case 1
            matrix = intensityProfile(:,:,1);
        case 2
            matrix = intensityProfile(:,:,7);
        case 3
            matrix = intensityProfile(:,:,1)./intensityProfile(:,:,8);
        case 4
            matrix = intensityProfile(:,:,7)./intensityProfile(:,:,8);
        otherwise
            matrix = intensityProfile(:,:,readType);
    end
    
end

function [matrix] = selectReadManual(masterMatrix,intensityMatrix,labels)
        
        figure(),
        hold on;
        numLines = size(masterMatrix,1);
        numSam = 6;
        if numLines < numSam
            numSam = numLines;
        end
            
        lines = datasample([1:numLines],6,'Replace',false);
        for i=1:numSam
            subplot(3,2,i),
            hold on
            plot(intensityMatrix(lines(i),:,1),'r');
            plot(intensityMatrix(lines(i),:,2),'g');
            plot(intensityMatrix(lines(i),:,3),'b');
            plot(intensityMatrix(lines(i),:,4),'c');
            plot(intensityMatrix(lines(i),:,5),'m');
            plot(intensityMatrix(lines(i),:,6),'k');
            if i==numSam
                legend('(1) full radius','(2) 90% radius','(3) 70% radius','(4) 50% radius',...
                '(5) 30% radius','(6) 10% radius');
            end
            hold off
            
        end
        fig = gcf; 
        fig.Position= [100 100 600 900];
        vecNum = input('please select the correct read-out radius? >>');
        matrix = intensityMatrix(:,:,vecNum);
        str = input('Do you want to normalize by nuclear expression? (y/n)>>', 's');
        if strcmp(str,'y') || strcmp(str,'z')
           matrix = matrix./intensityMatrix(:,:,8);
        end
        
end

function [] = plotPrem(matrix,labels)
    figure(6666),
    imagesc(matrix);
    numCol = length(matrix(:,1));
    set(gca, 'YTick',[1:1:numCol],'YTickLabel',labels);
end

 

function [searchData,lightHandle,f] = displayNeurons(labels,displayMode,displayType,scaling,ellipseData,opMode,profileObject,fig)
    cMass = cell2mat(ellipseData(:,[10:12]));
    x = cMass(:,1);
    y = cMass(:,2);
    z = cMass(:,3);
    f = fig;
    if ~ishandle(fig)
        f = figure();
    end
    PixSS = get(0,'screenSize');
    width = PixSS(3);
    height = PixSS(4);
    set(gcf,'Units','Pixel','Position',[0,round(height*0.08),width,round(height*0.90)]);
    hold on 
    searchData = {};
    tHandler  = cell(length(cMass(:,1)),1);
    %this done only for the first t-frame:
    for i=1:1:length(cMass(:,1))
              
       %scatter3(x(i),y(i),z(i),'o','r');
                    
       parameters = ellipseData(i,:);
       parameters = cell2mat(parameters(13:18));
       R = randsample('ymcrgb',1);

       [eX,eY,eZ] = ellipsoid(x(i),y(i),z(i),parameters(1),parameters(2),parameters(3),40);
       handle = surf(eX,eY,eZ);
       rotate(handle,[1 0 0],radtodeg(parameters(4)),[x(i),y(i),z(i)]);
       rotate(handle,[0 1 0],radtodeg(parameters(5)),[x(i),y(i),z(i)]);
       rotate(handle,[0 0 1],radtodeg(parameters(6 )),[x(i),y(i),z(i)]);
       
           
       handle.FaceAlpha = 0.6;
       str = labels{i};
       t = text(x(i),y(i),z(i),str,'FontSize',14);
       tHandler{i} = t;
   
        handle.LineStyle = 'none';
        line = {[x(i),y(i),z(i)],handle};
        searchData = vertcat(searchData,line);
    end
    %hold off
    searchData = horzcat(searchData,tHandler);
    rotate3d on;
    lightHandle = light('Position',[-1 0 0],'Style','local');
    daspect(scaling);
    
end

function [] = deleteallhandles(handleList)
    
    for i=1:size(handleList)
        delete(handleList{i,3});
        delete(handleList{i,2});
    end

end

function mat = proformaNorm(mat,mode)
    for i=1:size(mat)
        if mode ==1
           mat(i,:) = quaNorm(mat(i,:));
        elseif mode == 2
           mat(i,:) = quaNorm2(mat(i,:));
        elseif mode == 3    
           mat(i,:) = meanSDNorm(mat(i,:));
        end
    end
end

function line = quaNorm(line)
    nandx = isnan(line);
    sLine = smooth(line);
    sLine(nandx) = NaN;
    q5 = quantile(sLine,0.03);
    line = (line-q5)/(max(line)-q5);
end

function line = quaNorm2(line)
    nandx = isnan(line);
    sLine = smooth(line);
    sLine(nandx) = NaN;
    q5 = quantile(sLine,0.03);
    line = line/q5;
end

function line = meanSDNorm(line)
    line = (line-nanmean(line))/nanstd(line);
end
