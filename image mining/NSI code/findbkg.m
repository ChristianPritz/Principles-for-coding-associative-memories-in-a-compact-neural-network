function [averLevel] = findbkg(cube,thrshld)
    perc5 = round(numel(cube)*thrshld);
    lin = sort((reshape(cube,1,numel(cube),1)),'descend');
   averLevel= mean(lin(end-perc5:end));

end