function [resMats] = showStats(tracks,labels,conds,sttngs)
    refPoints = [0,0;0, -3.5]; %hardcoded
    % calculate statsistics -----------------------------------------------
    resMats = cell(numel(conds),2);

    for i=1:numel(conds)
        [paths,pLabels] = fetchData(tracks,labels,'.',conds{i},'.');
        [tMat,rMat] = doStats(paths,pLabels,sttngs.interval,refPoints);
        [tMat] = filterMat(tMat,sttngs,16,8,[5,3,4]);
        [rMat] = filterMat(rMat,sttngs,5,NaN,[4,2,3]);
        resMats{i,1} = tMat;
        resMats{i,2} = rMat;
    end
    % plot results---------------------------------------------------------
    colors = makeColors(conds);  
    lineGraphs(resMats(:,1),2,sttngs,colors,'errorEstim');
    title('local Angles');
    ylim([60 125]);
    xlim([1 6]);
    hold on
        ax = gca;
        YL = ax.YLim;
        ax.YLim = YL; 
        h = plot([1.25 1.25],YL,'--','Color',[0 0 0.5]);
        uistack(h,'bottom');
        h = plot([3.5 3.5],YL,'--','Color',[0 0 0.7]);
        uistack(h,'bottom');
    hold off
    lineGraphs(resMats(:,1),8,sttngs,colors);
    title('velocity');
    ylim([0 0.04]);
    xlim([1 6])
    hold on
        ax = gca;
        YL = ax.YLim;
        ax.YLim = YL; 
        h = plot([1.25 1.25],YL,'--','Color',[0 0 0.5]);
        uistack(h,'bottom');
        h = plot([3.5 3.5],YL,'--','Color',[0 0 0.7]);
        uistack(h,'bottom');
    hold off
    lineGraphsReversal(resMats(:,2),1,sttngs,colors);
    title('reversals');
    xlim([1 6]);
    ylim([0 30]);
    hold on
        ax = gca;
        YL = ax.YLim;
        ax.YLim = YL; 
        h = plot([1.25 1.25],YL,'--','Color',[0 0 0.5]);
        uistack(h,'bottom');
        h = plot([3.5 3.5],YL,'--','Color',[0 0 0.7]);
        uistack(h,'bottom');
    hold off
     
end

function [mat] = filterMat(mat,sttngs,tCol,velCol,locs)
    idx = mat(:,tCol) > sttngs.minTime & mat(:,tCol) < sttngs.maxTime;
    mat = mat(idx,:);
    %this should get rid of all the jumping tracks.. max worm speed is 0.08
    if ~isnan(velCol)
        idx = mat(:,velCol) > 0 & mat(:,velCol) < 0.09;
        mat = mat(idx,:);
    end
    %spacial filtering
    mat = isinsector(mat,sttngs.sector,sttngs.minDist,sttngs.maxDist,locs);
end

function [colors] = makeColors(conds)
    %legacy conds
    condsN1 = {'LT_appetitive_mock';
                'LT_appetitive_trained';
                'LT_aversive_mock';
                'LT_aversive_trained';
                'ST_appetitive_mock';
                'ST_appetitive_trained';
                'ST_aversive_mock';
                'ST_aversive_trained';
                'naive';
                'NAIVEM1';
                'NAIVEM3';
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
        'NAIVEM1';
        'NAIVEM3';
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
            0.333333333333333,0.600000000000000,1;
            0.333333333333333,0.600000000000000,1;
            0.5686    0.4353    0.4353;
            0   17/255  215/255];

        colors = nan(numel(conds),3);
        for i=1:numel(conds)
            [~,loc] = ismember(conds{i},condsN);
            colors(i,:) = colorsX(loc,:);
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

        colors = nan(numel(conds),3);
        for i=1:numel(conds)
            [~,loc] = ismember(conds{i},condsN);
            colors(i,:) = colorsX(loc,:);
        end
    end
end

function [matOut]  = isinsector(matIn,angLim,dMin,dMax,locs)
    showDat = false;

    dist = matIn(:,locs(1));
    xRel = matIn(:,locs(2));
    yRel = matIn(:,locs(3));

    %get the angle 

    vecs = [xRel,yRel];
    % get a new center...
    vecs = vecs - repmat([0,2],size(vecs,1),1);

    homeV = repmat([0,-2],size(vecs,1),1);
    
    angs = nan(size(matIn,1),1);
    for i=1:size(matIn,1)
        CosTheta = dot(homeV(i,:),vecs(i,:))/(norm(homeV(i,:))*norm(vecs(i,:)));
        angs(i) = acosd(CosTheta); 
    end
    idx = dist > dMin & dist < dMax &  angs > -angLim & angs < angLim & ...
        yRel < -0.3;
    
    matOut = matIn(idx,:);
    if showDat 
        figure(),
        h = scatter(matIn(:,3),matIn(:,4),'.','MarkerEdgeColor',[0.9 0 0]);
        h.MarkerEdgeAlpha = 0.01;
        hold on
        
        h = scatter(matOut(:,3),matOut(:,4),'.','MarkerEdgeColor',[0 0.9 0]);
        h.MarkerEdgeAlpha = 0.01;
            scatter(0,0,100,'+','MarkerEdgeColor',[0 0 0],'LineWidth',3);
            
        sx = unique(matIn(:,10));
        sy = unique(matIn(:,11));
        ex = unique(matIn(:,12));
        ey = unique(matIn(:,13));
        if numel(sx) < numel(ex)
            sx = repmat(sx(1),size(ex));
            sy = repmat(sy(1),size(ey));
        end
        for i=1:numel(ex)
           vx =  sx(i)-ex(i); 
           vy =  sy(i)-ey(i);
           quiver(ex(i),ey(i),vx,vy,0,'LineWidth',3,'color','k');
        end
        ax = gca;
        addScalebar(3,-8,3,ax);
        hold off
        
        xR = ax.XLim;
        yR = ax.YLim;
        pbaspect([xR/xR,yR/xR,1]);
        ax.XAxis.Visible = 'off';
        ax.YAxis.Visible = 'off';
    end

end


 