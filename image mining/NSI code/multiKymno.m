function [ handle,handlePlot ] = multiKymno( inputObject, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    labels = inputObject.multipleLabels';
    matrix = inputObject.multipleYDataCorr;
    xLabels = 'time (s)';
    labelFont = 12;
    pearsonP = 0;
    sorted = 0;
    stdP = 0;
    figNum = nan; 
    subPlotting = 0;
    parentAxes = 0;
    for i=1:length(varargin)
        if strcmp(varargin{i},'originalLables')
            labels = inputObject.originalLabels';
        end
        if strcmp(varargin{i},'pearson')
            matrix = inputObject.Analytics.pairwiseCorr;
            xLabels = 'neurons';
            labelFont = 10;
            pearsonP = 1;
        end
        if strcmp(varargin{i},'stdP')
            matrix = inputObject.multipleYVar;
            stdP = 1;
        end
        if strcmp(varargin{i},'figNum')
            figNum = varargin{i+1};
        end
        if strcmp(varargin{i},'sorted')
            sorted = 0;
            matrix = inputObject.Analytics.sortedPCorr;
            labels = inputObject.Analytics.sortedLabels;
            xLabels = 'neurons';
            labelFont = 10;
            pearsonP = 1;
        end
        if strcmp(varargin{i},'singleNeurons')
            sorted = 0;
            matrix = inputObject.singleNData;
            labels = inputObject.singleNlabels;
            xLabels = 'neurons';
            labelFont = 12;
    
        end
        if strcmp(varargin{i},'subplot')
            subPlotting = 1;
    
        end
        if strcmp(varargin{i},'ParentAxes')
            parentAxes = 1;
            pAxis = varargin{i+1};
        end
    end
    if subPlotting == 0
        if isnan(figNum)
            handle = figure(),
        end
        if ~isnan(figNum)
            handle = figure(figNum),
        end
    end
    if isfield(inputObject,'stimulusProfile')
        maxI = max(matrix(:));
        minI = min(matrix(:));
        line = inputObject.stimulusProfile;
        line = line*maxI
        [loc] = find(line == 0)
        line(loc) = minI;
        matrix = [line;matrix];
        if size(labels,1) < size(labels,2)
            labels = labels'
        end
        labels = vertcat('stimulus',labels);
    end
    if parentAxes == 1
        handlePlot = imagesc(matrix,'Parent',pAxis);
    else    
        handlePlot = imagesc(matrix);
    end
    handlePlot.HandleVisibility = 'on';
    numCol = length(inputObject.multipleYDataCorr(:,1));
    if isfield(inputObject,'stimulusProfile')
        numCol = numCol + 1
    end
    
    set(gca, 'YTick',[1:1:numCol],'YTickLabel',labels,'fontsize',labelFont);
    
    line = inputObject.multipleYDataCorr(1,:);
    
    
    if pearsonP == 0 
        set(gca, 'XTick',[0:5*inputObject.frameRate:inputObject.time(end)*inputObject.frameRate],'XTickLabel',[0:5:inputObject.time(end)],'fontsize',labelFont);
    end
    if pearsonP == 1 
        set(gca, 'XTick',[1:1:numCol],'XTickLabel',labels,'fontsize',labelFont);
        ax = gca;
        ax.XTickLabelRotation = 90;
    end
    if parentAxes == 0
        pAxis = gca; %previously ax
    end
    xlabel(pAxis, xLabels);
    ylabel(pAxis,'neurons');
    colormap jet;
    colorbar('southoutside');
    handle = gcf;
end
