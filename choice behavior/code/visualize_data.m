%--------------------------------------------------------------------------
% load the file 'data_figure_1.mat' into the workspace
%--------------------------------------------------------------------------
% The following lines viualize choice indices  
%--------------------------------------------------------------------------
barValues(fliplr(CI_STAP),{},[-1 1],0.3,'grays')
    ax = gca;
    ax.XTickLabels = fliplr(CI_column_headers);
    ax.XTickLabelRotation = 45;
    title('STAP');
    fig = gcf;
    fig.Position = [50 50 800 800];
barValues(fliplr(CI_STAV),{},[-1 1],0.3,'grays')
    ax = gca;
    ax.XTickLabels = fliplr(CI_column_headers);
    ax.XTickLabelRotation = 45;
    title('STAV');
    fig = gcf;
    fig.Position = [50 50 800 800];
barValues(fliplr(CI_LTAV),{},[-1 1],0.3,'grays')
    ax = gca;
    ax.XTickLabels = fliplr(CI_column_headers);
    ax.XTickLabelRotation = 45;
    title('LTAV');
    fig = gcf;
    fig.Position = [50 50 800 800];
barValues(fliplr(CI_LTAP),{},[-1 1],0.3,'grays')
    ax = gca;
    ax.XTickLabels = fliplr(CI_column_headers);
    ax.XTickLabelRotation = 45;
    title('LTAP');
    fig = gcf;
    fig.Position = [50 50 800 800];
%--------------------------------------------------------------------------
% The following lines viualize learning indices  
%--------------------------------------------------------------------------   
barValues(fliplr(LI_STAP),{},[-2 2],0.3)
    ax = gca;
    ax.XTickLabels = fliplr(LI_column_headers);
    ax.XTickLabelRotation = 45;
    title('STAP');
    fig = gcf;
    fig.Position = [50 50 800 800];
barValues(fliplr(LI_STAV),{},[-2 2],0.3)
    ax = gca;
    ax.XTickLabels = fliplr(LI_column_headers);
    ax.XTickLabelRotation = 45;
    title('STAV');
    fig = gcf;
    fig.Position = [50 50 800 800];
barValues(fliplr(LI_LTAV),{},[-2 2],0.3)
    ax = gca;
    ax.XTickLabels = fliplr(LI_column_headers);
    ax.XTickLabelRotation = 45;
    title('LTAV');
    fig = gcf;
    fig.Position = [50 50 800 800];
barValues(fliplr(LI_LTAP),{},[-2 2],0.3)
    ax = gca;
    ax.XTickLabels = fliplr(LI_column_headers);
    ax.XTickLabelRotation = 45;
    title('LTAP');
    fig = gcf;
    fig.Position = [50 50 800 800];