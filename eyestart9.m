function eyestart9
clear 
imaqreset 
setGlobalbbe1(0);
setGlobalFocus(0);
setGlobalCal(0);
setGlobalbb(0);
setGlobalBdr1(0);
setGlobalBdr2(0);
setGlobalCoefDp(0);
setGlobalCoefDp2(0);
setGlobalcropi(1);
setGlobalTbn(0.2);
setGlobalTbn2(0.2);
% profile on
handles.count=1;
disp('Reading parameters....')

MLmatC=matfile('MLeyecam_C.mat','Writable',true);
MLmatE=matfile('MLeyecam_E.mat','Writable',true);


%% Replace with camera parameters
% FIELDmat = matfile of field camera intrinsic/extrinsic parameters
% FCparams= matfile of pupil cameras (Left and Right) intrinsic/extrinsic parameters
% R = right, L = left

% setGlobalIMP(FIELDmat.imp)
% setGlobalFCparams(FIELDmat);
% setGlobalCPL(RLmat);
% setGlobalCPR(RLmat);

%% camera extrinsics
% setGlobalRL(RLmat);
% setGlobalRR(RLmat);
% setGlobalTL(RLmat);
% setGlobalTR(RLmat);


%% Camera assignment
camobj=imaqhwinfo('winvideo');

n=1;
while n<=length(camobj.DeviceIDs)
    camname(n)=string(camobj.DeviceInfo(n).DeviceName);
    n=n+1;
end

wc=find(camname=="HBVCAM Camera");
pupc=find(camname=="USB2.0 Camera");

disp('Opening Cameras...')
handles.vid1 = videoinput('winvideo',pupc(1),'MJPG_320x240');
handles.vid2 = videoinput('winvideo',pupc(2),'MJPG_320x240');
triggerconfig(handles.vid1,'manual');
triggerconfig(handles.vid2,'manual');
start(handles.vid1); start(handles.vid2); %//////// necessary?

disp('Building GUI...')

%% INPUT INTERFACE
% Create a figure and axes
figure
    I1 = getsnapshot(handles.vid1);
    I2 = getsnapshot(handles.vid2);
imshow(I1)
[i1,a]=imcrop(I1);
setGlobalbbe1(a)
setGlobalxx1(1)
setGlobalxx2(1)
[i2,b]=imcrop(I2);
setGlobalbbe2(b)

% 
handles.figH = figure('Name','Eye-Tracker - v1.0', 'color', [0.1 0.1 0.1], 'Position', [463 219 460 206], 'ToolBar', 'none', 'MenuBar', 'none','Resize', 'off');
handles.figH.Units = 'pixels';
% 
handles.ax1=axes('Parent',handles.figH,...
    'Position',[0.0173757763975154 0.309963099630996 0.480450310559006 0.668420681065748]);
set(handles.ax1,'Color',[0.149019607843137 0.149019607843137 0.149019607843137]);
imshow(imread('LEL.png'),'Parent',handles.ax1);
% 
handles.ax2 = axes('Parent',handles.figH,...
    'Position',[0.510854037267081 0.306273062730627 0.480450310559006 0.668420681065748]);%667256349034077]);
set(handles.ax2,'Color',[0.149019607843137 0.149019607843137 0.149019607843137])
imshow(imread('REL.png'),'Parent',handles.ax2);

%% LEFT PUPIL
handles.vidRes = handles.vid1.VideoResolution;
handles.nBands = handles.vid1.NumberOfBands;
handles.roiL = vision.CascadeObjectDetector('LeftEye'); %LeftEye

