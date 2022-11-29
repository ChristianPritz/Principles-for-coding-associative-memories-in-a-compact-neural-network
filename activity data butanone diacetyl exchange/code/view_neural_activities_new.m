% Using createOverlay mean and single neuron activities can be viewed 
% load data_figure_4_and_5.mat into the workspace
    allConditions = {'STAVT','STAVM','STAPT','STAPM','NAIVE'};

% These overlays can be produced by executing createOverlay funciton
% createOverlay input arguments:
%    data: data matrix
%    labels: label matrix
%    nrn:   name of the neuron that should be plotted, i.e. 'AWA'
%    STEP: 'ON' diacetyl-to-butanone switch. 
%          'OFF' butanone-to-diacetyl switch.  
%   
%   conditions: an cell array of strings listing the desired conditions i.e.:
%       {'NAIVE','STAVT','STAVM'}
%   frameRate: the frame rate of the dataset - it varies, see examples.  

% Sensory neurons:  one neurons alone......................................
    frameRate = 2;
    conds = {'STAVT','STAPT','NAIVE'};
    n = createOverlay(data_sen2,labels_sen2,'AWCON','OFF',...
        conds,frameRate);
    
% Sensory neurons:  one neurons alone......................................
    frameRate = 2;
    conds = {'STAVT','STAPT'};
    n = createOverlay(data_sen2,labels_sen2,'AWA','OFF',...
        conds,frameRate,'YL',[1 1.4]); %define YL 
    
% command neurons without levamisole:  display individual traces..........
    %WITHOUT levamisole
    frameRate = 3;
    conds = {'STAPT','STAVT','NAIVE'};
    n = createOverlay(data_int2,labels_int2,'AVA','ON',...
        conds,frameRate,'YL',[1 2.5],'showHm');

% interneurons: AIYnr .....................................................
    frameRate = 3;
    conds = {'STAVT','NAIVE','STAVM'};
    n = createOverlay(data_int2,labels_int2,'AIYnr','ON',...
    conds,frameRate,'YL',[1,1.4]);
    
    
% interneurons: RIAnrS - note that data is the time-derivative of the
% activity
    frameRate = 3;
    conds = {'STAPT','STAVT','NAIVE'};
    n = createOverlay(data_int2,labels_int2,'RIAnrS','OFF',...
    conds,frameRate);
    close(); 
    ylabel('Calcium net flux');
    xlim([-10 10]); 

% Search data within the single
% fetchData retrieves the activities and labels from the neurons specified
% by the search terms: 
%   STEP: 'ON' or 'OFF'
%   NRN:  neuron name
%   CONDITION: condition as a string, i.e. 'STAVT' 

    [qData,qLabels] = fetchData(data_sen2,labels_sen2,'OFF','AWCON','NAIVE');

% note that wildcard letters (REGEX) can be used in the search terms i. e.:
% '.' will be a permissive wild card returning any entry
% this returns  AWCON, OFF-step activities for all conditions 

    [qData,qLabels] = fetchData(data_sen2,labels_sen2,'OFF','AWCON','.');

%Visualizing the butanone timecourse alone.................................
% ON-step (interneurons):
    figure(); 
    plot(time_int2,butanone_int_onStep2,'LineWidth',2);ylim([-.1 1.2]);
    ax=gca; ax.LineWidth = 2;
    ax.Box = 'off';
    ylabel('Butanone presence');
    xlabel('Time (s)');

% Off-step (interneurons):
    figure(); 
    plot(time_int2,butanone_int_offStep2,'LineWidth',2);ylim([-.1 1.2]);
    ax=gca; ax.LineWidth = 2;
    ax.Box = 'off';
    ylabel('Butanone presence');
    xlabel('Time (s)');

    