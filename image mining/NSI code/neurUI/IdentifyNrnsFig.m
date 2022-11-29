function varargout = IdentifyNrnsFig(varargin)
% IDENTIFYNRNSFIG MATLAB code for IdentifyNrnsFig.fig
%      IDENTIFYNRNSFIG, by itself, creates a new IDENTIFYNRNSFIG or raises the existing
%      singleton*.
%
%      H = IDENTIFYNRNSFIG returns the handle to a new IDENTIFYNRNSFIG or the handle to
%      the existing singleton*.
%
%      IDENTIFYNRNSFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IDENTIFYNRNSFIG.M with the given input arguments.
%
%      IDENTIFYNRNSFIG('Property','Value',...) creates a new IDENTIFYNRNSFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IdentifyNrnsFig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IdentifyNrnsFig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IdentifyNrnsFig

% Last Modified by GUIDE v2.5 07-Nov-2018 17:03:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IdentifyNrnsFig_OpeningFcn, ...
                   'gui_OutputFcn',  @IdentifyNrnsFig_OutputFcn, ...
                   'gui_LoopFcn',  @IdentifyNrnsFig_LoopFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% End initialization code - DO NOT EDIT

% --- Executes just before IdentifyNrnsFig is made visible.
function IdentifyNrnsFig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IdentifyNrnsFig (see VARARGIN)