disp('Begining eye-tracker...')
n=1;
while n==1
    bbe1=[];
    x1=[];
    BB1=[];
    I1 = getsnapshot(handles.vid1);

            [PUPrealCordX1, PUPrealCordY1, bbx1, Pbws111, i1] = PupSegmStart(I1,getGlobalbbe1,getGlobalxx1);
         
            try
                imagePoints1 = [bbx1(1:2); ...
                    bbx1(1) + bbx1(3), bbx1(2)];
                
                % Get the world coordinates of the corners
                worldPoints1 = pointsToWorld(getGlobalCPR, getGlobalRR, getGlobalTR, imagePoints1);
                
                % Compute the diameter in millimeters.
                d = worldPoints1(2, :) - worldPoints1(1, :);
                setGlobalPupECm(hypot(d(1), d(2)));
            catch
                setGlobalPupECm(0)
            end

            
                cla(handles.ax1, 'reset');
                imshowpair(i1,Pbws111,'Parent',handles.ax1);
                hold on
                n=2;

        end
        
%% RIGHT PUPIL
vidRes = handles.vid2.VideoResolution;
nBands = handles.vid2.NumberOfBands;

n=1;
while n<=1
    x2=[];
    bbe2=[];
    I2 = getsnapshot(handles.vid2);
            
            [PUPrealCordX2, PUPrealCordY2, bbx2, Pbws222, i2] = PupSegmStart2(I2,getGlobalbbe2,getGlobalxx2);
            
            try
                imagePoints2 = [bbx2(1:2); ...
                    bbx2(1) + bbx2(3), bbx2(2)];
                
                worldPoints2 = pointsToWorld(getGlobalCPL, getGlobalRL, getGlobalTL, imagePoints2);
                d = worldPoints2(2, :) - worldPoints2(1, :);
                setGlobalPupDCm(hypot(d(1), d(2)));
            catch
                setGlobalPupDCm(0)
            end
            
                cla(handles.ax2, 'reset');
                imshowpair(i2,Pbws222,'Parent',handles.ax2);
                hold on
                n=2;

        end


handles.roiR = vision.CascadeObjectDetector('RightEye');
handles.a=0; 
handles.vCount=1; 
handles.Eyeseg=1;
handles.Eyes=1;
handles.Cal=1; 
setGlobalqr2(1);
handles.zzz=0;
handles.zz=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  BUTTONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.focusL = uicontrol('Style', 'popup',...
    'String', {'Select one option below', 'Reset pupil segmentation', 'Confirm pupil segmentation'},...
    'Position', [62 43 120 20],...
    'Callback', @setmap);

handles.incX = uicontrol('Style', 'pushbutton', 'String', '+',...
    'Position', [42 43 20 20],...
    'TooltipString','Increase X',...
    'Interruptible','on',...
    'BackgroundColor',[0 1 0],'Callback',@incX);

handles.decX = uicontrol('Style', 'pushbutton', 'String', '-',...
    'Position', [42 21 20 20],...
    'TooltipString','Decrease X',...
    'Interruptible','on',...
    'BackgroundColor',[0 1 0],'Callback',@decX);

handles.incY = uicontrol('Style', 'pushbutton', 'String', '+',...
    'Position', [22 43 20 20],...
    'TooltipString','Increase Y',...
    'Interruptible','on',...
    'BackgroundColor',[0 0 1],'Callback',@incY);

handles.decY = uicontrol('Style', 'pushbutton', 'String', '-',...
    'Position', [22 21 20 20],...
    'TooltipString','Decrease Y',...
    'Interruptible','on',...
    'BackgroundColor',[0 0 1],'Callback',@decY);


%% WIDHT HEIGHT // 1
handles.incH = uicontrol('Style', 'pushbutton', 'String', '+',...
    'Position', [182 43 20 20],...
    'TooltipString','Increase H',...
    'Interruptible','on',...
    'BackgroundColor',[0 1 1],'Callback',@incH);

handles.decH = uicontrol('Style', 'pushbutton', 'String', '-',...
    'Position', [182 21 20 20],...
    'TooltipString','Decrease H',...
    'Interruptible','on',...
    'BackgroundColor',[0 1 1],'Callback',@decH);

