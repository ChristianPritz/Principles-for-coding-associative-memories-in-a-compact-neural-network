function [ h ] = showTemplates(objectList )
%DISPLAYONSURFACE Summary of this function goes here
    specialNrns = 0;
    orgData = 0;
    extraIdx = [];
    switchOff = 0;
    %for i=1:length(varargin)

    %end
    object = objectList{1};
    scaling = object.backgroundData.scaling;
    relScaling = [1, 1, scaling(1)/scaling(3)];
    displayType = 'isoSurf'
    displayMode = 'displaySpheres';
    opMode = 'apriori'; %obsolete... remove that...............
    labels = object.backUpLabels(:,2);

    [searchData,lightHandle,fig] = displayNeurons(labels,displayMode,displayType,relScaling,object.backgroundData.changedFiltMatrix{1},'postHoc',object,nan);
    thandle = title(object.namefield,'FontSize',20);
   
    %while cycling == true
        pause(1);   
    %end
    theList = {};
    for i=1:size(objectList)
        theList = vertcat(theList,objectList{i}.namefield)
    end
    selSet = uicontrol('Style', 'popup',...
           'String', theList,...
           'Position', [45 30 80 20],...
           'Callback', @selectSet); 
    function selectSet(source,event)
       val = source.Value;
       object = objectList{val};
       deleteallhandles(searchData);
       labels = object.backUpLabels(:,2);
       [searchData,lightHandle,fig] = displayNeurons(labels,displayMode,displayType,relScaling,object.backgroundData.changedFiltMatrix{1},'postHoc',object,fig);
       thandle = title(object.namefield,'FontSize',20);
    end
    
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
    assignin('base','searchData',searchData);
    
    
end

function [] = deleteallhandles(handleList)
    
    for i=1:size(handleList)
        delete(handleList{i,3});
        delete(handleList{i,2});
    end

end