function [ ellipseData ] = meshellipse( boxSize,origin,elDat,eulAng )
%MESHELLIPSE Summary of this function goes here
%   Detailed explanation goes here
     
    %geometric parameters-------------------------------------------------
    bX = boxSize(2); %this is on purpose
    bY = boxSize(1); %this is on purpose
    bZ = boxSize(3);
    x0 = origin(1);
    y0 = origin(2);
    z0 = origin(3);
    
    a = elDat(1);
    b = elDat(2);
    c = elDat(3);
   
    center = [1;1;1];
    endX = [bX;1;1];
    endY = [1;bY;1];
    endZ = [1;1;bZ];
    
    
    %this bs safeguards that the meshgrid is rotatet around the center of
    %the ellipse (=origin) 
    center = center - [origin(1);origin(2);origin(3)];
    endX = endX - [origin(1);origin(2);origin(3)];
    endY = endY - [origin(1);origin(2);origin(3)];
    endZ = endZ - [origin(1);origin(2);origin(3)];
    
    %
    %rotm = eul2rotm(eulAng,'ZYX');
    rotm = eul2rotmc(eulAng);
    % create mesh grid and rotate -----------------------------------------
    [X,Y,Z] = meshgrid(center(1):1:endX(1),center(2):1:endY(2),center(3):1:endZ(3));
    %[X,Y,Z] = meshgrid(1:1:bX,1:1:bY,1:1:bZ);
    %rotm = eul2rotmc(eulAng);
    temp=[X(:),Y(:),Z(:)]*rotm ;
    sz=size(X);
    Xrot=reshape(temp(:,1),sz);
    Yrot=reshape(temp(:,2),sz);
    Zrot=reshape(temp(:,3),sz);
    
    % check all points if they are in the ellipse-------------------------
    rawEllipse = (Xrot).^2/a^2+(Yrot).^2/b^2+(Zrot).^2/c^2;
    ellipseData = double(rawEllipse <= 1);

end
