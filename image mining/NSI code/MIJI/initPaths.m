function [] = initPaths(imageJPath);

    %add MIJI libraries paths
  
    
    eval(['javaaddpath ''',matlabroot,'\java\jar\mij.jar','''']);
    eval(['javaaddpath ''',matlabroot,'\java\jar\ij.jar','''']);
    
    addpath(imageJPath);
    addpath([imageJPath(1:end-7),'plugins\']);
    addpath([imageJPath(1:end-7),'macros\']);

    str = which('getImageMIJI');
    [x,y,z] = fileparts(str);
    javaaddpath(x);
    eval(['javaaddpath ''',imageJPath(1:end-7),'\plugins\3D_Viewer-4.0.2.jar','''']);
    
    % start MIJI
    % maybe also add the plugins folder as java path
    
    MIJ.start();

end