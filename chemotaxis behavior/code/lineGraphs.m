function  lineGraphs(dataCell,idx,sttngs,colors,varargin)
    repeats = 0;
    frags = true; %for high spatial resolution base of variation is fragments. 
    for i = 1:numel(varargin)
       bins = [1 2.5;2.5 4;4 5.5;5.5 8]; 
       if strcmp(varargin{i},'repeats')
           %repeats = 18;
           frags = false;
           for i = 1:numel(dataCell)
            [dataCell{i}] = groupDataBins(dataCell{i},18,bins);
           end
       end
       if strcmp(varargin{i},'tracks')
           %repeats = 17;
           frags = false
           for i = 1:numel(dataCell)
            [dataCell{i}] = groupDataBins(dataCell{i},18,bins);
           end
       end
    end
    %processing rawData 
    binSize = sttngs.binSize;
    maxDist = sttngs.maxDist;
    minDist = sttngs.minDist;
    bins = [minDist:binSize:maxDist+binSize];
    x = movmean(bins,2);
    x = x([2:end]);
    if idx == 2 
       circ = 1;
    else
        circ = 0;
    end
    if repeats > 0
        [plotData,plotError,plotStd] = getDataNErrRep(dataCell,x,idx,bins,circ,repeats);
    elseif frags 
        [plotData,plotError,plotStd] = getDataNErr2(dataCell,x,idx,bins,circ,sttngs);
    end 
    
    figure(), 
    hold on
    for i=1:numel(plotData)
        data = plotData{i};
        nanDex = isnan(data);
        error = plotError{i};
        error(nanDex) = [];
        data(nanDex) = [];
        cleanX = x;
        cleanX(nanDex) = [];
        plot(cleanX,data,'LineWidth',3,'color',colors(i,:));
        xd = [cleanX,fliplr(cleanX)];
        yd = [data+error,fliplr(data-error)];
        patch(xd,yd,colors(i,:),'FaceAlpha',0.35,'EdgeColor',colors(i,:),'LineStyle','none');
    end
    hold off 
    ax = gca;
    ax.FontWeight = 'bold'; 
    ax.LineWidth = 7;
    ax.FontSize = 28;
    ax.TickDir = 'out'; 
    ax.Position = [0.1300    0.1100    0.7750    0.8150];
    ax.XLim = [minDist,maxDist];
    sp = ax.YLim;
    xlabel('Distance (cm)','FontSize',22);
    fig = gcf; 
    fig.Position = [100   100   840   504];
end


function [dataOut,errOut] = getDataNErr(dataCell,x,idx,bins,circ)
    %2do: change into matrix notation
    if circ == 0
        dataOut = {};
        errOut = {};
        for i = 1:numel(dataCell)
           data = dataCell{i};
           dates = unique(data(:,17));
           res = nan(numel(dates),size(x,2));
           for j = 1:numel(dates)
              jData = data(data(:,17)==dates(j),:);
              jData(:,5) = discretize(jData(:,5),bins);
              jData = jData(:,[5,idx]);
              line = nan(size(x));
              distCl = unique(jData(:,1));
              for k = 1:numel(distCl)
                  kDat = jData(jData(:,1)==distCl(k),2);
                  kDat(isnan(kDat)) = [];
                  line(k) =  nanmean(kDat);
              end
              res(j,:) = line;
           end
           dataOut{i} = nanmean(res,1);
           errOut{i} = nanstd(res,1)./sqrt(sum(~isnan(res),1));
        end
    else 
       dataOut = {};
        errOut = {};
        for i = 1:numel(dataCell)
           data = dataCell{i};
           dates = unique(data(:,17));
           res = nan(numel(dates),size(x,2));
           for j = 1:numel(dates)
              jData = data(data(:,17)==dates(j),:);
              jData(:,5) = discretize(jData(:,5),bins);
              jData = jData(:,[5,idx]);
              line = nan(size(x));
              distCl = unique(jData(:,1));
              for k = 1:numel(distCl)
                  kDat = jData(jData(:,1)==distCl(k),2);
                  kDat(isnan(kDat)) = [];
                  line(k) =  circmean(kDat);
              end
              res(j,:) = line;
           end
           dataOut{i} = circmean(res,1);
           errOut{i} = circstd(res,1)./sqrt(sum(~isnan(res),1));
        end
    end