handles.incH = uicontrol('Style', 'pushbutton', 'String', '+',...
    'Position', [202 43 20 20],...
    'TooltipString','Increase W',...
    'Interruptible','on',...
    'BackgroundColor',[1 0 1],'Callback',@incW);

handles.decH = uicontrol('Style', 'pushbutton', 'String', '-',...
    'Position', [202 21 20 20],...
    'TooltipString','Decrease W',...
    'Interruptible','on',...
    'BackgroundColor',[1 0 1],'Callback',@decW);

handles.incX2 = uicontrol('Style', 'pushbutton', 'String', '+',...
    'Position', [265 43 20 20],...
    'TooltipString','Increase X',...
    'Interruptible','on',...
    'BackgroundColor',[0 1 0],'Callback',@incX2);

handles.decX2 = uicontrol('Style', 'pushbutton', 'String', '-',...
    'Position', [265 21 20 20],...
    'TooltipString','Decrease X',...
    'Interruptible','on',...
    'BackgroundColor',[0 1 0],'Callback',@decX2);

handles.incY2 = uicontrol('Style', 'pushbutton', 'String', '+',...
    'Position', [245 43 20 20],...
    'TooltipString','Increase Y',...
    'Interruptible','on',...
    'BackgroundColor',[0 0 1],'Callback',@incY2);

handles.decY2 = uicontrol('Style', 'pushbutton', 'String', '-',...
    'Position', [245 21 20 20],...
    'TooltipString','Decrease Y',...
    'Interruptible','on',...
    'BackgroundColor',[0 0 1],'Callback',@decY2);

handles.incH2 = uicontrol('Style', 'pushbutton', 'String', '+',...
    'Position', [405 43 20 20],...
    'TooltipString','Increase H',...
    'Interruptible','on',...
    'BackgroundColor',[0 1 1],'Callback',@incH2);

handles.decH2 = uicontrol('Style', 'pushbutton', 'String', '-',...
    'Position', [405 21 20 20],...
    'TooltipString','Decrease H',...
    'Interruptible','on',...
    'BackgroundColor',[0 1 1],'Callback',@decH2);

handles.incH2 = uicontrol('Style', 'pushbutton', 'String', '+',...
    'Position', [425 43 20 20],...
    'TooltipString','Increase W',...
    'Interruptible','on',...
    'BackgroundColor',[1 0 1],'Callback',@incW2);

handles.decH2 = uicontrol('Style', 'pushbutton', 'String', '-',...
    'Position', [425 21 20 20],...
    'TooltipString','Decrease W',...
    'Interruptible','on',...
    'BackgroundColor',[1 0 1],'Callback',@decW2);


handles.focusR = uicontrol('Style', 'popup',...
    'String', {'Select one option below', 'Reset pupil segmentation', 'Confirm pupil segmentation'},...
    'Position', [285 41 120 20],...
    'Callback', @setmap);
    
handles.pare = uicontrol('Style', 'pushbutton', 'String', 'Proceed',...
    'Position', [415 1 47 20],...
    'TooltipString','Start Eye-tracker',...
    'Interruptible','on',...
    'BackgroundColor',[0 1 0],'Callback',@stopi);

handles.cropEu = uicontrol('Style', 'pushbutton', 'String', '+',...
    'Position', [88 21 20 20],...
    'TooltipString','Increase',...
    'Interruptible','on',...
    'BackgroundColor',[1 0 0],'Callback',@Bdr1u);

handles.cropEd = uicontrol('Style', 'pushbutton', 'String', '-',...
    'Position', [108 21 20 20],...
    'TooltipString','Decrease',...
    'Interruptible','on',...
    'BackgroundColor',[1 0 0],'Callback',@Bdr1d);

handles.cropEr = uicontrol('Style', 'pushbutton', 'String', 'R',...
    'Position', [128 21 20 20],...
    'TooltipString','Reset',...
    'Interruptible','on',...
    'BackgroundColor',[1 0 0],'Callback',@Bdr1r);