% Choose default command line output for IdentifyNrnsFig
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using IdentifyNrnsFig.
if strcmp(get(hObject,'Visible'),'off')
  
 %sort all the variables...   
    
    
    S = varargin{1,1};
    if ~isfield(S,'vertexN')
        S.vertexN = 20; %move outside 
    end
        %input-specific fields
        
    
        S.axes = {handles.axes1;handles.axes2;handles.axes3};
        %Visualization properties
              
        if S.naive == 1
            [searchData,lightHandle,handleFrame,handleDat] = ...
            displayNeuronSpheres(S,1);
            S.searchData = searchData;
            S.lightHandle = lightHandle;
            S.handleFrame = handleFrame;
            S.handleDat = handleDat;
            
            S.currVisType = 'colorMap'; % colorMap or colors
            S.dataColorMap = 'jet';
            %naive State
            S.geomData = S.ellipseData{1};
            S.outputData = horzcat(searchData,S.labels,S.labels);
            S.xpos = S.ellipseData{1}{1,10};
            S.ypos = S.ellipseData{1}{1,11};
            S.zpos = S.ellipseData{1}{1,12};
            S.lx = 10;
            S.ly = 10;
            S.lz = 10;
            S.angleX = 0;
            S.angleY = 0;
            S.angleZ = 0;
            S.currentNum = 1;
        else
            S.labels = S.outputData(:,4);
            [searchData,lightHandle,handleFrame,handleDat] = ...
            displayNeuronSpheres(S,1);
            S.searchData = searchData;
            S.lightHandle = lightHandle;
            S.handleFrame = handleFrame;
            S.handleDat = handleDat;
            S.outputData = horzcat(searchData,S.outputData(:,[4,5]));
        end
        
        S.nextStep = 1;

        S.cycling = 1;
        S.proceed = 0;
        S.data = [];
        S.str = '';
     
        S.nameNeuron = 1;
        S.itsDone = false;
        S.h = '';
        
        S.toggleV = false;
        S.hSlice = '';
        S.stack_green  = getImageMiji( [cd,'\',S.imageStack],[],[1],[1] );
        S.stack_green = permute(S.stack_green,[2,1,3]);
        S.stack_red  = getImageMiji( [cd,'\',S.imageStack],[],[2],[1] );
        S.stack_red = permute(S.stack_red,[2,1,3]);
        S.stack = S.stack_green;
        S.stackColor = 1;
        %S.ax1 = gca;
        S.xRange = S.axes{1}.XLim;
        S.yRange = S.axes{1}.YLim;
        S.zRange = S.axes{1}.ZLim;
        S.line = [];
        S.changeGeom = 0;
        S.clicked = 0;
        S.processing = 0;
        S.firstSwitch = 1; 
        S.colorRange = [1 4095]; % get this dynamically from the bit range of the stack
        S.lowerDRLim = 1;
        S.upperDRLim = 4095;
        S.addANeuron = false;
        
        S.colNum = 4;
        S.dataAx = nan;
        S.deleteANrn = false;
        S.positionLog = [0,0,0];
        S.comment = '';
        S.corrInd = [];
        S.c = 1;
        S.handles = handles;
        S.hObject = hObject;
        %slice view settings.........
        S.zVal = 0;
        S.zLim1Old = S.axes{1}.ZLim(1);
        S.zLim2Old = S.axes{1}.ZLim(2);
        S.zSlice = round((S.zLim2Old-S.zLim1Old)/2);
        S.zHandle = '';
        S.naive = 0;
        S.visTypes = {'colorMap','colors','corrColors'};
        S.colorSpaces = {'currentColors','userColors','corrColors'};
        
        
        dcm_obj = datacursormode(hObject);
        dcm_obj.DisplayStyle = 'window';
        set(dcm_obj,'UpdateFcn',@myupdatefcn);
        S.dcm_obj = dcm_obj;
        
        setGlobalS(S);
        updateGUIstate(S);
    
    % plot all the neurons into the    
    
end

% UIWAIT makes IdentifyNrnsFig wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = IdentifyNrnsFig_OutputFcn(hObject, eventdata, handles,varargin)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    S = getGlobalS;
    varargout{1} = handles.output;
    varargout{2} = S;


 % --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
%done button 
 S=getGlobalS;
 assignin('base','crashProfile',S);
 close(gcf);
 formprocpkg(S);

% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
    S = getGlobalS;
    info= getCursorInfo(S.dcm_obj);

% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end
fileID = fopen('allNeurons.txt');
    C = textscan(fileID,'%s %s');
    fclose(fileID);
    theList = C{1};

set(hObject, 'String', theList);


% --- Executes on slider movement.
function slider11_Callback(hObject, eventdata, handles)
 S = getGlobalS;
 num = S.currentNum;;
  
    % get the rotations... 
    rx = S.handles.slider11.Value;;
    ry = S.ellipseData{1}{num,17};
    rz = S.ellipseData{1}{num,18};
    
    lx = S.ellipseData{1}{num,13};
    ly = S.ellipseData{1}{num,14};
    lz = S.ellipseData{1}{num,15};
    trafoLine  = [0 0 0 lx ly lz rx ry rz];
    updateGeometry(num,trafoLine);
    


% --- Executes during object creation, after setting all properties.
function slider11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider12_Callback(hObject, eventdata, handles)
S = getGlobalS;
 num = S.currentNum;;
  
    % get the rotations... 
    rx = S.ellipseData{1}{num,16};
    ry = S.handles.slider12.Value;;
    rz = S.ellipseData{1}{num,18};
    
    lx = S.ellipseData{1}{num,13};
    ly = S.ellipseData{1}{num,14};
    lz = S.ellipseData{1}{num,15};
    trafoLine  = [0 0 0 lx ly lz rx ry rz];
    updateGeometry(num,trafoLine);

% --- Executes during object creation, after setting all properties.
function slider12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider13_Callback(hObject, eventdata, handles)
S = getGlobalS;
 num = S.currentNum;;
  
    % get the rotations... 
    rx = S.ellipseData{1}{num,16};
    ry = S.ellipseData{1}{num,17};
    rz = S.handles.slider13.Value;    
    lx = S.ellipseData{1}{num,13};
    ly = S.ellipseData{1}{num,14};
    lz = S.ellipseData{1}{num,15};
    trafoLine  = [0 0 0 lx ly lz rx ry rz];
    updateGeometry(num,trafoLine);


% --- Executes during object creation, after setting all properties.
function slider13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider14_Callback(hObject, eventdata, handles)
%xScale
  S = getGlobalS;
  num = S.currentNum;
  
    % get the rotations... 
    rx = S.ellipseData{1}{num,16};
    ry = S.ellipseData{1}{num,17};
    rz = S.ellipseData{1}{num,18};
    lx = S.handles.slider14.Value; 
    ly = S.ellipseData{1}{num,14};
    lz = S.ellipseData{1}{num,15};
    trafoLine  = [0 0 0 lx ly lz rx ry rz];
    updateGeometry(num,trafoLine);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider15_Callback(hObject, eventdata, handles)
% yScale
S = getGlobalS;
  num = S.currentNum;
  
    % get the rotations... 
    rx = S.ellipseData{1}{num,16};
    ry = S.ellipseData{1}{num,17};
    rz = S.ellipseData{1}{num,18};
    
    lx = S.ellipseData{1}{num,13};
    ly = S.handles.slider15.Value;
    lz = S.ellipseData{1}{num,15};
    trafoLine  = [0 0 0 lx ly lz rx ry rz];
    updateGeometry(num,trafoLine);

% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider16_Callback(hObject, eventdata, handles)
  %zScale
  S = getGlobalS;
  num = S.currentNum;;
  
    % get the rotations... 
    rx = S.ellipseData{1}{num,16};
    ry = S.ellipseData{1}{num,17};
    rz = S.ellipseData{1}{num,18};
    
    lx = S.ellipseData{1}{num,13};
    ly = S.ellipseData{1}{num,14};
    lz = S.handles.slider16.Value;
    trafoLine  = [0 0 0 lx ly lz rx ry rz];
    updateGeometry(num,trafoLine);

    % hObject    handle to slider16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider17_Callback(hObject, eventdata, handles)
% hObject    handle to slider17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider18_Callback(hObject, eventdata, handles)
% hObject    handle to slider18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider19_Callback(hObject, eventdata, handles)
% hObject    handle to slider19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider20_Callback(hObject, eventdata, handles)
% hObject    handle to slider20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider21_Callback(hObject, eventdata, handles)
% hObject    handle to slider21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
    %change colormap 
    S = getGlobalS;
    list = S.handles.popupmenu4.String;
    idx = S.handles.popupmenu4.Value;
    cMap = list{idx};
    disp('');
    eval(['S.dataColorMap = ', cMap,';']);
    setGlobalS(S);
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
hObject.String = {'parula','jet','summer','autumn','hot','cool','gray'};
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
   % half zoomOut
    S = setGlobalS;
    zlim(zRange);
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% half zoomIn; 
    S=getGlobalS;
    S.zlim([zpos-10,zpos+10]);
    % hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
    % ZoomOut
    S = getGlobalS;
    xlim(S.xRange);
    ylim(S.yRange);
    zlim(S.zRange);
    
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
    % ZoomIn
    S = getGlobalS;
    xlim([S.xpos-25,S.xpos+25]);
    ylim([S.ypos-25,S.ypos+25]);
    zlim([S.zpos-10,S.zpos+10]);
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider23_Callback(hObject, eventdata, handles)
    S = getGlobalS;
    oldLowerDR = S.lowerDRLim;
        S.lowerDRLim = S.handles.slider23.Value;
        if S.lowerDRLim < S.upperDRLim 
            
            
            currentLimits = S.axes{1}.CLim; 
            currentLimits(1) = S.lowerDRLim; 
            S.axes{1}.CLim = currentLimits;
        end
        if S.lowerDRLim >= S.upperDRLim
            S.lowerDRLim = oldLowerDR;
        end
        S.handles.slider23.Value = S.lowerDRLim;
   setGlobalS(S);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider22_Callback(hObject, eventdata, handles)
% hObject    set upper threshold
%get callback 
        S = getGlobalS;
        oldUpperDR = S.upperDRLim;
        S.upperDRLim = S.handles.slider22.Value;
        if S.lowerDRLim < S.upperDRLim
            
            currentLimits = S.axes{1}.CLim; 
            currentLimits(2) = S.upperDRLim; 
            S.axes{1}.CLim = currentLimits;
        end
        if S.lowerDRLim >= S.upperDRLim
            S.upperDRLim = oldUpperDR;
        end
        S.handles.slider22.Value = S.upperDRLim;
    setGlobalS(S);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
    S = getGlobalS;
    toggleStackOff(S);
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
    S = getGlobalS;
    toggleStackOn(S);
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
            S = getGlobalS;
            %delete visualization;
            delete(S.outputData{S.currentNum,2}); 
            %delete(S.outputData(S.currentNum,2));
            % update filtMatrix....
             for i=1:size(S.ellipseData,1)
                S.ellipseData{i}(S.currentNum,:) = [];
             end
             
           % delete currentColors entry
           %{'currentColors','userColors','corrColors'};
             S.currentColors(S.currentNum,:) = [];
             S.userColors(S.currentNum,:) = [];
             S.corrColors(S.currentNum,:) = [];
           % update geomData 
             S.geomData = S.ellipseData{1};
           % update searchData
             S.searchData(S.currentNum,:) = [];    
           % update outputData
             S.outputData(S.currentNum,:) = [];
           % update intensity matrix 
             S.multipleYDataCorr(S.currentNum,:) = [];
             S.multipleLabels(S.currentNum) = [];
           % update the display of the intensities
           S.currentNum = S.currentNum -1;  
           
           S = redrawPlots(S);
           
           setGlobalS(S);
           %safety dump in base workspace;
           assignin('base','changedFiltMatrix',S.ellipseData);
           assignin('base','crashLabels',S.outputData(:,4)) %?????? 
           assignin('base','S',S);
          
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
    addNeuron();
    % hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
    S = getGlobalS;
    [num,type] = getCurrentSelection;
    list = S.handles.popupmenu1.String;
    value = S.handles.popupmenu1.Value;
    name = list{value};
    if ~strcmp('nan',type)
        %change display name..............................
        S.outputData{num,3}.String = name;
        %change output label..............................
        S.outputData{num,4} = name;
    end
    % writing S back to global space
    setGlobalS(S);
    assignin('base','changedFiltMatrix',S.ellipseData);
    assignin('base','crashLabels',S.outputData(:,4));
    assignin('base','S',S);
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function text26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
            
 



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
  % move up x
  S = getGlobalS;
  num = S.currentNum;
  % get the rotations... 
    rx = S.ellipseData{1}{num,16};
    ry = S.ellipseData{1}{num,17};
    rz = S.ellipseData{1}{num,18};
    lx = S.ellipseData{1}{num,13};
    ly = S.ellipseData{1}{num,14};
    lz = S.ellipseData{1}{num,15};
    trafoLine  = [0.5 0 0 lx ly lz rx ry rz];
    setGlobalS(S);
    updateGeometry(num,trafoLine);
    

% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles)
 

% --- Executes on button press in pushbutton39.
function pushbutton39_Callback(hObject, eventdata, handles)
  


% --- Executes on button press in pushbutton30.
function pushbutton30_Callback(hObject, eventdata, handles)
    S = getGlobalS;
    S.comment = [S.comment, ' / ',S.handles.edit2.String];
    S.handles.edit2.String = 'Add comment';
    setGlobalS(S);


% --- Executes on button press in pushbutton31.
function pushbutton31_Callback(hObject, eventdata, handles)
 changeVisulazation('','');


% --- Executes on button press in pushbutton37.
function pushbutton37_Callback(hObject, eventdata, handles)
closestCorr()
    
% --- Executes on button press in pushbutton38.
function pushbutton38_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton32.
function pushbutton32_Callback(hObject, eventdata, handles)
  S = getGlobalS;
  num = S.currentNum;
  
    % get the rotations... 
    rx = S.ellipseData{1}{num,16};
    ry = S.ellipseData{1}{num,17};
    rz = S.ellipseData{1}{num,18};
    lx = S.ellipseData{1}{num,13};
    ly = S.ellipseData{1}{num,14};
    lz = S.ellipseData{1}{num,15};
    trafoLine  = [-0.5 0 0 lx ly lz rx ry rz];
    setGlobalS(S);
    updateGeometry(num,trafoLine);
  
  

% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, handles)
%yUP
S = getGlobalS;
  num = S.currentNum;
  
    % get the rotations... 
    rx = S.ellipseData{1}{num,16};
    ry = S.ellipseData{1}{num,17};
    rz = S.ellipseData{1}{num,18};
    lx = S.ellipseData{1}{num,13};
    ly = S.ellipseData{1}{num,14};
    lz = S.ellipseData{1}{num,15};
    trafoLine  = [0 0.5 0 lx ly lz rx ry rz];
    setGlobalS(S);
    updateGeometry(num,trafoLine);
    
% --- Executes on button press in pushbutton34.
function pushbutton34_Callback(hObject, eventdata, handles)
% yDown
S = getGlobalS;
  num = S.currentNum;
  
    % get the rotations... 
    rx = S.ellipseData{1}{num,16};
    ry = S.ellipseData{1}{num,17};
    rz = S.ellipseData{1}{num,18};
    lx = S.ellipseData{1}{num,13};
    ly = S.ellipseData{1}{num,14};
    lz = S.ellipseData{1}{num,15};
    trafoLine  = [0 -0.5 0 lx ly lz rx ry rz];
    setGlobalS(S);
    updateGeometry(num,trafoLine);
  
  
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton35.
function pushbutton35_Callback(hObject, eventdata, handles)
%zUP
  S = getGlobalS;
  num = S.currentNum;
  
    % get the rotations... 
    rx = S.ellipseData{1}{num,16};
    ry = S.ellipseData{1}{num,17};
    rz = S.ellipseData{1}{num,18};
    lx = S.ellipseData{1}{num,13};
    ly = S.ellipseData{1}{num,14};
    lz = S.ellipseData{1}{num,15};
    trafoLine  = [0 0 0.5 lx ly lz rx ry rz];
    setGlobalS(S);
    updateGeometry(num,trafoLine);
  


% --- Executes on button press in pushbutton36.
function pushbutton36_Callback(hObject, eventdata, handles)
%zDown
  S = getGlobalS;
  num = S.currentNum;
  
    % get the rotations... 
    rx = S.ellipseData{1}{num,16};
    ry = S.ellipseData{1}{num,17};
    rz = S.ellipseData{1}{num,18};
    lx = S.ellipseData{1}{num,13};
    ly = S.ellipseData{1}{num,14};
    lz = S.ellipseData{1}{num,15};
    trafoLine  = [0 0 -0.5 lx ly lz rx ry rz];
    setGlobalS(S);
    updateGeometry(num,trafoLine);
  

% --- Executes on button press in pushbutton40.
function pushbutton40_Callback(hObject, eventdata, handles)
    S = getGlobalS;
    changeLabels(S);

    % --- Executes on button press in pushbutton41.
function pushbutton41_Callback(hObject, eventdata, handles)
% change channel
    S = getGlobalS;
    if S.stackColor == 1
            S.stack = S.stack_red;
            S.stackColor = 2;
            delete(S.hSlice);
            S.toggleV = false;
            toggleStackOn(S);
        elseif S.stackColor == 2
            S.stack = S.stack_green;
            S.stackColor = 1;
            delete(S.hSlice);
            S.toggleV = false;
            toggleStackOn(S);
    end

        % --- Executes on button press in pushbutton42.
function pushbutton42_Callback(hObject, eventdata, handles)
    S=getGlobalS;
    if S.zVal == 0
       val = 0;
    else 
       val = 1; 
    end
    zSlicing(S,val)
    %toggle Z view


% --- Executes on slider movement.
function slider26_Callback(hObject, eventdata, handles)
% z Slice 
    S=getGlobalS;
    if S.zVal == 1
        S.zSlice = hObject.Value;
        %check if z-slicing is on before updating else only update S in else
        zSlicing(S,0);
    end
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    S = getGlobalS;
    hObject.SliderStep = [1/size(S.stack,3) 1/size(S.stack,3)];
    hObject.Min = 0;
    hObject.Max = S.zLim2Old;
    hObject.Value = round((S.zLim2Old-S.zLim1Old)/2)
   
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

    

%auxilliary functions---------------------------------------------------
function setGlobalS(val)
    global S
    S = val;

function r = getGlobalS
    global S
    r = S;

function [num,type] = getCurrentSelection
        S = getGlobalS;
        info = getCursorInfo(S.dcm_obj);
        if ~isempty(info)
            if strcmp(info.Target.Type,'image') 
                num = info.Position(2);
                type = 'trace';
            elseif strcmp(info.Target.Type,'surface') || strcmp(info.Target.Type,'scatter') 
                type = 'neuron';
                [num,x] = knnsearch(cell2mat(S.searchData(:,1)),info.Position,'k',1);
            end
        else 
            type = 'nan';
            num = NaN;
        end

        
 function [position] = myupdatefcn(empt,event_obj)
    S = getGlobalS;
    oldNum = S.currentNum; 
    [num,type] = getCurrentSelection;
    % highlight the spheres..........................................    
    if ~strcmp(type,'nan')
        if strcmp(S.currVisType, 'flat')
           S.outputData{oldNum,2}.FaceColor = 'flat';
           S.outputData{oldNum,2}.FaceAlpha = 0.6;
         else
           S.outputData{oldNum,2}.FaceColor = S.currentColors(oldNum,:);
           S.outputData{oldNum,2}.FaceAlpha = 0.6;
        end
        S.outputData{num,2}.FaceColor = [1 1 1];
        S.outputData{num,2}.FaceAlpha = 1;
     % highlight the intensities ......................................... 
    end
    S.handleFrame.XData = [0.5,size(S.multipleYDataCorr,2),size(S.multipleYDataCorr,2),0.5,0.5];
    S.handleFrame.YData = [num-0.5,num-0.5,num+0.5,num+0.5,num-0.5];
    S.handleDat.YData = S.multipleYDataCorr(num,:);
    S.currentNum = num;
    %position = [S.ellipseData{num,10},S.ellipseData{num,11},S.ellipseData{num,12}]; 
    S.xpos = S.ellipseData{1}{num,10};
    S.ypos = S.ellipseData{1}{num,11};
    S.zpos = S.ellipseData{1}{num,12};
    setGlobalS(S);
    disp('-----------------------------------------');
    updateGUIstate(S); 
         
function updateGUIstate(S)
% set slider ranges and states for geometry
    S.handles.slider14.Value = S.geomData{S.currentNum,13};
    S.handles.slider14.Min = 0.1;
    S.handles.slider14.Max = S.geomData{S.currentNum,13} + 20;

    S.handles.slider15.Value = S.geomData{S.currentNum,14};
    S.handles.slider15.Min = 0.1;
    S.handles.slider15.Max = S.geomData{S.currentNum,14} + 20;
    
    S.handles.slider16.Value = S.geomData{S.currentNum,15};
    S.handles.slider16.Min = 0.1;
    S.handles.slider16.Max = S.geomData{S.currentNum,15} + 20;
    
    S.handles.slider11.Value = S.geomData{S.currentNum,16};
    S.handles.slider11.Min = -2*pi;
    S.handles.slider11.Max = 2*pi;
    
    S.handles.slider12.Value = S.geomData{S.currentNum,17};
    S.handles.slider12.Min = -2*pi;
    S.handles.slider12.Max = 2*pi;
    
    S.handles.slider13.Value = S.geomData{S.currentNum,18};
    S.handles.slider13.Min = -2*pi;
    S.handles.slider13.Max = 2*pi;
    
    % set slider ranges and states for dynamic range
    S.handles.slider22.Value = S.upperDRLim;
    S.handles.slider22.Min = 1;
    S.handles.slider22.Max = 65635;
    
    S.handles.slider23.Value = S.lowerDRLim;
    S.handles.slider23.Min = 1;
    S.handles.slider23.Max = 65635;

            % slider positions
            
            %popupmenues
            
            
function updateGeometry(num,changeLine)
        %get the S:
        S = getGlobalS;
      
        %add new deltas
        S.ellipseData{1}{num,10} = S.ellipseData{1}{num,10} + changeLine(1);
        S.ellipseData{1}{num,11} = S.ellipseData{1}{num,11} + changeLine(2);
        S.ellipseData{1}{num,12} = S.ellipseData{1}{num,12} + changeLine(3);
        S.ellipseData{1}{num,13} =  changeLine(4);
        S.ellipseData{1}{num,14} =  changeLine(5);
        S.ellipseData{1}{num,15} =  changeLine(6);
        S.ellipseData{1}{num,16} =  changeLine(7);
        S.ellipseData{1}{num,17} =  changeLine(8);
        S.ellipseData{1}{num,18} =  changeLine(9);
       
        h = S.outputData{num,2};
        
        delete(h);
        %S.outputData{num,2} = nan;
        [eX,eY,eZ] = ellipsoid(S.ellipseData{1}{num,10},S.ellipseData{1}{num,11},....
            S.ellipseData{1}{num,12},S.ellipseData{1}{num,13},S.ellipseData{1}{num,14},...
            S.ellipseData{1}{num,15},S.vertexN);
        S.outputData{num,2} = surf(eX,eY,eZ);
        rotate(S.outputData{num,2},[1,0,0],radtodeg(S.ellipseData{1}{num,16}),[S.ellipseData{1}{num,10},S.ellipseData{1}{num,11},...
                S.ellipseData{1}{num,12}]);
        rotate(S.outputData{num,2},[0,1,0],radtodeg(S.ellipseData{1}{num,17}),[S.ellipseData{1}{num,10},S.ellipseData{1}{num,11},...
                S.ellipseData{1}{num,12}]);
        rotate(S.outputData{num,2},[0,0,1],radtodeg(S.ellipseData{1}{num,18}),[S.ellipseData{1}{num,10},S.ellipseData{1}{num,11},...
                S.ellipseData{1}{num,12}]);
        S.outputData{num,2}.EdgeColor = 'none';
        S.outputData{num,2}.FaceColor = [1 1 1]; 

        
        % move the text to the new center mass
        textO = S.searchData{num,3};
        textO.Position = [S.ellipseData{1}{num,10},S.ellipseData{1}{num,11},...
                S.ellipseData{1}{num,12}];
        
        %writing the change into the geomdata and throughout
        
        delta = cell2mat(S.ellipseData{1}(:,[10:18]))-cell2mat(S.geomData(:,[10:18]));
        S.geomData = S.ellipseData{1};
        S.searchData{num,1} = cell2mat(S.ellipseData{1}(num,[10:12]));
        %all the frames... 
        
        
        for i=2:length(S.ellipseData);
            newEntry = cell2mat(S.ellipseData{i}(:,[10:18]))+delta;
            S.ellipseData{i}(:,[10:18]) = mat2cell(newEntry,...
                repmat(1,size(newEntry,1),1),...
                repmat(1,1,size(newEntry,2)));
        end
        %writing S back to glocal space
        
    setGlobalS(S);
    assignin('base','changedFiltMatrix',S.ellipseData);
    assignin('base','crashLabels',S.outputData(:,4));
    assignin('base','S',S);
     
function changeVisulazation(type,cMap)
    
     S = getGlobalS;
     pSp = [[1:numel(S.visTypes)],1];
     if strcmp(type,'')
        
        [~,loc] = ismember(S.currVisType,S.visTypes);
        newType  = S.visTypes(pSp(loc+1));
        S.currVisType = newType;
        eval(['S.currentColors = S.',S.colorSpaces{pSp(loc+1)},';']);
        type = newType;
     else
         
        [~,loc] = ismember(type,S.visTypes);
        newType  = S.visTypes(pSp(loc+1));
        S.currVisType = newType;
        eval(['S.currentColors = S.',S.colorSpaces{pSp(loc+1)},';']);
        
%         if strcmp(S.currVisType,'colorMap')
%             type = 'colors';
%         else
%             type = 'colorMap'; 
%         end
     end
     if ~strcmp('colorMap',type)
        for i=1:size(S.outputData,1);
            S.outputData{i,2}.FaceColor = S.currentColors(i,:);
            
        end
        %S.currVisType = 'colors';
     else
       for i=1:size(S.outputData,1);
            S.outputData{i,2}.FaceColor = 'flat';
            
            if ~strcmp(cMap,'')
                colormap(cMap);
            end
            %S.currVisType = 'colorMap';
       end 
         
     end
     setGlobalS(S);
 
function changeLabels(S)
  if S.colNum == 4
      S.colNum = 5;
  elseif S.colNum == 5
      S.colNum = 4;
  end
  
  for i=1:size(S.outputData,1);
    S.outputData{i,3}.String = S.outputData{i,S.colNum};
  end
  setGlobalS(S);
  
function [S] = toggleStackOn(S)
        
        if S.toggleV == false
           S.hSlice = slice(S.stack,S.xpos,S.ypos,S.zpos,'Parent',S.axes{1});
           set(S.hSlice,'EdgeColor','none',...
           'FaceAlpha',0.8);
           S.colorAx = S.axes{1};
            %alpha('color');
            %alphamap('rampdown')
            %alphamap('increase',.1)
            colormap(S.colorAx,jet);
            %colormap(ax1,jet);
            %colormap jet;
            xlim(S.axes{1},S.xRange);
            ylim(S.axes{1},S.yRange);
            zlim(S.axes{1},S.zRange);
            %lightHandle.Visible = 'off';
            %lightHandle.AmbientStrength = 0.3;
            %lightHandle.DiffuseStrength = 0.8;
            if S.firstSwitch == 0
                S.colorAx.CLim = [1,1000];
                S.lowerDRLim = 1;
                S.upperDRLim = 1000;
                S.dataAx = S.colorAx;
            end            
            if S.firstSwitch == 1
               S.colorRange = S.colorAx.CLim;
               S.firstSwitch = 0;
               S.lowerDRLim = S.colorRange(1);
               S.upperDRLim = S.colorRange(2);
               S.dataAx = S.colorAx;
            end
            
       S.toggleV = true;
       end
       setGlobalS(S);
        
    
 function [S] = toggleStackOff(source,callbackdata)
      
      S = getGlobalS;
      if S.toggleV == true
      delete(S.hSlice);
           %lightHandle.Visible = 'on';
           %lightHandle.AmbientStrength = 1;
           %lightHandle.DiffuseStrength = 1;
           
      colormap(S.colorAx,cool); % not sure if colorAx ok
      S.colorAx.CLim = S.axes{1}.ZLim;
      S.toggleV = false;
      setGlobalS(S);
      end  

function zSlicing(S,val)
 
 if val == 0 
    %[S] = toggleStackOff(S)
    S.xpos = 0;
    S.ypos = 0;
    S.zpos = S.zSlice;
    %[S] = toggleStackOn(S);
    %switch on 
    
    %confine the Z range to the slice
    for i=1:size(S.outputData,1)
      
       if S.outputData{i,1}(3) > S.zSlice+2 || ...
               S.outputData{i,1}(3) < S.zSlice-2
          S.outputData{i,3}.String = '';
       else
           
          
          S.outputData{i,3}.String = S.outputData(i,S.colNum);
       end
    end
    if ~strcmp(S.zHandle,''  )
        delete(S.zHandle);
    end
        S.zHandle = slice(S.stack,S.xpos,S.ypos,S.zpos,'Parent',S.axes{1});
           set(S.zHandle,'EdgeColor','none',...
           'FaceAlpha',0.8);
           S.colorAx = S.axes{1};
           if S.firstSwitch == 0
                S.colorAx.CLim = [1,1000];
                S.lowerDRLim = 1;
                S.upperDRLim = 1000;
                S.dataAx = S.colorAx;
                colormap(S.colorAx,S.dataColorMap);
            end            
            if S.firstSwitch == 1
               S.colorRange = S.colorAx.CLim;
               S.firstSwitch = 0;
               S.lowerDRLim = S.colorRange(1);
               S.upperDRLim = S.colorRange(2);
               S.dataAx = S.colorAx;
               colormap(S.colorAx,S.dataColorMap);
            end
   
    increment = (S.zLim2Old-S.zLim1Old)/size(S.stack,3);
    S.axes{1}.ZLim = [S.zSlice-increment,S.zSlice+increment];
    % switch off the outside Text 
    S.zVal = 1;
   
 else
    S.axes{1}.ZLim = [S.zLim1Old,S.zLim2Old];
    %confine the Z range to the slice
    for i=1:size(S.outputData,1)
       S.outputData{i,3}.String = S.outputData{i,S.colNum};
       
    end
    S.zVal = 0; 
    handles = S.zHandle;
    delete(handles);
    
    S.zHandle = '';
    colormap(S.colorAx,S.dataColorMap); 
      S.colorAx.CLim = S.axes{1}.ZLim;
      S.toggleV = false;
      setGlobalS(S);

 end
 setGlobalS(S); 

function closestCorr()
    S = getGlobalS;
    n = S.currentNum;
    data = S.multipleYDataCorr;
    %remove nancols
    data(logical(sum(isnan(data),2)),:) = -2;
    data(:,logical(sum(isnan(data),1))) = [];
    corrs = corr(data');
    %corrs = corr(data', 'rows','complete');
    line = corrs(n,:);
    line(isnan(line)) = 0;
    line = (line+1)/2;
    inc = 1/64; %[1,-1]
    
    %[~,idx] = sort(line,'descend');
    %inc = 64/numel(idx);
    idx = round(line/inc);
    cm = jet;
    colors = cm(idx,:);
    for i=1:size(S.outputData,1);
        S.outputData{i,2}.FaceColor = colors(i,:);
        S.currVisType = 'colors';
    end
    S.corrColors = colors;
    S.currVisType = 'corrColors';
    S.currentColors = colors;
    setGlobalS(S);
    
function addNeuron()
    % prompt user to provide 3 neurons as reference point
        S = getGlobalS;
        addNrn = false;
        numRef = 3;
        %numRef = inputdlg('How many reference points?');
        %numRef = double(num2str(numRef{1}));
        disp(numRef);
        naming = true;
        iter = 0;
        sOld = S.currentNum;
        refPoints = [];
        changes = 0;
        S.outputData{sOld,2}.FaceColor = 'flat';
        S.outputData{sOld,2}.FaceAlpha = 0.6;
        
        while naming == true;
            pause(0.5);
            S = getGlobalS;
            if sOld ~= S.currentNum
            %detect changing S.currentNum;
                refPoints = [refPoints;S.currentNum];
                changes = changes +1;
                sOld = S.currentNum;
                disp('Change');
            end
            if changes == numRef
               addNrn = true;
               break
               
            end
            
            if iter > 400 || changes == numRef  %breaks after 20 sec or numRef chosen neurons
               if changes == numRef
                    addNrn = true;
              
               
                end
                
                break
            end
           iter = iter +1;
           setGlobalS(S);
        end
        
        S.outputData{S.currentNum,2}.FaceColor = 'flat';
        S.outputData{S.currentNum,2}.FaceAlpha = 0.6;
        if addNrn
        % calculate new x y z pos from the averages of the 
        xnew = mean(cell2mat(S.geomData(refPoints,10)));
        ynew = mean(cell2mat(S.geomData(refPoints,11)));
        znew = mean(cell2mat(S.geomData(refPoints,12)));
        lxnew = mean(cell2mat(S.geomData(refPoints,13)));
        lynew = mean(cell2mat(S.geomData(refPoints,14)));
        lznew = mean(cell2mat(S.geomData(refPoints,15)));
        rxnew = mean(cell2mat(S.geomData(refPoints,16)));
        rynew = mean(cell2mat(S.geomData(refPoints,17)));
        rznew = mean(cell2mat(S.geomData(refPoints,18)));

        S.outputData = vertcat(S.outputData,S.outputData(size(S.outputData,1),:));
        num = size(S.outputData,1);

        [eX,eY,eZ] = ellipsoid(xnew,ynew,znew,lxnew,lynew,lznew,S.vertexN);
        S.outputData{num,2} = surf(eX,eY,eZ,'Parent',S.axes{1});
        S.outputData{num,2}.FaceColor = [1,1,1];
        S.outputData{num,2}.EdgeColor = 'none';
        scatter(xnew,ynew,znew,'+','r','Parent',S.axes{1});
        rotate(S.outputData{num,2},...
            [1 0 0],radtodeg(rxnew),[xnew,ynew,znew]);
        rotate(S.outputData{num,2},...
            [0 1 0],radtodeg(rynew),[xnew,ynew,znew]);
        rotate(S.outputData{num,2},...
            [0 0 1],radtodeg(rznew),[xnew,ynew,znew]);
       S.outputData{num,2}.FaceAlpha = 0.6;
       S.outputData{num,3} = text(xnew,ynew,znew,...
           'new_nrn','Color',[0.913,0.913,0.2118],'FontSize',14,'Parent',S.axes{1});
       S.outputData{num,4} = 'new_nrn';
       uniId = [randsample('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1),...
           num2str(round(rand(1)*1000))];

       S.outputData{num,5} = uniId;
       S.outputData{num,1} = [xnew,ynew,znew];
        disp('asdfas');
      line = S.ellipseData{1}(size(S.ellipseData{1},1),:);
      line([10:18]) = {[xnew] [ynew] [znew] [lxnew] [lynew] [lznew] [rxnew] [rynew] [rznew]};
      line([19:length(line)]) = {[nan]};
      S.geomData = vertcat(S.geomData,line);
      S.multipleYDataCorr = vertcat(S.multipleYDataCorr,...
          repmat(nan,1,size(S.multipleYDataCorr,2)));
      S.multipleLabels = vertcat(...
        S.multipleLabels,'new_nrn');
      S.searchData = S.outputData(:,[1:3]);
      for i=1:size(S.ellipseData,1)
        xnew = mean(cell2mat(S.ellipseData{1}(refPoints,10)));
        ynew = mean(cell2mat(S.ellipseData{1}(refPoints,11)));
        znew = mean(cell2mat(S.ellipseData{1}(refPoints,12)));
        line = S.ellipseData{i}(size(S.ellipseData{i},1),:);
        line([10:12]) = {[xnew] [ynew] [znew]};
        line([19:length(line)]) = {[nan]};
         S.ellipseData{i} = vertcat(S.ellipseData{i},line); 
      end
      %{'currentColors','userColors','corrColors'};
      S.currentColors = [S.currentColors;[0 0 0]]; % new neurons are black
      S.userColors = [S.userColors;[0 0 0]];
      S.corrColors = [S.corrColors;[0 0 0]];
      
      
      S.currentNum = num;
      S.xpos = xnew;
      S.ypos = ynew;
      S.zpos = znew;
      S = redrawPlots(S);

      setGlobalS(S);
      updateGUIstate(S);

      %safety dump in base workspace;
      assignin('base','changedFiltMatrix',S.ellipseData);
      assignin('base','crashLabels',S.outputData(:,4));%??????
      assignin('base','S',S);
   end   
    % set a sphere
    % add empty entries for the sphere in 
    % propagate thourgh all variables
function S = redrawPlots(S)
    %heatmap--------------------------------------------------------------
    % content.....
    S.axes{2}.Children(2).CData = ...
          rand(4);
    S.axes{2}.Children(2).CData = ...
          S.multipleYDataCorr;
    S.axes{2}.YLim = [0.5 size(S.multipleYDataCorr,1)+0.5];
    S.axes{2}.XLim = [1,size(S.multipleYDataCorr,2)];
    % frame.....
    S.handleFrame.XData = [0.5,size(S.multipleYDataCorr,2),size(S.multipleYDataCorr,2),0.5,0.5];
    S.handleFrame.YData = [S.currentNum-0.5,S.currentNum-0.5,S.currentNum+0.5,S.currentNum+0.5,S.currentNum-0.5];
    S.handleDat.YData = S.multipleYDataCorr(S.currentNum,:);
    %dynamically scale the fontSize if possible
    % Labels.....
    set(S.axes{2}, 'YTick',[1:size(S.multipleYDataCorr,1)],...
        'YTickLabel',S.outputData(:,4),'fontsize',12);

    
    function formUpOutput
    S = getGlobalS;
    % put the old (japanese) intensities in .backgroundData.oldIntensities (check var name) 
    % propagate labels also into profileObject for output
    % make sure that the old labels and the assigned labels are
    % consistently used throughout the code and output
    