end

function [dataOut,errOut,errOut2] = getDataNErr2(dataCell,x,idx,bins,circ,sttngs)
    %2do: change into matrix notation
    if circ == 0 
        dataOut = {};
        errOut = {};
        errOut2 = {};
        for i = 1:numel(dataCell)
           data = dataCell{i};
           n = getN(data,17,sttngs);
           res = nan(1,size(x,2));
           err = res;

              data(:,5) = discretize(data(:,5),bins);
              data = data(:,[5,idx]);
              %line = nan(size(x));
              distCl = unique(data(:,1));
              for k = 1:numel(distCl)
                  res(k) =  nanmean(data(data(:,1)==distCl(k),2));
                  err(k) =  nanstd(data(data(:,1)==distCl(k),2));
              end

           dataOut{i} = res;
           errOut{i} = err./sqrt(n);
           errOut2{i} = err;
        end
    else 
        dataOut = {};
        errOut = {};
        errOut2 = {};
        for i = 1:numel(dataCell)
           data = dataCell{i};
           n = getN(data,17,sttngs);
           res = nan(1,size(x,2));
           err = res;

              data(:,5) = discretize(data(:,5),bins);
              data = data(:,[5,idx]);
              line = nan(size(x));
              distCl = unique(data(:,1));
              for k = 1:numel(distCl)
                  res(k) =  circmean(data(data(:,1)==distCl(k),2));
                  err(k) =  circstd(data(data(:,1)==distCl(k),2));
              end
           dataOut{i} = res;
           errOut{i} = err./sqrt(n);
           errOut2{i} = err;
        end
    end
end


function [nOut] = getN(data,groupCol,sttngs)
    
    nOut = [];
    
    binSize = sttngs.binSize;
    maxDist = sttngs.maxDist;
    minDist = sttngs.minDist;
    bins = minDist:binSize:maxDist+binSize;
    for i = 2:numel(bins)
           idx = data(:,5) >= bins(i-1) & data(:,5) < bins(i);
           n = numel(unique(data(idx,groupCol)));
           nOut(i) = n;
    end
    nOut = nOut(2:end);


end

function [res] = circmean(array,varargin)
    if numel(array) == 1 && sum(isnan(array)) == 1
        res = nan;
    elseif ~isempty(array)
        array = deg2rad(array);
        turnBack = false;
        if numel(varargin) > 0
           dim = varargin{1};
           if dim == 2
            turnBack = true;
            array = array';

           end
        end
        [a,b] = size(array);
        if a == 1 || b == 1
            if b > a 
                array = array';
            end
            array(isnan(array)) = [];
        end
        res = circ_mean(array);

        res = rad2deg(res);
        if turnBack == true
           res = res'; 
        end
    else
        res = nan;
    end
    
end

function [res] = circmedian(array,varargin)
    if numel(array) == 1 && sum(isnan(array)) == 1
        res = nan;
    elseif ~isempty(array)
        array = deg2rad(array);
        turnBack = false;
        if numel(varargin) > 0
           dim = varargin{1};
           if dim == 2
            turnBack = true;
            array = array';

           end
        end
        [a,b] = size(array);
        if a == 1 || b == 1
            if b > a 
                array = array';
            end
            array(isnan(array)) = [];
        end
        res = circ_median(array);

        res = rad2deg(res);
        if turnBack == true
           res = res'; 
        end
    else
        res = nan;
    end
    
end

function [res] = circstd(array,varargin)

    if numel(array) == 1 && sum(isnan(array)) == 1
        res = nan;
    elseif ~isempty(array)
        array = deg2rad(array);
        turnBack = false;
        if numel(varargin) > 0
           dim = varargin{1};
           if dim == 2
            turnBack = true;
            array = array';

           end
        end
        [a,b] = size(array);
        if a == 1 || b == 1
            if b > a 
                array = array';
            end
            array(isnan(array)) = [];
        end
        res = circ_std(array);

        res = rad2deg(res);
        if turnBack == true
           res = res'; 
        end
    else
        res = nan;
    end
end