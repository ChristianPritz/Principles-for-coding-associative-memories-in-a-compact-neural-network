% Using createOverlay mean and single neuron activities can be viewed 
allConditions = {'LTAPT','LTAPM','LTAVT','LTAVM','STAVT','STAVM','STAPT','STAPM','NAIVE'};

% These overlays can be produced by executing createOverlay funciton
% createOverlay input arguments:
%    data: data matrix
%    labels: label matrix
%    nrn:   name of the neuron that should be plotted, i.e. 'AWA'
%    STEP: 'ON' or 'OFF' for butanone presentation or butanone removal, 
%          respectively.
%   conditions: an cell array of strings listing the desired conditions i.e.:
%       {'NAIVE','STAVT','STAVM'}
%   frameRate: the frame rate of the dataset - it varies, see examples.  

% Sensory neurons:  one neurons alone......................................
    frameRate = 2;
    conds = {'STAVT','STAPT','NAIVE'};
    n = createOverlay(data_sen,labels_sen,'AWCON','OFF',...
        conds,frameRate);
    
% Sensory neurons:  one neurons alone......................................
    frameRate = 2;
    conds = {'LTAPT','STAPT'};
    n = createOverlay(data_sen,labels_sen,'AWCON','OFF',...
        conds,frameRate,'YL',[0.95 1.5]); %define YL............................ 
    
% Interneurons neurons:  display individual traces.........................
% note that the interneuron data has a frame rate of 5 Hz and a duration of
% -15 to 15 second 
    frameRate = 5;
    conds = {'LTAVT','STAVT'};
    n = createOverlay(data_int,labels_int,'AIAnr','ON',...
        conds,frameRate,'showHm','dispInterval',[15,15],'offSet',15'); 

% Note that the synchronous signal in RIAnrD and RIAnrV neurite parts
% (RIAnrS) is the time derivative of the neural activity: 
   frameRate = 5;
    conds = {'NAIVE','STAPT'};
    n = createOverlay(data_int,labels_int,'RIAnrS','OFF',...
        conds,frameRate,'dispInterval',[15,15],'offSet',15');
    close(); 
    ylabel('Calcium net flux'); 
    xlim([-10 10]); 
    
% Search data for specific neurons, conditions and steps: 
% fetchData retrieves the activities and labels from the neurons specified
% by the search terms: 
%   STEP: 'ON' or 'OFF'
%   NRN:  neuron name
%   CONDITION: condition as a string, i.e. 'NAIVE' 
    [qData,qLabels] = fetchData(data_sen,labels_sen,'OFF','AWCON','NAIVE');

% note that wildcard letters (REGEX) can be used in the search terms i. e.:
% '.' will be a permissive wild card returning any entry
% this returns  AWCON, OFF-step activities for all conditions 
    [qData,qLabels] = fetchData(data_sen,labels_sen,'OFF','AWCON','.');

%Visualizing the stimulus alone............................................
% ON-step (interneurons):
    figure(); 
    plot(time_int,butanone_int_onStep,'LineWidth',2);ylim([-.1 1.2]);
    ax=gca; ax.LineWidth = 2;
    ax.Box = 'off';
    ylabel('Butanone presence');
    xlabel('Time (s)');

% Off-step (interneurons):
    figure(); 
    plot(time_int,butanone_int_offStep,'LineWidth',2);ylim([-.1 1.2]);
    ax=gca; ax.LineWidth = 2;
    ax.Box = 'off';
    ylabel('Butanone presence');
    xlabel('Time (s)');

    