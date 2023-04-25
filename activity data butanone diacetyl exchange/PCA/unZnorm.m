function [m] = unZNorm(mat,string,intervals,R)
    m = [];
    counter = 1;

    yn = zeros(1,size(string,2));
    a = cellfun(@numel,intervals);
    lens = cumsum(a);
    
    for i=1:1:size(string,2)
       idcs = counter:lens(i);
       mx = mat(:,idcs); 
       mt = mx*R(i,2)+R(i,1); 
       m = horzcat(m,mt);
       counter = idcs(end)+1;
       
    end
end