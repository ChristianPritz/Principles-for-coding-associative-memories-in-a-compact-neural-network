function [m] =subslice(mat,idx,intervals)
    %This function extractes the partial activity vectors
    % of all neurons specified by idx.
    % intervals indicate the length of the partial vectors
    % neuron identies can be viewed in deltaString
    m = [];
    counter = 1;
    yn = zeros(1,numel(intervals));
    yn(idx) = 1; 
    a = cellfun(@numel,intervals);
    lens = cumsum(a);
    
    for i=1:1:numel(yn)
       idcs = counter:lens(i); 
       if yn(i) == 1
        m = horzcat(m,mat(:,idcs));
       end
       counter = idcs(end)+1;
       
    end
end