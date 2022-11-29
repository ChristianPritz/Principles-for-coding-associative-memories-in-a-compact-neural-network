function [ arraysOut ] = inboundries3D( theSize,xArray,yArray,zArray )
    %subStack = stack([yUp:yDown],[xUp:xDown],[zUp:zDown]);
    
    arrays = {xArray,yArray,zArray};
    arraysOut = {};
    for i=1:1:length(arrays)
       
        start = arrays{i}(1);
        theEnd = arrays{i}(end);
        if start < 1
            start = 1;
        end
        if i == 1 
            limit = theSize(2);
        end
        if i == 2 
            limit = theSize(1);
        end
        %if i == 2 
            %limit = theSize(1);
        %end
        if i == 3 
            limit = theSize(3);
        end
        if theEnd > limit
            theEnd = limit;
        end
        
        % implement limits for negative start values ones... 
        % subtract negative initial values from end limit to prevent an overshoot 
    
        theArray = [start:theEnd];
        arraysOut = vertcat(arraysOut,theArray);
        
    end


    %BOUNDRIES Summary of this function goes here
    %   Detailed explanation goes here


end

