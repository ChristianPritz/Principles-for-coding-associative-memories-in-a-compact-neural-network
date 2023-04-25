function [m,R] = vectorZnorm(mat,string,intervals)
    % each line in mat is sequence of neural activity vectors of a neuron; 
    % corresponding timepoints of neurons are stacked in columns. This code
    % normalizes each neuron individually by selecting only the sub sets 
    % in the matrix that neurons occupy
    
    m = [];
    R = [];
    counter = 1;
    yn = zeros(1,size(string,2));
    a = cellfun(@numel,intervals);
    lens = cumsum(a);
    
    for i=1:1:size(string,2)
       idcs = counter:lens(i);
       mx = mat(:,idcs); 
       mt = (mx-nanmean(mx(:)))./nanstd(mx(:)); 
       m = horzcat(m,mt);
       counter = idcs(end)+1;
       R(i,1) = nanmean(mx(:));
       R(i,2) = nanstd(mx(:));
    end
end