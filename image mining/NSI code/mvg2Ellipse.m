function [ isoS,ellipseData ] = mvg2Ellipse( sigmaParam,centerMass,pDP )

%MVG2ELLIPSE Summary of this function goes here
%   Detailed explanation goes here
    % the whole thing works in pixel
    isoS = [];
     ellipseData = struct();
    
    sigma = [sigmaParam(1),sigmaParam(2),sigmaParam(3);...
        sigmaParam(2),sigmaParam(4),sigmaParam(5);...
        sigmaParam(3),sigmaParam(5),sigmaParam(6)];

           
       ellipseData.center = [centerMass(1),centerMass(2),centerMass(3)];
       
       
       [ellipseData.evecs,ellipseData.v] = eig(sigma);
       [largest_eigenvec,largest_eigenval,ind] = findEigMax(sigma);
       
       ellipseData.radii = [1.6*sqrt(ellipseData.v(1));1.6*sqrt(ellipseData.v(5));1.6*sqrt(ellipseData.v(9))];
       %ellipseData.radii = [1.6*sqrt(ellipseData.v(1));1.6*sqrt(ellipseData.v(5));1.6*sqrt(ellipseData.v(9))];
       % next line practically obsolete pDP is default 1.
       ellipseData.radii = ellipseData.radii * pDP;
       % get eulers Angles... 
       ellipseData.eulAngles = rotm2eulc(ellipseData.evecs);
              
end

function [largest_eigenvec,largest_eigenval,largest_eigenvec_ind_c] = findEigMax(covMat)
    
    [eigenvec, eigenval ] = eig(covMat);

    % Get the index of the largest eigenvector
    [largest_eigenvec_ind_c, r] = find(eigenval == max(max(eigenval)));
    largest_eigenvec = eigenvec(:, largest_eigenvec_ind_c);

    % Get the largest eigenvalue
    largest_eigenval = max(max(eigenval));
end