handles.Tbnu = uicontrol('Style', 'pushbutton', 'String', 'T+',...
    'Position', [224 150 20 20],...
    'TooltipString','Increase',...
    'Interruptible','on',...
    'BackgroundColor',[1 0 0],'Callback',@Tbnu);
handles.Tbnd = uicontrol('Style', 'pushbutton', 'String', 'T-',...
    'Position', [224 130 20 20],...
    'TooltipString','Decrease',...
    'Interruptible','on',...
    'BackgroundColor',[1 0 0],'Callback',@Tbnd);


handles.Tbnu2 = uicontrol('Style', 'pushbutton', 'String', 'T+',...
    'Position', [224 110 20 20],...
    'TooltipString','Increase',...
    'Interruptible','on',...
    'BackgroundColor',[1 0 0],'Callback',@Tbnu2);
handles.Tbnd2 = uicontrol('Style', 'pushbutton', 'String', 'T-',...
    'Position', [224 90 20 20],...
    'TooltipString','Decrease',...
    'Interruptible','on',...
    'BackgroundColor',[1 0 0],'Callback',@Tbnd2);



handles.cropDu = uicontrol('Style', 'pushbutton', 'String', '+',...
    'Position', [324 21 20 20],...
    'TooltipString','Increase',...
    'Interruptible','on',...
    'BackgroundColor',[1 0 0],'Callback',@Bdr2u);

handles.cropDd = uicontrol('Style', 'pushbutton', 'String', '-',...
    'Position', [344 21 20 20],...
    'TooltipString','Decrease',...
    'Interruptible','on',...
    'BackgroundColor',[1 0 0],'Callback',@Bdr2d);

handles.cropDr = uicontrol('Style', 'pushbutton', 'String', 'R',...
    'Position', [364 21 20 20],...
    'TooltipString','Reset',...
    'Interruptible','on',...
    'BackgroundColor',[1 0 0],'Callback',@Bdr2r);
   


disp('Loading complete!')

