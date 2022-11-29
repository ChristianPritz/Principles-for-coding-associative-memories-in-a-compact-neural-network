function lineGraphsX2(dataCell,idx,settings,colors,varargin)
    
    repeats = false;
    for i = 1:numel(varargin)
       
       if strcmp(varargin{i},'repeats')
           repeats = true;
       end
    end
    
 
    binSize = settings.binSize;
    maxDist = settings.maxDist;
    minDist = settings.minDist;
    bins = [minDist:binSize:maxDist+binSize];
    x = movmean(bins,2);
    x = x([2:end]);
    %[plotData1,plotError1] = getDataError(dataCell,x,idx,bins);

    circ = 0;
    
    if repeats 
        [plotData,plotError,plotStds] = getDataNErrRep(dataCell,x,idx,bins,circ);
    else 
        [plotData,plotError,plotStds] = getDataNErr3(dataCell,x,idx,bins,circ);
    end 
    
    figure(), 
    hold on
    for i=1:numel(plotData)
        data = plotData{i};
        error = plotError{i};
        nanDex = isnan(data);
        data(nanDex) = [];
        error(nanDex) = [];
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
    %sp = ax.YLim;
    xlabel('Distance (cm)','FontSize',22);
    fig = gcf; 
    fig.Position = [100   100   840   504];
    
    
end


function [dataOut,errOut] = getDataNErr(dataCell,x,idx,bins,circ)
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

function [dataOut,errOut,err2Out] = getDataNErr3(dataCell,x,idx,bins,circ)
    if circ == 0 
        dataOut = {};
        errOut = {};
        err2Out = {};
        for i = 1:numel(dataCell)
           data = dataCell{i};

           res = nan(1,size(x,2));
           err = res;

              data(:,4) = discretize(data(:,4),bins);
              data = data(:,[4,idx]);
              %line = nan(size(x));
              distCl = unique(data(:,1));
              for k = 1:numel(distCl)
                  res(k) =  nanmean(data(data(:,1)==distCl(k),2));
                  err(k) =  nanstd(data(data(:,1)==distCl(k),2))/...
                  sqrt(sum(~isnan(data(data(:,1)==distCl(k),2))));
                  err2(k) =  nanstd(data(data(:,1)==distCl(k),2));
              end

           dataOut{i} = res;
           errOut{i} = err;
           err2Out{i} = err2;
        end
        
    else 
        dataOut = {};
        errOut = {};
        err2Out = {};
        for i = 1:numel(dataCell)
           data = dataCell{i};

           res = nan(1,size(x,2));
           err = res;

              data(:,4) = discretize(data(:,4),bins);
              data = data(:,[4,idx]);
              %sline = nan(size(x));
              distCl = unique(data(:,1));
              for k = 1:numel(distCl)
                  res(k) =  circmean(data(data(:,1)==distCl(k),2));
                  err(k) =  circstd(data(data(:,1)==distCl(k),2))/...
                  sqrt(sum(~isnan(data(data(:,1)==distCl(k),2))));
                  err2(k) =  circstd(data(data(:,1)==distCl(k),2));
              end

           dataOut{i} = res;
           errOut{i} = err;
           err2Out{i} = err2;
        end
    end
end
