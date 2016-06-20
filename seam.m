function varargout = seam(varargin)
% SEAM MATLAB code for seam.fig
%      

% Edit the above text to modify the response to help seam

% Last Modified by GUIDE v2.5 20-Jun-2016 00:36:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @seam_OpeningFcn, ...
                   'gui_OutputFcn',  @seam_OutputFcn, ...
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


% --- Executes just before seam is made visible.
function seam_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to seam (see VARARGIN)

% Choose default command line output for seam
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes seam wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = seam_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Browse.
function Browse_Callback(hObject, eventdata, handles)
% hObject    handle to Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile({'*.png';'*.jpg';'*.bmp';}, 'Please select an image');
if isequal(filename,0) || isequal(pathname,0)
    disp('User pressed cancel')
else
    oriImage=imread(filename);
    axes(handles.axes1);
    cla(handles.axes1, 'reset');
    imshow(oriImage);   
    set( handles.OriginalX, 'string', strcat('X:', num2str(size(oriImage, 1))) );
    set( handles.OriginalY, 'string', strcat('Y:', num2str(size(oriImage, 2))) );
    handles.oriImage=oriImage;
    handles.deleteMask = false(size(oriImage, 1), size(oriImage, 2));
    handles.remainMask = false(size(oriImage, 1), size(oriImage, 2));
end
    
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in SelectAreaDelete.
function SelectAreaDelete_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAreaDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
oriImage = im2double(handles.oriImage);
ax1 = handles.axes1;
axes(ax1);

pts = get_pencil_curve(ax1);
X = round(pts(:, 1));
Y = round(pts(:, 2));
X = X';
Y = Y';
X = [X X(1)];
Y = [Y Y(1)];
hold on;
h = fill(X,Y,'r');
set(h,'facealpha',.6);
deleteMask = roipoly(oriImage, X, Y);
handles.deleteMask = handles.deleteMask | deleteMask;

% Update handles structure
guidata(hObject, handles);

%{
% --- Executes on button press in SelectAreaRect.
function SelectAreaRect_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAreaRect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
oriImage = im2double(handles.oriImage);
[I, area] = imcrop(handles.axes1);
X = [area(1,1) area(1,1)+area(1,3) area(1,1)+area(1,3) area(1,1) area(1,1)];
Y = [area(1,2) area(1,2) area(1,2)+area(1,4) area(1,2)+area(1,4) area(1,2)];
hold on;
plot(X,Y,'LineWidth',3);
h = fill(X,Y,'r');
set(h,'facealpha',.6);
area = ceil(area);
selectMask = false(size(oriImage, 1), size(oriImage, 2));
for i = area(1,2):area(1,2)+area(1,4)-1
    for j = area(1,1):area(1,1)+area(1,3)-1
        selectMask(i, j) = true;
    end
end
handles.imageMask = handles.imageMask | selectMask;

% Update handles structure
guidata(hObject, handles);
%}

% --- Executes on button press in SelectAreaRemain.
function SelectAreaRemain_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAreaRemain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

oriImage = im2double(handles.oriImage);
ax1 = handles.axes1;
axes(ax1);

pts = get_pencil_curve(ax1);
X = round(pts(:, 1));
Y = round(pts(:, 2));
X = X';
Y = Y';
X = [X X(1)];
Y = [Y Y(1)];
hold on;
h = fill(X,Y,'g');
set(h,'facealpha',.6);
remainMask = roipoly(oriImage, X, Y);
handles.remainMask = handles.remainMask | remainMask;

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in Clear.
function Clear_Callback(hObject, eventdata, handles)
% hObject    handle to Clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ax1 = handles.axes1;
axes(ax1);
cla(ax1, 'reset');
oriImage = im2double(handles.oriImage);
imshow(oriImage);
handles.deleteMask = false(size(oriImage, 1), size(oriImage, 2));
handles.remainMask = false(size(oriImage, 1), size(oriImage, 2));

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in Remove.
function Remove_Callback(hObject, eventdata, handles)
% hObject    handle to Remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes2);
energyOffset = handles.deleteMask * -50 + handles.remainMask * 50;
% TODO handle overlap case
oriImage = im2double(handles.oriImage);
set( handles.Message, 'string', 'Computing...' );
drawnow;
%disp(find(selectMask == true));
tic
newImage = objectRemoving(energyOffset, oriImage);
toc
imshow(newImage);
set( handles.Message, 'string', 'Done' );
handles.result = newImage;

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in AmplifyObject.
function AmplifyObject_Callback(hObject, eventdata, handles)
% hObject    handle to AmplifyObject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes2);
oriImage = im2double(handles.oriImage);
scale = str2double(get(handles.Scale, 'string'));
set( handles.Message, 'string', 'Computing...' );
drawnow;
%%%%Implement Object Amplify here ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
tic
newImage = contentAmplify( oriImage, scale);
toc
imshow(newImage);
%%%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set( handles.Message, 'string', 'Done' );
handles.result = newImage;

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in Resize.
function Resize_Callback(hObject, eventdata, handles)
% hObject    handle to Resize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes2);
oriImage = im2double(handles.oriImage);
energyOffset = handles.deleteMask * -50 + handles.remainMask * 50;
set( handles.Message, 'string', 'Computing...' );
drawnow;
newX = str2num(get(handles.NewX, 'string'));
newY = str2num(get(handles.NewY, 'string'));
tic
newImage = seamCarving([newX, newY], energyOffset, oriImage);
toc
imshow(newImage);
set( handles.Message, 'string', 'Done' );
handles.result = newImage;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in MoveObject.
function MoveObject_Callback(hObject, eventdata, handles)
% hObject    handle to MoveObject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes2);
oriImage = im2double(handles.oriImage);
energyOffset = handles.deleteMask * -50 + handles.remainMask * 50;
shift = str2num(get(handles.Shift, 'string'));
set( handles.Message, 'string', 'Computing...' );
drawnow;
%%%%Implement Object Moving here ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
tic
newImage = objectMoving( oriImage, energyOffset,shift);
toc
imshow( newImage);
%%%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set( handles.Message, 'string', 'Done' );
handles.result = newImage;

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imwrite(handles.result, 'result.png');
set( handles.Message, 'string', 'Image Saved' );

% --- Executes during object creation, after setting all properties.
function NewY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NewY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function NewX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NewX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Shift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Shift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Scale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