% profile on
    function setmap(~,~)
                       
        if get(handles.focusL, 'Value')==2
            handles.zz=0;
            handles.queryroi=1;
            while handles.queryroi==1
                I11 = getsnapshot(handles.vid1);
                bbe11 = step(handles.roiL, I11);
                [x11,~,~]=size(bbe11);
                if ~isempty(bbe11)
                    BB11=bbe11(x11,:,:);
                    
                    if BB11(3)>50 && BB11(3)<90 && BB11(4)>30 && BB11(4)<70
                        [~, ~, bbx1, Pbws111, i11] = PupSegmStart(I11,bbe11,x11);
                        cla(handles.ax1,'reset');

                        imshowpair(i11,Pbws111,'Parent',handles.ax1)
                        hold on
                        
                        choice1 = questdlg('The Eye is being properly displayed?', ...
                            'Focus of the eye', ...
                            'Yes','No','No');
                        
                        % Handle response
                        switch choice1
                            case 'Yes'
                                handles.queryroi = 0;
                                handles.Eyeseg=0;
                                disp('Camera #1 display: Ok')
                                handles.focusL.Value=1;
                                setGlobalxx1(x11);
                                setGlobalbbe1(bbe11);
                                handles.zz=1;
                                fprintf('CORRECT Lx: #%g \n', char(BB11(3)))
                                fprintf('CORRECT Ly: #%g \n', char(BB11(4)))
                                MLmatC.BB1_3(length(MLmatC.BB1_3)+1,1)=BB11(3);
                                MLmatC.BB1_4(length(MLmatC.BB1_4)+1,1)=BB11(4);  
                                MLmatC.i1(length(MLmatC.i1)+1,1)={i11}; 
                                setGlobalPicE(i11)
                                aaa=getGlobalbbe1;
                                setGlobalMy(1)

                                
                            case 'No'
                                MLmatE.BB1_3(length(MLmatE.BB1_3)+1,1)=BB11(3);
                                MLmatE.BB1_4(length(MLmatE.BB1_4)+1,1)=BB11(4);  
                                MLmatE.i1(length(MLmatE.i1)+1,1)={i11}; 
                                handles.queryroi = 1;
                        end
                    end
                end
            end
        end
        
        if get(handles.focusR, 'Value')==2
            
            handles.queryroi=1;
            while handles.queryroi==1
                handles.zzz=0;
                I22 = getsnapshot(handles.vid2);
                bbe22 = step(handles.roiL, I22);
                [x22,~,~]=size(bbe22);
                if ~isempty(bbe22)
                    BB22=bbe22(x22,:,:);
                    
                    if BB22(3)>50 && BB22(3)<90 && BB22(3)>30 && BB22(4)<70
                        [~, ~, bbx2, Pbws222, i22] = PupSegmStart2(I22,bbe22,x22);
                        cla(handles.ax2,'reset');
                        imshowpair(i22,Pbws222,'Parent',handles.ax2)
                        hold on
                        
                        choice2 = questdlg('The Eye is being properly displayed?', ...
                            'Focus of the eye', ...
                            'Yes','No','No');
                        
                        % Handle response
                        switch choice2
                            case 'Yes'
                                handles.queryroi = 0;
                                handles.Eyeseg=0;
                                disp('Camera #2 display: Ok')
                                handles.cutbb2=bbe22(x22,:,:);
                                handles.focusR.Value=1;
                                setGlobalxx2(x22);
                                setGlobalbbe2(bbe22);
                                handles.zzz=1;
                                fprintf('CORRECT Rx: #%g \n', char(BB22(3)))
                                fprintf('CORRECT Ry: #%g \n', char(BB22(4)))
                                fprintf('Pup diam: #%g \n', bbx2)
                                MLmatC.BB2_3(length(MLmatC.BB2_3)+1,1)=BB22(3);
                                MLmatC.BB2_4(length(MLmatC.BB2_4)+1,1)=BB22(4);  
                                MLmatC.i2(length(MLmatC.i2)+1,1)={i22};  
                                MLmatC.I22(length(MLmatC.I22)+1,1)={I22}; 
                                MLmatC.I11(length(MLmatC.I11)+1,1)={I11}; 
                                aaa=getGlobalbbe2;
                                setGlobalPicD(i22)
                                setGlobalMy(0)

                            case 'No'
                                disp('')
                                MLmatE.BB2_3(length(MLmatE.BB2_3)+1,1)=BB22(3);
                                MLmatE.BB2_4(length(MLmatE.BB2_4)+1,1)=BB22(4);  
                                MLmatE.i2(length(MLmatE.i2)+1,1)={i22};  
                                handles.queryroi = 1;
                        end
                        
                    end
                end
            end
        end

                    
        %% PROCEED
        if get(handles.focusL, 'Value')==3
            handles.zz=1;
        end
        
        if get(handles.focusR, 'Value')==3
            handles.zzz=1;
        end
        

        
            if handles.zz==1 || handles.zzz==1
            z=1;
            while z==1
                if handles.zz==1
                    handles.data1 = getsnapshot(handles.vid1);  %LEFT PUPIL
                    [PUPrealCordX1, PUPrealCordY1, bbx1, Pbws111, i111] = PupSegmStart(handles.data1,getGlobalbbe1,getGlobalxx1);
                end
                
                if handles.zzz==1
                    handles.data2 = getsnapshot(handles.vid2);  %RIGHT PUPIL
                    [PUPrealCordX2, PUPrealCordY2, bbx2, Pbws222, i222] = PupSegmStart2(handles.data2,getGlobalbbe2,getGlobalxx2);
                end
                

                if getGlobalBdr1~=0
                    [a,b]=find(Pbws111==1);
                    n=1;
                    while n<length(a)
                        Pbws111(a(n)-getGlobalBdr1,b(n))=1;
                        Pbws111(a(n)+getGlobalBdr1,b(n))=1;
                        n=n+1;
                    end
                    
                    n=1;
                    while n<length(a)
                        Pbws111(a(n),b(n)+getGlobalBdr1)=1;
                        Pbws111(a(n),b(n)-getGlobalBdr1)=1;
                        n=n+1;
                    end
                    

                    if isempty(bbx1)
                        setGlobalPupECm(0)
                    else
                        
                        try
                            
                            imagePoints1 = [bbx1(1:2); ...
                                bbx1(1) + bbx1(3), bbx1(2)];
                            
                            worldPoints1 = pointsToWorld(getGlobalCPL, getGlobalRL, getGlobalTL, imagePoints1);
                            
                            d = worldPoints1(2, :) - worldPoints1(1, :);

                            setGlobalPupECm(hypot(d(1), d(2)));

                        catch
                            setGlobalPupECm(0)
                        end
                        
                    end
                    
                else
                    
                    if isempty(bbx1)
                        setGlobalPupECm(0)
                    else
                        try
                            imagePoints1 = [bbx1(1:2); ...
                                bbx1(1) + bbx1(3), bbx1(2)];                            
                            worldPoints1 = pointsToWorld(getGlobalCPL, getGlobalRL, getGlobalTL, imagePoints1);
                            d = worldPoints1(2, :) - worldPoints1(1, :);
                            setGlobalPupECm(hypot(d(1), d(2)));

                        catch
                            le=['Left Pupil BLINK?          ', datestr(now,'HH:MM:SS')];
                            disp(le)
                            setGlobalPupECm(0)
                        end
                    end
                end

                
                if getGlobalBdr2~=0
                    [a,b]=find(Pbws222==1);
                    
                    n=1;
                    while n<length(a)
                        Pbws222(a(n)-getGlobalBdr2,b(n))=1;
                        Pbws222(a(n)+getGlobalBdr2,b(n))=1;
                        n=n+1;
                    end
                    
                    n=1;
                    while n<length(a)
                        Pbws222(a(n),b(n)+getGlobalBdr2)=1;
                        Pbws222(a(n),b(n)-getGlobalBdr2)=1;
                        n=n+1;
                    end
                    
                    if isempty(bbx2)
                        setGlobalPupDCm(0)
                    else
                        try
                            imagePoints2 = [bbx2(1:2); ...
                                bbx2(1) + bbx2(3), bbx2(2)];
                            
                            worldPoints2 = pointsToWorld(getGlobalCPR, getGlobalRR, getGlobalTR, imagePoints2);
                            
                            d2 = worldPoints2(2, :) - worldPoints2(1, :);

                            setGlobalPupDCm(hypot(d2(1), d2(2)));
                            
                            
                        catch
                            setGlobalPupDCm(0)
                            re=['Right Pupil BLINK?          ', datestr(now,'HH:MM:SS')];
                            disp(re)
                        end
                    end
                    
                else
                    if isempty(bbx2)
                        setGlobalPupDCm(0)
                    else
                        try
                            imagePoints2 = [bbx2(1:2); ...
                                bbx2(1) + bbx2(3), bbx2(2)];
                            
                            worldPoints2 = pointsToWorld(getGlobalCPR, getGlobalRR, getGlobalTL, imagePoints2);
                            
                            d2 = worldPoints2(2, :) - worldPoints2(1, :);
                            setGlobalPupDCm(hypot(d2(1), d2(2)));

                        catch
                            setGlobalPupDCm(0)
                        end
                    end
                end
                

                
                if handles.zz==1

                    cla(handles.ax1, 'reset')
                    imshowpair(i111,Pbws111,'Parent',handles.ax1) %i111
                    hold on
                    text('Parent',handles.ax1,'FontSize',9,'FontName','OCR A Extended','Color','magenta',...
                        'String', strcat('L_D_i_a_m: ', num2str(getGlobalPupECm,4), ' mm'),...
                        'Position',[5 5 0]); 
                end

                
                if handles.zzz==1
                  
                    cla(handles.ax2, 'reset')
                    imshowpair(i222,Pbws222,'Parent',handles.ax2)%'method','diff', 'blend' //'ColorChannels' 'red-cyan'
                    hold on
                    text('Parent',handles.ax2,'FontSize',9,'FontName','OCR A Extended','Color', 'magenta',...
                        'String', strcat('R_D_i_a_m: ', num2str(getGlobalPupDCm,4), ' mm'),...
                        'Position',[5 5 0]);
                end
                drawnow
                        
                
            end
        end
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Tbnu(~,~)
setGlobalTbn(getGlobalTbn+0.05)
fprintf('Pup Threshold: %g \n', getGlobalTbn)
end

