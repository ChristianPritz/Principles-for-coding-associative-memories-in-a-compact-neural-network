function [means,errors,mean_p_scaling,err_p_scaling] = retransform(pcData,coeffs,batches,nrns,intervals,labels,origLabels,method,components,R,scaleX,varargin)
    %this function takes the associated loads and the PC scores from principal components 
    % and recalculates the input data. By selecting only a subset of
    % principal components variance is omitted from the reconstructed
    % data
    % Then activity deltas of individual neurons are summed and averaged
    % the resulting values are then scaled by the amplitudes of then
    % neurons to better reflect the hierarchy between the neurons by taking their
    % reaction amplitudes into consideration
    % then these scaled means are plotted together with stdevs of the individual
    % reapeats. 

    scaleByAMP = false; 
    
    for i=1:numel(varargin)
        if strcmp(varargin{i},'scaleByAMP')
            scaleByAMP = true;
            AMPs = varargin{i+1};
        end
    end
    % re-calculating the from the PC scores and loads based upon selected
    % principal components (components)
    backMat = pcData(:,components)*coeffs(:,components)';
   
    %undoing the normalization (Retransform into neuronal activity space).............
    backMat = unZnorm(backMat,nrns,intervals,R);

    %from these reconstructed data now extract individual neurons:    
    backDeltas = repmat(nan,4,size(nrns,2));    
    backSTDs = backDeltas;
    b = batches(:,1)';
    batches = batches(:,2)';
    a = cellfun(@numel,intervals);
    lens = cumsum(a);
    
    butCol = [0 0 128]/255;
    daCol = [145 111 125]/255;
    
    a = [1;lens(1:end-1)+1];
    horS = repmat(a',numel(batches),1);
    horE = repmat(lens',numel(batches),1);
    
    
    
    verS = repmat(b',1,numel(lens));
    verE = repmat(batches',1,numel(lens));
    
    
    % each animal underwent 6 but/da exchanges the average activity delta
    % is used an estimator for change the stdev between those trials 
    % is used as an estimator of uncertainty. Here means and stdev are
    % calculated for each neuron in each memory component (batches)
    for i=1:numel(batches)
        for j=1:numel(lens)
            m = backMat([verS(i,j):verE(i,j)],[horS(i,j):horE(i,j)]);
            [mx,ms] = metrics(m);
            backDeltas(i,j) = mx;
            backSTDs(i,j) = ms;
            backSEMs(i,j) = ms/sqrt(size(m,1)); 

        end
    end
    %exporting the the back transformed deltas and errors for later filtering....
    means = backDeltas;
    errors = backSTDs;
    %scaling the deltas by reaction amplitudes........................................... 
    if scaleByAMP
        scaling = ((AMPs-min(AMPs))./((max(AMPs)-min(AMPs))*2)+0.5)*scaleX;
        scaleMat = repmat(scaling,size(backDeltas,1),1); 
        backDeltas = backDeltas.*scaleMat; 
        backSTDs = backSTDs.*scaleMat;
        backSEMs = backSEMs.*scaleMat;
    else 
        backDeltas = backDeltas * scaleX;
        backSTDs = backSTDs * scaleX;
        backSEMs = backSEMs * scaleX;
    end 


%Plotting the arrows and associated error fields...........................
%
%..........................................................................

    bIdcs = 1:2:size(backDeltas,2);
    dIdcs = 2:2:size(backDeltas,2);
    butMat = backDeltas(:,bIdcs);
    daMat = backDeltas(:,dIdcs);
    
    butMatErr = backSTDs(:,bIdcs);
    daMatErr = backSTDs(:,dIdcs);
    
    yMat = repmat([1:5:5*size(backDeltas,1)]',1,size(butMat,2));
    xMat = repmat(1:size(butMat,2),size(backDeltas,1),1);
    zerMat = zeros(size(butMat));
  
    figure(), 
    hold on 
    
    displayError(xMat-.1,yMat,butMat,butMatErr,butCol);
    h1 = quiver(xMat-.1,yMat,zerMat,butMat,0,'LineWidth',3);
    h1.Color = butCol; 
    h1.MaxHeadSize = 0.05;
    displayError(xMat+.1,yMat,daMat,daMatErr,daCol);
    h2 = quiver(xMat+0.1,yMat,zerMat,daMat,0,'LineWidth',3);
    h2.Color = daCol; 
    h2.MaxHeadSize = 0.05;
    for i=1:numel(labels) 
       plot([0.5,size(butMat,2)+.3],[yMat(i,1),yMat(i,1)],'color',[0 0 0]); 
       text(0,yMat(i,1),labels{i},'FontSize',20,'FontWeight','bold');
    end
    for i=1:2:size(butMat,2)
       x = [i-0.5, i+0.5, i+0.5, i-0.5];
       y = [-4 -4 size(backDeltas,1)*5 size(backDeltas,1)*5];
       hp = patch(x,y,[0.95 .95 .95],'LineStyle','none');
       uistack(hp,'bottom'); 
    end
    
    hold off
    ax = gca;
    ax.YAxis.Visible = 'off';
    labels = nrns(2,1:2:size(nrns,2));
    ax.XTick = 1:size(butMat,2);
    ax.XTickLabel = labels;
    ax.FontSize = 16; 
    ax.FontWeight = 'bold';
    ax.XTickLabelRotation = 90;
    ylim([-1 size(backDeltas,1)*5]);
    ax.TickLength = [0 0];
    fig = gcf; 
    fig.Position = [6         595        2458         743];
    mean_p_scaling = backDeltas;
    err_p_scaling = backSTDs;

end

function showmap(im,labels)
    imagesc(im); 
    colormap(jet);
    ax = gca;
    ax.XTick = [];
    ax = gca; 
    ax.XTick = [];
    ax.YTick = 1:36;
    ax.YTickLabel = labels;
    ax.FontWeight = 'bold';
end
function displayError(xMat,yMat,meanMat,errMat,color)
    f = 0.09;
    d = 0.13;
    for i=1:numel(xMat)
       x = [xMat(i)-f,xMat(i),xMat(i)+f];
       x = [x,fliplr(x)];
       if meanMat(i) > 0 
           y = [ meanMat(i) + errMat(i)-d, meanMat(i) + errMat(i), meanMat(i) + errMat(i)-d,...
               meanMat(i) - errMat(i)-d, meanMat(i) - errMat(i), meanMat(i) - errMat(i)-d]  + yMat(i);
       else
           y = [ meanMat(i) - errMat(i)+d, meanMat(i) - errMat(i), meanMat(i) - errMat(i)+d,...
               meanMat(i) + errMat(i)+d, meanMat(i) + errMat(i), meanMat(i) + errMat(i)+d]  + yMat(i);
       end
       p = patch(x,y,color); 
       p.LineStyle = 'None';
       p.FaceAlpha = 0.2;
    end
end


function showVector(vec,val,pos,color)
    figure(),
    hold on 
    plot(vec,'LineWidth',2); 
    h = quiver(pos,0,0,val,0,'LineWidth',3);
    h.Color = color; 
    h.MaxHeadSize = 0.5;
    ax = gca; 
    ax.YTick = [-3:.5:3];
    ax.XTick = [];
    ax.LineWidth = 3; 
    ax.FontSize = 18;
    ax.FontWeight = 'bold';
    ax.XAxis.Visible = 'off';
    fig = gcf;
    fig.Position = [500 500 500 500];
     
end

function showArea(vec,color)
    figure(),
    y = [vec,zeros(size(vec))];
    t = 1:numel(vec); 
    x = [t,fliplr(t)];
    
    hold on 
    p = patch(x,y,color); 
    p.LineStyle = 'none'; 
    p.FaceAlpha = 0.5; 
    plot(vec,'LineWidth',3); 
    h.MaxHeadSize = 0.5;
    ax = gca; 
    ax.YTick = [-3:.5:3];
    ax.XTick = [];
    ax.LineWidth = 3; 
    ax.FontSize = 18;
    ax.FontWeight = 'bold';
    ax.XAxis.Visible = 'off';
    fig = gcf;
    fig.Position = [500 500 500 500];
    hold off ;  
end

function [mx,ms] = metrics(m)
    
    s = nansum(m,2);%/size(m,2);
    %s = max(m,[],2);
    mx = nanmean(s); 
    ms = nanstd(s); 
    
end

