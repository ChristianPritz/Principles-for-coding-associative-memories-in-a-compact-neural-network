function nTab = createOverlay(data,labels,nrn,stepT,conditions,frameRate,varargin)
%This function creates population mean graphs for soma data only
%variables-----------------------------------------------------------------
    nTab = cell(numel(conditions),2);
    if ~iscell(conditions)
        error('Please state conditions as cell array! e.g. {''naive''}');
    end
    showHm = false;
    showSing = false;
    interval = [10,30];
    customColors = false;
    offSet = 30;
    plotInAxes = false;
    YL = false;
    for i=1:numel(varargin)
            if strcmp(varargin{i},'dispInterval')
                interval = varargin{i+1}; %this changes the display range of the figure
            end
            if strcmp(varargin{i},'showHm')
                showHm = true; %this will show heat maps of individual neurons.
                hmh = cell(numel(conditions),1);
            end
            if strcmp(varargin{i},'singleTraces')
                showSing = true; %this will show heat maps of individual neurons. 
                singYL = estYL(data,labels,nrn,stepT);
            end
            if strcmp(varargin{i},'customColors')
                customColors = true; % this allows user defined colors to be used.
                myColors = varargin{i+1}; % use 9x3 color matrix 
      
            end
            if strcmp(varargin{i},'offSet')
                offSet = varargin{i+1}; 
            end
            if strcmp(varargin{i},'plotInAxes')
                plotInAxes = true; 
            end
            if strcmp(varargin{i},'YL')
                YL = true;
                YLim = varargin{i+1};
            end
    end
    XL = interval; 
    XL(1) = XL(1)*-1;
    [colorsX] = makeColors(conditions);
    
%-------------------------------------------------------------------------
    if customColors 
        colorsX = myColors; %high treason 
    end
    % this creates overlay of population mean in one figure................
    if ~plotInAxes
        figure(),
        
    end
    fig = gcf; 
    num = fig.Number;
    
    hold on
    for i=1:numel(conditions)
        figure(num); 
        %extracting data from data matrix for each of the conditions.......
        [dat,labs] = fetchData(data,labels,stepT,nrn,conditions{i});
        %get number of animals involved
        if size(labs,2) > 3
            nTab{i,1} = conditions{i};
            nTab{i,2} = numel(unique(labs(:,4)));
        end
        %formats data for overlay (line graphs and patch)..................
        [x,y,matrix,time,m] = makeOverlay(dat,frameRate,interval,offSet);
        killDx = isnan(y); 
        x(killDx) = [];
        y(killDx) = [];
        
        patch(x,y,[0 0 1],'FaceColor',colorsX(i,:),'FaceAlpha',...
            0.3,'LineStyle','none');
        plot(time,m,'LineWidth', 3, 'color',colorsX(i,:));
        if ~YL
            ax = gca;
            YLim = ax.YLim;
        end
        %exports heat maps if required.....................................
        if showHm 
            makeheatmap(matrix,interval,frameRate,conditions{i},...
                [YLim(1) YLim(2)*1.5]);
            ax = gca;
            hmh{i} = ax;
            sRange = interval(1)*frameRate+1:...
                interval(1)*frameRate+1+interval(2)*frameRate;
            sortFigureMat(ax.Children(2),sRange,'ascend');
            m = ax.Children(2).CData;
        end
        if showSing 
            singleTraces(matrix,labs,interval,frameRate,conditions{i},colorsX(i,:),singYL);
        end
    end
    figure(num);
    hold off
    ax = gca;
    ax.FontSize = 22;
    ax.FontWeight = 'bold';
    ax.LineWidth = 5;
    ax.XTick = XL(1):10:XL(2);
    %ax.YTick = 0:0.2:5;
    ax.XLim = XL;
    
    %YL = ax.YLim;
    if YL
        ax.YLim = YLim;
    else 
        YLim = ax.YLim;
        ax.YLim = YLim;
    end
    if strcmp('OFF',stepT)
        STIM = [XL(1) 0];
    elseif strcmp('ON',stepT)
        STIM = [0 XL(2)];
    end
    x = [STIM(1),STIM(2),STIM(2),STIM(1)];
    y = [YLim(1),YLim(1),YLim(2),YLim(2)];
    h = patch(x,y,[0 0 0],'FaceAlpha',0.1,'LineStyle','none');
    uistack(h,'bottom');
    fig = gcf;
    fig.Position = [100 100 612 694];
    xlabel('Time (sec)');
    ylabel('Neural activation F/F_G');
    makeLegend(colorsX,conditions);
    if ~YL && showHm
        syncCAxis(hmh);
    end
