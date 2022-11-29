function [ angles ] = rotm2eulc( rotMat )
%ROTM2EULC Summary of this function goes here
%   Detailed explanation goes here
    if size(rotMat) == [3,3]
        sy = sqrt(rotMat(1,1) * rotMat(1,1) + rotMat(2,1) * rotMat(2,1));
        
        if ~(sy < 1*exp(-6))
            x = atan2(rotMat(3,2),rotMat(3,3));
            y = atan2(-rotMat(3,1),sy);
            z = atan2(rotMat(2,1),rotMat(1,1));
        else
            x = atan2(-rotMat(2,3),rotMat(2,2));
            y = atan2(-rotMat(3,1),sy);
            z = 0;
            
        end
            % output according to matlab convention
            angles = [z,y,x];
    
    end

end