function Tbnd(~,~)
setGlobalTbn(getGlobalTbn-0.05)
fprintf('Pup Threshold: %g \n', getGlobalTbn)
end


function Tbnu2(~,~)
setGlobalTbn2(getGlobalTbn2+0.05)
fprintf('Pup Threshold: %g \n', getGlobalTbn2)
end

function Tbnd2(~,~)
setGlobalTbn2(getGlobalTbn2-0.05)
fprintf('Pup Threshold: %g \n', getGlobalTbn2)
end

function Bdr1u(~,~)
setGlobalBdr1(getGlobalBdr1+1)
fprintf('Increase Pup diam (L): %g \n', getGlobalBdr1)
end

function Bdr1d(~,~)
if getGlobalBdr1==0
    fprintf('Cannot decrease minimum threshold: %g \n', getGlobalBdr1)
else
    setGlobalBdr1(getGlobalBdr1-1)
    fprintf('Decrease Pup diam (L): %g \n', getGlobalBdr1)
end
end

function Bdr1r(~,~)
setGlobalBdr1(0)
fprintf('Reset points (L): %g \n', getGlobalBdr1)
end

function Bdr2u(~,~)
setGlobalBdr2(getGlobalBdr2+1)
fprintf('Increase Pup diam (R): %g \n', getGlobalBdr2)
end