end

function [x,y,data,time,m] = makeOverlay(data,frameRate,interval,offSet)
    % this function calculates the data population mean, std and outputs 
    % vectors for population mean +-SEM, data matrix, a time vector and the
    % population mean 
    data = data(:,offSet*frameRate-interval(1)*frameRate+1:offSet*frameRate+interval(2)*frameRate+1);
     n = sum(~isnan(data),1);
     m = nanmean(data,1);
     if size(data,1) > 1
        dS = nanstd(data,1);
     else
        dS = zeros(size(data));
     end
     sem = dS./sqrt(n);
     time = -interval(1):1/frameRate:interval(2);
     x = [time,fliplr(time)];
     y = [m-sem,fliplr(m+sem)];
end

function [dat,lab,idx] = fetchData(data,labels,stepT,nrn,condition,varargin)
    %this function filters neuronal activation data as specified by 
    % stepT (on or off step), nrn (neuron type), & condition (training
    % state).
     A = regexp(labels(:,3),condition);
     B = regexp(labels(:,2),nrn);
     C = regexp(labels(:,1),stepT);
     if numel(varargin) > 0
        ind = varargin{1};
        D = ismember(labels(:,4),ind); %exact search! 
        idx = ~cellfun(@isempty,A) & ~cellfun(@isempty,B) &....
             ~cellfun(@isempty,C) & D;
     else 
         idx = ~cellfun(@isempty,A) & ~cellfun(@isempty,B) &....
             ~cellfun(@isempty,C);
     end
    dat = data(idx,:);
    lab = labels(idx,:);

end

function makeheatmap(mat,interval,frameRate,name,cRange)
    %cRange =  [0.8 4]; %his is hardcoded. 
    figure(),
    tp = interval(1)*frameRate + 1;
    hold on
        imagesc(mat);
        colormap jet;
        caxis(cRange); 
        plot([tp, tp],[0.5,size(mat,1)+0.5], 'LineWidth',2,'color',[1 1 1]);
    hold off
    ax = gca; 
    ax.Box = 'on';
    ax.YTick = [];
    ax.XLim = [0.5 size(mat,2)+0.5];
    ax.YLim = [0.5 size(mat,1)+0.5];
    fig = gcf;
    fig.Position = [100 100 600 600];
    fig.Name = name;
    ax.LineWidth = 7; 
    ax.XTick = [1,tp,frameRate*interval(2) + frameRate*interval(1)+1];
    ax.XTickLabel = [interval(1)*-1,0,interval(2)];
    ax.FontSize = 20;
    ax.FontWeight = 'bold';
    xlabel('Time (sec)');
    ylabel('Neurons');
    colorbar('southoutside');
    ax.TickDir = 'out';
end


function singleTraces(mat,labels,interval,frameRate,name,colorX,lims)
    % this function draws each Line in mat into separate figure and labels,
    % it with the according label taken from labels; 
   
    interval(1) = interval(1)*-1;
    time = [interval:1/frameRate:interval(2)];
    
    for i = 1:size(mat,1)
        fig = figure();
        tp = interval(1)*frameRate + 1;
        hold on
            if strcmp('ON',labels{i,1})
                x = [0 interval(2) interval(2) 0];
            else 
                x = [interval(1) 0 0 interval(1)];
            end
             y = [lims(1) lims(1) lims(2) lims(2)];
            hp = patch(x,y,[0.5 0.5 0.5],'FaceAlpha',0.3,'LineStyle','none');
            hL = plot(time,mat(i,:),'LineWidth',2.5,'color',colorX); 
        hold off
        ax = gca; 
        ax.Box = 'off';
        ax.XLim = interval();
        ax.YLim = lims;
        fig.Position = [400 100 600 300];
        fig.Name = [name, ' - ', labels{i,2}, '  STIMULUS: ',labels{i,1}];
        ax.LineWidth = 5; 
        ax.FontSize = 20;
        ax.FontWeight = 'bold';
        xlabel('Time (sec)');
        ylabel('Neural activation F/F_G');
        r = (lims(2)-lims(1))/20;
        ht = text(interval(1)+2,lims(2)+r,[labels{i,2},' - ',getNums(labels{i,4})],'FontSize',22,'FontWeight','bold');
        ax.TickDir = 'out';
    end
