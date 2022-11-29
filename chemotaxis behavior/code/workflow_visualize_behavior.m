% plate overview..........................................................
    %this visulizes individual tracks on the plates and also provides a
    %normalized a animal density distribution that runs along an axis from
    %the butanone (0) to diacetyl (-7). 
    % visualize single experiments 
    showPlates(tracks,labels,{'.'},{'STAVT'});
    showPlates(tracks,labels,{'.'},{'STAVM'});
    % visualize two experiments in overlay
    showPlates(tracks,labels,{'.','.'},{'STAVT','STAVM'});
      
% draw line graphs for deviation angle, speed, and reversals...............

% the following code requires directional statistics tool box by 
% Philip Berens https://www.mathworks.com/matlabcentral/fileexchange/10676-circular-statistics-toolbox-directional-statistics
% download the toolbox and integrate add to folders or copy into the working directory  

    %analysis parameters. 
    sttngs = struct();
    sttngs.gridSize = 0.2000; %cm 
    sttngs.interval = 24; %frames
    sttngs.binSize = 0.5000; %cm
    sttngs.sector = 35; %degree
    sttngs.minDist = 1; %cm
    sttngs.maxDist = 8; %cm 
    sttngs.minTime = 10; %frames
    sttngs.maxTime = 2160; %frames

    %draw the graphs.......................................................
    showStats(tracks,labels,{'NAIVEM3','STAVM','STAVT'},sttngs);
    showStats(tracks,labels,{'NAIVEM1','STAPM','STAPT'},sttngs);