function Bdr2d(~,~)
if getGlobalBdr2==0
    fprintf('Cannot decrease minimum threshold: %g \n', getGlobalBdr1)
else
    setGlobalBdr2(getGlobalBdr2-1)
    fprintf('Decrease Pup diam (R): %g \n', getGlobalBdr2)
end
end

function Bdr2r(~,~)
setGlobalBdr2(0)
fprintf('Reset points (R): %g \n', getGlobalBdr2)
end


    
%% X FUNCT
function incX(~,~)
aaa=getGlobalbbe1;
if aaa(:,1)>=300
    disp('Maximum X threshold reached')
    aaa(:,1)=300;
    setGlobalbbe1(aaa);
else
aaa(:,1)=aaa(:,1)+8;
setGlobalbbe1(aaa);
end
end
function incX2(~,~)
aaa=getGlobalbbe2;
if aaa(:,1)>=300
    disp('Maximum X threshold reached')
    aaa(:,1)=300;
    setGlobalbbe1(aaa);
else
aaa(:,1)=aaa(:,1)+8;
setGlobalbbe2(aaa);
end
end
function decX(~,~)
aaa=getGlobalbbe1;
if aaa(:,1)<=0
    disp('Maximum X threshold reached')
    aaa(:,1)=0;
setGlobalbbe1(aaa);   
else
aaa(:,1)=aaa(:,1)-8;
setGlobalbbe1(aaa);
end
end
function decX2(~,~)
aaa=getGlobalbbe2;
if aaa(:,1)<=0
    disp('Maximum X threshold reached')
    aaa(:,1)=0;
setGlobalbbe1(aaa);  
else
aaa(:,1)=aaa(:,1)-8;
setGlobalbbe2(aaa);
end
end

%% Y FUNCT
function incY(~,~)
aaa=getGlobalbbe1;
if aaa(:,2)+aaa(:,4)>240
    aaa(:,3)=240-aaa(:,2);
    disp('Maximum Y threshold reached')
