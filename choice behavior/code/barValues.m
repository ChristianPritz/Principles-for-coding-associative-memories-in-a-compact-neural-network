function handle = barValues( data,labels,yRange,spacing,varargin )
%redundant     
    barOn = true;
    green = [95 211 95]/255;
    blue = [55 113 200]/255;
    gray = [111 124 145]/255;
    
    colors = [gray;blue;green;];
    colors = vertcat(colors,rand(100,3));
    scatterShow = true;
    barWidthOverride = false;
    useMedian = false;
    for i=1:numel(varargin)
        if strcmp(varargin{i},'showLink')
           showLink = true; 
        end
        if strcmp(varargin{i},'boxOff')
           boxOn = false; 
        end
        if strcmp(varargin{i},'barWidth')
           barWidthOverride = true;
           bw = varargin{i+1};
        end
        
        if strcmp(varargin{i},'rgb')
            red = [239 153 144]/255;
            green = [95 211 95]/255;
            blue = [55 113 200]/255; 
            colors = [green;red;blue];
            colors = vertcat(colors,rand(100,3));
        end
        if strcmp(varargin{i},'grays')
            colors = [.8,.8 .8;
                      .65, .65, .65;
                      .4, .4, .4];
            colors = vertcat(colors,rand(100,3));
        end
        
        if strcmp(varargin{i},'colors')
           colors = varargin{i+1};
        end
        if strcmp(varargin{i},'customColor')
           colors = varargin{i+1};
        end
        
        if strcmp(varargin{i},'noScatter')
           scatterShow = false; 
        end
        if strcmp(varargin{i},'useMedian')
           useMedian = true;
        end
    end

    handle = figure();
    
    
    hold on
    xT = [];
    xM = [];
    yT = [];
    yM = [];
    
    %values
    

    hold on
    
    if scatterShow
        for i=1:size(data,2)


            ydat = data(:,i);
            ydat(isnan(ydat)) = [];
            [xVals,yVals] = sortInHist(ydat,i,spacing);
             cutOff = 0.05;
   
             xVals = xVals + cutOff;

            if i == 3
                xT = xVals;
                yT = yVals;
            elseif i == 2
                xM = xVals;
                yM = yVals;
            end

            sz = repmat(100,1,numel(yVals));
            h = scatter(xVals,yVals,sz);
            h.MarkerEdgeColor = 'k';
            h.MarkerFaceColor = colors(i,:);
        end
       barWidth = 0.5;
       if barWidthOverride 
        barWidth = bw;
       end
       xStart = 0.3;
    else
       barWidth = 0.74;
       if barWidthOverride 
        barWidth = bw;
       end
       xStart = 0;
       xEnd = 0.6;
    end
     
    
        if useMedian 
            iMean = nanmedian(data,1);
        else
            iMean = nanmean(data,1);
        end
        iStd = nanstd(data,1);
        n = sum(~isnan(data),1);
        iSEM = iStd./sqrt(n);
        if barOn
           
           xp = [0.7:1:size(data,2)];
           for i=1:size(data,2)
            mj = bar(xp(i),iMean(i));
            mj.BarWidth = barWidth;
            mj.LineWidth = 5;
            mj.FaceColor = colors(i,:);
           end
           
           mk = errorbar(xp,iMean,iSEM);
           mk.LineStyle = 'none';
           mk.LineWidth = 5;
           mk.Color = 'k';
        end
    %format the crap out of the plot 
    hold off
    fig = gcf;
    ax = gca;   
    ax.FontSize = 28;
    ax.LineWidth = 6;
    ax.FontWeight = 'Bold';
    ax.XTick = xp;
    ax.TickDir = 'out';
    ax.XTickLabels = {};
    ax.TickDir = 'out';
    pbaspect([1,1,1]);
    ylim(yRange);
    xlim([xStart size(data,2)+0.4]);
end

function [x,y] = sortTheMessOut(xT,yT,xM,yM,data)
    x = [];
    y = [];
    for i=1:size(data,1)
       
        [~,locT] = ismember(data(i,3),yT);
        [~,locM] = ismember(data(i,2),yM);
        if locT > 0 
            x(1,i) = xT(locT);
            y(1,i) = yT(locT);
        end 
        if locM > 0 
            x(2,i) = xM(locM);

            y(2,i) = yM(locM);
        end
    end


end

function [xVals,yVals] = sortInHist(data,num,spacing)
    if ~isempty(data)
        base = num;
        h = figure(),[a] = histogram(data,numel(data*2));
        edg = a.BinEdges;
        a = a.Values;
        xVals = [];
        yVals = [];
        nL = (a-1)/(max(a)-1)*spacing;
        nL(isnan(nL)) = 0;
        nL(isinf(nL)) = 1;
        uL = abs(nL-spacing/2); 
        for i = 1:numel(a)

            if a(i) > 0
                if mean([edg(i),edg(i+1)]) < nanmean(data)
                    add2 = [0:a(i)-1];
                    inc = nL(i)/a(i);
                    rawVals = base-(mean(add2*inc)-spacing/2)+add2*inc;
                    if i == 1
                        [~,idx] = sort(data(data>=edg(i)& data<=edg(i+1)),'ascend');
                    else 
                        [~,idx] = sort(data(data>edg(i)& data<=edg(i+1)),'ascend');
                    end
                    xVals = [xVals,rawVals(idx)];


                    %idx = data(data>=edg(i)& data<edg(i+1));
                    if i == 1
                        yVals = [yVals,data(data>=edg(i)& data<=edg(i+1))'];
                    else
                        yVals = [yVals,data(data>edg(i)& data<=edg(i+1))'];
                    end
                else 
                   add2 = [0:a(i)-1];
                    inc = nL(i)/a(i);
                    rawVals = base-(mean(add2*inc)-spacing/2)+add2*inc;
                    if i == 1
                        [~,idx] = sort(data(data>=edg(i)& data<=edg(i+1)),'descend');
                    else 
                        [~,idx] = sort(data(data>edg(i)& data<=edg(i+1)),'descend');
                    end
                    xVals = [xVals,rawVals(idx)];

                    %idx = data(data>=edg(i)& data<edg(i+1));
                    if i == 1
                        yVals = [yVals,data(data>=edg(i)& data<=edg(i+1))'];
                    else 
                        yVals = [yVals,data(data>edg(i)& data<=edg(i+1))'];
                    end
                end
            end
        end
        close(h.Number);
    else
        xVals = nan;
        yVals = nan;
    end
    checksum = sum(ismember(yVals,data))
    if checksum ~= numel(data)
       error('sorting error in the scatter plot!'); 
    end
end


