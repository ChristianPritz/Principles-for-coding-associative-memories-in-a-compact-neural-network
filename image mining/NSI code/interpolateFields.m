function 	[object] = interpolateFields( object,fieldList,frameRate,wDur);
%INTERPOLATEFIELDS Summary of this function goes here
%   Detailed explanation goes here
    for i=1:size(fieldList,1)
       if isfield(object,fieldList{i});
            data = eval(['object.',fieldList{i}]);
            dataNew = [];
            disp(fieldList{i});
            for j=1:size(data,1)
                interDat = interp1(object.time,data(j,:),[1/frameRate:1/frameRate:wDur],'linear');
                dataNew = [dataNew;interDat];
                
            end
            eval(['object.',fieldList{i},' = dataNew;']);
       end
    end
    object.time = [1/frameRate:1/frameRate:wDur];
end