else
aaa(:,2)=aaa(:,2)+8;
setGlobalbbe1(aaa);
end
end
function incY2(~,~)
aaa=getGlobalbbe2;
aaa(:,2)=aaa(:,2)+8;
setGlobalbbe2(aaa);
end
function decY(~,~)
aaa=getGlobalbbe1;
aaa(:,2)=aaa(:,2)-8;
setGlobalbbe1(aaa);
end
function decY2(~,~)
aaa=getGlobalbbe2;
aaa(:,2)=aaa(:,2)-8;
setGlobalbbe2(aaa);
end

%% H FUNCT
function incH(~,~)
aaa=getGlobalbbe1;
aaa(:,3)=aaa(:,3)+8;
setGlobalbbe1(aaa);
end
function incH2(~,~)
aaa=getGlobalbbe2;
aaa(:,3)=aaa(:,3)+8;
setGlobalbbe2(aaa);
end
function decH(~,~)
aaa=getGlobalbbe1;
aaa(:,3)=aaa(:,3)-8;
setGlobalbbe1(aaa);
end
function decH2(~,~)
aaa=getGlobalbbe2;
aaa(:,3)=aaa(:,3)-8;
setGlobalbbe2(aaa);
end

%% W FUNCT
function incW(~,~)
aaa=getGlobalbbe1;
aaa(:,4)=aaa(:,4)+8;
setGlobalbbe1(aaa);
end
function incW2(~,~)
aaa=getGlobalbbe2;
aaa(:,4)=aaa(:,4)+8;
setGlobalbbe2(aaa);
end
function decW(~,~)
aaa=getGlobalbbe1;
aaa(:,4)=aaa(:,4)-8;
setGlobalbbe1(aaa);
end
function decW2(~,~)
aaa=getGlobalbbe2;
aaa(:,4)=aaa(:,4)-8;
setGlobalbbe2(aaa);
end


function stopi(~,~)

answer = questdlg('Are you sure you want to proceed?', ...
    'Proceed to Eye-tracker', ...
    'Yes','No','No');

% Handle response
switch answer
    case 'Yes'
        MLmat11=matfile('MLmat1.mat','Writable',true);
        MLmat22=matfile('MLmat2.mat','Writable',true);

        x1=getGlobalxx1; bbe1=getGlobalbbe1;
        valsml1=bbe1(x1,:,:);
        MLmat11.BB1_3(length(MLmat11.BB2_3)+1,1)=valsml1(3);
        MLmat11.BB1_4(length(MLmat11.BB2_4)+1,1)=valsml1(4);        
        MLmat11.thresholdp(length(MLmat11.i2)+1,1)=getGlobalTbn;
        
        x2=getGlobalxx2; bbe2=getGlobalbbe2;
        valsml2=bbe2(x2,:,:);
        disp('ahoy')
        MLmat22.BB2_3(length(MLmat22.BB2_3)+1,1)=valsml2(3);
        MLmat22.BB2_4(length(MLmat22.BB2_4)+1,1)=valsml2(4);
        MLmat22.thresholdp(length(MLmat22.i2)+1,1)=getGlobalTbn;

        EYEmat = matfile('C:\dados\eye.mat','Writable',true);
        EYEmat.x1=getGlobalxx1;
        EYEmat.x2=getGlobalxx2;
        EYEmat.Bdr1=getGlobalBdr1;
        EYEmat.Bdr2=getGlobalBdr2;  
        EYEmat.Tbn=getGlobalTbn;          
        EYEmat.CPR=getGlobalCPR;   
        EYEmat.CPL=getGlobalCPL;   
        EYEmat.RL=getGlobalRL;
        EYEmat.RR=getGlobalRR; 
        EYEmat.TL=getGlobalTL;           
        EYEmat.TR=getGlobalTL;    
               
        clc
        clear
        imaqreset
        close
        
        
    case 'No'
        
end
end