end


function numstr= getNums(str)
    a = regexp(str,'[0123456789]');
    numstr = str(a); 
end

function singYL = estYL(data,labels,nrn,stepT)
    %this function checks the y-range for single traces
    dat = fetchData(data,labels,stepT,nrn,'.');
    singYL = [min(dat(:)),max(dat(:))];

end

function makeLegend(colors,conds)
 
    fig = figure();
    hold on
    for i = 1:numel(conds)
        b = bar(i,1,'FaceColor',colors(i,:));
        b.BarWidth = 1; 
    end
    hold off
    for i=1:numel(conds)
       a = regexp(conds{i},'_');
       conds{i}(a) = ' ';
    end
    ax = gca; 
    ax.XLim = [0.5 numel(conds)+0.5];
    ax.XTick = 1:numel(conds);
    ax.XTickLabel = conds;
    ax.XTickLabelRotation = 90;
    ax.Box = 'on'; 
    ax.LineWidth = 4; 
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ax.YTick = [];
    fig.Position = [712   250   420   175];
    title('Legend');
    fig.Name = 'Legend';
   
end

function [colors] = makeColors(conds)
    
    condsN1 = {'LT_appetitive_mock';
                'LT_appetitive_trained';
                'LT_aversive_mock';
                'LT_aversive_trained';
                'ST_appetitive_mock';
                'ST_appetitive_trained';
                'ST_aversive_mock';
                'ST_aversive_trained';
                'naive';
                'BUFFER';
                'original'};
            
   condsN = {'LTAPM';
        'LTAPT';
        'LTAVM';
        'LTAVT';
        'STAPM';
        'STAPT';
        'STAVM';
        'STAVT';
        'NAIVE';
        'BUFFER';
        'original'};

    if ismember(conds{1},condsN)
        
    % The King's colours:      
    colorsX = [0.5 0.5 0.5;        
            0.196078431372549,0.517647058823530,0.227450980392157;
            0.5 0.5 0.5;
            0.588235294117647,0,0;
            0.5 0.5 0.5;
            0,0.901960784313726,0;
            0.5 0.5 0.5;
            1,0.501960784313726,0.501960784313726;
            0.333333333333333,0.600000000000000,1;
            0.5686    0.4353    0.4353;
            0   17/255  215/255];

        colors = [];
        for i=1:numel(conds)
            [~,loc] = ismember(conds{i},condsN);
            colors = vertcat(colors,colorsX(loc,:));
        end
    else
        
        colorsX = [0.5 0.5 0.5;        
            0.196078431372549,0.517647058823530,0.227450980392157;
            0.5 0.5 0.5;
            0.588235294117647,0,0;
            0.5 0.5 0.5;
            0,0.901960784313726,0;
            0.5 0.5 0.5;
            1,0.501960784313726,0.501960784313726;
            0.333333333333333,0.600000000000000,1;
            0.5686    0.4353    0.4353;
            0   17/255  215/255];

        colors = [];
        for i=1:numel(conds)
            [~,loc] = ismember(conds{i},condsN1);
            colors = vertcat(colors,colorsX(loc,:));
        end
    end
end


function syncCAxis(h)
    vals = zeros(numel(h),2);
    for i = 1:size(h)
       axes(h{i});
       vals(i,:) = caxis;
    end
    nAx = [min(vals(:,1)),max(vals(:,2))];
    for i = 1:size(h)
       axes(h{i});
       caxis(nAx); 
    end
end

function [handle] = sortFigureMat(axH,int,ascDesc)
    data = axH.CData;
    score2 = nansum(data(:,int),2); %sorting by how much Calcium after the stimulus exchange
    [~,idx] = sort(score2,ascDesc);
    %[idx] = nnsort(data,score2,ascDesc); %sorting by similarity in waveform 
    axH.CData = data(idx,:);
    
end

function [idx] = nnsort(data,score,ascDesc)
    dist = pdist(data);
    dist = squareform(dist);
    [~,idx] = sort(dist(:,1),ascDesc);
end
 
