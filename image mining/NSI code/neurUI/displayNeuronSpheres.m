function [searchData,lightHandle,handleFrame,handleDat] = displayNeuronSpheres(S,frame)
    ellipses = S.ellipseData{frame};
    cMass = cell2mat(ellipses(:,[10:12]));
    x = cMass(:,1);
    y = cMass(:,2);
    z = cMass(:,3);
    handle = figure(665),
    subplot(2,1,1)  
    left = imread('AmphidLeft.jpg');
    imshow(left);
    subplot(2,1,2)  
    right = imread('AmphidRight.jpg');
    imshow(right);
    %f = figure(666);
    PixSS = get(0,'screenSize');
    width = PixSS(3);
    height = PixSS(4);
    set(gcf,'Units','Pixel','Position',[0,round(height*0.08),width,round(height*0.90)]);

       %subplot(2,2,4,'Position',[0.75,0.10,0.23,0.18]);
       handleDat = plot(S.time,S.multipleYDataCorr(1,:),'LineWidth',2,'Parent',S.axes{3});
       xlabel(S.axes{3},'time (s)');
       ylabel(S.axes{3},'neuronal activity a.u.');
            
        %title('Subplot 2: Polynomial')
        

       %subplot(2,2,2,'Position',[0.75,0.35,0.23,0.60]);
       [handleFrame] = showActivities(S,S.axes{2});
       colorbar('off');
    
    %figure();
    %subH = subplot(1,1,[1,3],'Position',[0.05,0.10,0.65,0.85]);
    plot(rand(2,1),'Parent',S.axes{1});
    hold(S.axes{1},'on');
    
    set(S.axes{1},'Position',[0.05,0.10,0.65,0.85]);
     
    searchData = {};
    tHandler  = cell(length(cMass(:,1)),1);
    %this done only for the first t-frame: 
    for i=1:1:length(cMass(:,1))
        
        
       scatter3(x(i),y(i),z(i),'+','r','Parent',S.axes{1});
            
            
       parameters = ellipses(i,:);
       parameters = cell2mat(parameters(13:18));
       R = randsample('ymcrgb',1);
 
       [eX,eY,eZ] = ellipsoid(x(i),y(i),z(i),parameters(1),parameters(2),parameters(3),S.vertexN);
       handle = surf(eX,eY,eZ,'Parent',S.axes{1});
       rotate(handle,[1 0 0],radtodeg(parameters(4)),[x(i),y(i),z(i)]);
       rotate(handle,[0 1 0],radtodeg(parameters(5)),[x(i),y(i),z(i)]);
       rotate(handle,[0 0 1],radtodeg(parameters(6 )),[x(i),y(i),z(i)]);
                  
       handle.FaceAlpha = 0.6;
       str = S.labels{i};
       t = text(x(i),y(i),z(i),str,'Color',[0.913,0.913,0.2118],'FontSize',14,'Parent',S.axes{1});
       tHandler{i} = t;
       
   
        handle.LineStyle = 'none';
        line = {[x(i),y(i),z(i)],handle};
        searchData = vertcat(searchData,line);
        
        
        
        colormap(S.axes{1}, 'cool');
    end
    %hold off
    searchData = horzcat(searchData,tHandler);
    rotate3d on;
    lightHandle = light('Position',[-1 0 0],'Style','local','Parent',S.axes{1});
    relScaling = [1, 1, S.scaling(1)/S.scaling(3)];
    daspect(S.axes{1},relScaling);
    hold off;
    
end

function [h,h2] = showActivities(S,ax)
    [~,h2] = multiKymno(S,'ParentAxes',ax);
    colormap(ax,'jet');
    
    [y,x] = size(S.multipleYDataCorr);
    %ax = gca;
    xDat = [0,x,x,0,0];
    yDat =  [0,0,y+0.5,y+0.5,0];
    hold(ax,'on')
       h = plot(xDat,yDat,'r','LineWidth',2,'Parent',ax);
    hold(ax,'off')
    caxis(ax,[0.8 3.5]);

end
function [h] = redrawFrame(h,h2,line,S)
    h.XData = [0.5,size(S.multipleYDataCorr,2),size(S.multipleYDataCorr,2),0.5,0.5];
    h.YData = [line-0.5,line-0.5,line+0.5,line+0.5,line-0.5];
    h2.YData = S.multipleYDataCorr(line,:);
end

function [outputData] = handleSpheres(outputData,field,value,num)
    if isnan(num)
        num = 1; 
        fin = size(outputData,1); 
    else 
        fin = num;
    end
    
    for i=num:fin
        if isnumeric(value)
            eval(['outputData{',num2str(i),',2}.',field,' = [',int2str(value),'];']);
        else
            eval(['outputData{',num2str(i),',2}.',field,' = ',value,';']);
        end
    end
end