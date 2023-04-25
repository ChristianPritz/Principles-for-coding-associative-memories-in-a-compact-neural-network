%load the data_fig_7.mat into the workspace
load('data_figure_7.mat')

% variables----------------------------------------------------------------
% -------------------------------------------------------------------------
% deltaMat      contains all the neural activity deltas in lines. Each line 
%               is a condition difference consisting of concatinated neural 
%               activity vectors. Labels for lines are stored in deltaLabS
% nrns          labels for the concatenated neural activity labels. 1st
%               line is the  triggering stimulant second line holds the
%               the responding
%               neuron
% ranges        cell array holding the length of the neural activity
%               vectors
% amplitudes    Mean neural activation amplitudes. These amplitudes are
%               used to scale the retransformed neural deltas to reflect 
%               their reaction amplitude.
% deltaLabS     is cell array defining the conditions
%               differences/memory components. These are the Y-labels
%               for deltaMat
% trainedModel  Is a KNN classifier that excludes insignificant activity
%               changes, it was trained on simulated data. 


%visualizing the raw query matrix from supplement-------------------------- 
%certain non-responding neurons and non-memory component conditions are
%excluded (see below)


%deltaMat holds all the activity deltas. Activity deltas are the
%differences between 2 experimental conditions (see deltaLabS col 1 and 2)
%each line consists of concatenated activity vecotrs of all neurons. 

figure(),imagesc(deltaMat);
ax = gca;
ax.YTick = 1:36;
ax.YTickLabel = deltaLabS(:,3);
colormap(jet)


%z-normalizeing (centering) the delta matrix-------------------------------
[norm_matrix,R] = vectorZnorm(deltaMat,nrns,ranges);

% sensory neurons; sensory neurons are the first 24 positions. subslice 
% cuts the sensory neurons out from the centered matrix (Fig 7A):         
[coeff,score,latent,tsquared,explained,mu] = pca(subslice(norm_matrix,...
    [1:24],allInts),'centered',false);
    %Variance explained by the PCs
    figure(), bar(explained);
    ylabel('Variance explained');
    xlabel('Principal components'); 

    % PC scatter plot for all neurons and memory components..
    conditionColors = [...
                0.8314 0.667 0;
                1 .8314 .1647;
                0.3725 .3725 .8275;
                0 0 .5;
                0 1 0;
                1 0 0;
                ];


    fig = figure(); 
    gscatter(score(:,1),score(:,2),deltaLabS(:,3),conditionColors)
    fig.Position = [1153,         462,         795,         754];
    ax = gca;
    for i=1:numel(ax.Children)
        ax.Children(i).MarkerSize = 60;
    end
    ax.LineWidth = 6;
    ax.FontSize = 28; 

    ax.FontWeight = 'bold';
    ax.TickDir = 'out';
    xlabel('PC 1'); 
    ylabel('PC 2');


%PCA on sensory neurons + interneurons (Fig 7B and C) ---------------------
%--------------------------------------------------------------------------
[coeff,score,latent,tsquared,explained,mu] = pca(norm_matrix,'centered',...
    false);


    %Variance explained by the PCs.........................................
    figure(), bar(explained);
    ylabel('Variance explained');
    xlabel('Principal components'); 

    % PC scatter plot for all neurons and memory components................
    conditionColors = [...
                0.8314 0.667 0;
                1 .8314 .1647;
                0.3725 .3725 .8275;
                0 0 .5;
                0 1 0;
                1 0 0;
                ];
        

    fig = figure(); 
    gscatter(score(:,1),score(:,2),deltaLabS(:,3),conditionColors)
    ax = gca;
    for i=1:numel(ax.Children)
        ax.Children(i).MarkerSize = 60;
    end
    
    fig.Position = [1153,         462,         795,         754];
    ax.LineWidth = 6;
    ax.FontSize = 28; 

    ax.FontWeight = 'bold';
    ax.TickDir = 'out';
    xlabel('PC 1'); 
    ylabel('PC 2');
    %this inverses the Y-axis to allow for a easier visual comparison of  
    % of the clusters with the PC scatter plot of the sensory neurons
    ax.YDir = 'reverse';


%Reconstruction input data form PC scores and loads (Fig 7 C)--------------
%--------------------------------------------------------------------------

%these are task parameter labels 
task_param = {'VAL','CS(AP)','CS(AV)','US+','US-'};   
%these are the lines associated with the parameters
batches = [1 12;
           13 18;
           19 24;
           25 30;
           31 36];

%This function re-calculates neural activity deltas from pc scores and
%loads using only selected principal components that group the task 
%parameters. It then reverses the normalization, scales the activity delta
%by the mean neural response and then plots the mean summed activity delta 
%for each neuron and task parameter.   
[means,errors] = retransform(score,coeff,batches,nrns,ranges,task_param,...
    deltaLabS,2,[1 2 3 5],R,.3,'scaleByAMP',amplitudes);
[rows,cols] = size(means);
%creating input data for the classifier
inputData = [abs(means(:)),abs(means(:))./errors(:)];
inputData = inputData/max(inputData(:,1));
%filtering out arrows that are numerical too small are show too much error
%based on a model trained on simulated data. This was used in Figure 7 C. 
pred = trainedModel.predictFcn(inputData);
preds = reshape(pred,[rows,cols]);
addresshandles(gca,preds);
title('Filtered by model'); 


%Note that the model is quite consistent with arbitrary thresholding that
%eliminates all smaller changes. 2 for abs(means) is the 75% percentile 
%in the absolute values for means, thereby using only the strongest 25 % 
[means,errors] = retransform(score,coeff,batches,nrns,ranges,task_param,...
    deltaLabS,2,[1 2 3 5],R,.3,'scaleByAMP',amplitudes);
io_mat = abs(means) > 2 & abs(means) > 2*errors;
addresshandles(gca,io_mat)
title('Filtered by thresholding'); 

