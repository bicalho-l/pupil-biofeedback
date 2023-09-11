function pupball8b
delete(imaqfind)
imaqreset;
clc
clear
close all
disp('Please wait...')

%FCmat = field camera specs/intrinsics  
setGlobalIMP(FCmat.imp2)
setGlobalFCparams(FCmat.cameraParams);
setGlobalBttnfc(0);
setGlobalCounterp(1);
setGlobalCounterT(0);
setGlobalCounterO(0);
setGlobalCRPC(1)
setGlobalINIT(1);
setGlobalFieldc(0);
setGlobalFCshow(0);
setGlobalOculo(0);
setGlobalPT(0);
setGlobalRECORDpup(0);
setGlobalW8t(0);
setGlobalStopped(0)
setGlobalbttn2(1)
setGlobalf(1)
setGlobalPC(0)
setGlobalPupBL(0)


f = warndlg('Verifique se as tentativas nao serao sobrepostas','Warning');
%% INPUT INTERFACE
prompt={'Participant initials:','Baseline duration(s):','Trial:',};
name='Data';
numlines=1;
defaultanswer={'gml','60','1'};
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
answerDLG=inputdlg(prompt,name,numlines,defaultanswer,options);
setGlobalBL(answerDLG(2));
setGlobalbb(cell2mat(answerDLG(1)));
tt=answerDLG(3); tt=str2num(cell2mat(tt));
setGlobalTrial(tt)

%% SAVING SESSION
x1=getGlobalxx1; bbe1=getGlobalbbe1;
x2=getGlobalxx2; bbe2=getGlobalbbe2;
bdr1=getGlobalBdr1;
bdr2=getGlobalBdr2;
tbn=getGlobalTbn;
cpr=getGlobalCPR;
rr=getGlobalRR;
tr=getGlobalTR;
cpl=getGlobalCPL;
rl=getGlobalRL;
tl=getGlobalTL;
wavmat = matfile('beep3.mat');
handles.soundputt=importdata('putt.ogg');
handles.soundgo=wavmat.data;

path = ['C:\dados\', getGlobalbb, '\'];
path2 = ['C:\dados\', getGlobalbb, '\perfm'];
mkdir (path)
mkdir (path2)

if getGlobalTrial>=2
    ct=['Continuing last session on trial ',num2str(getGlobalTrial)];
    disp(ct)

    EYEmat = matfile(['C:\dados\',getGlobalbb,'_eye.mat']);
    setGlobalx1(EYEmat.x1);
    setGlobalx2(EYEmat.x2);
    setGlobalbbe1(EYEmat.bbe1);
    setGlobalbbe2(EYEmat.bbe2);
    setGlobalBdr1(EYEmat.bdr1);
    setGlobalBdr2(EYEmat.bdr2);
    setGlobalTbn(EYEmat.tbn)
    setGlobalCPR(EYEmat.cpr)
    setGlobalRR(EYEmat.rr)
    setGlobalTR(EYEmat.tr)
    setGlobalCPL(EYEmat.cpl)
    setGlobalRL(EYEmat.rl)
    setGlobalTL(EYEmat.tl)

else
    bb=getGlobalbb;
    save('EYEcal.mat','bb','x1','x2','bbe1','bbe2',...
        'bdr1','bdr2','tbn','cpr','rr','tr','cpl','rl','tl','-v7.3');
    movefile('EYEcal.mat', ['C:\dados\',getGlobalbb,'_eye.mat']);
    copyfile('getGlobalbb.m', ['C:\dados\',getGlobalbb,'\getGlobalbb.m'])
    copyfile('getGlobalTrial.m', ['C:\dados\',getGlobalbb,'\getGlobalTrial.m'])
end

%% BUILDING FILES
% HEAD
disp('Building Oculomotor files')
Ex=[];
Ey=[];
Dx=[];
Dy=[];
WCs=[];
tacox=[];
save('bfboculo.mat',...
    'Ex', 'Ey', 'Dx', 'Dy', 'tacox', ...
    '-v7.3');
n=1;
while n<=100
    copyfile('bfboculo.mat', ['C:\dados\',getGlobalbb,'_o_',num2str(n),'.mat']);
    n=n+1;
end


disp('Building Performance files')

%% CAMERA
% Camera assignments
camobj=imaqhwinfo('winvideo');
camobjs=length(camobj.DeviceIDs);

i=1;
while i<=camobjs
    camname(i)=string(camobj.DeviceInfo(i).DeviceName);
    i=i+1;
end

fc=find(camname=="HBV HD CAMERA");
pc=find(camname=="USB Camera");
pupc=find(camname=="USB2.0 Camera");
disp('Opening camera preview...')

delete(imaqfind)
imaqreset;
objects=imaqfind;
delete(objects)

handles.vid1 = videoinput('winvideo',pupc(1),'MJPG_320x240');
handles.vid2 = videoinput('winvideo',pupc(2),'MJPG_320x240');
handles.vid3 = videoinput('winvideo',fc,'MJPG_1280x720');
handles.vid5 = videoinput('winvideo',pc,'MJPG_320x240');

triggerconfig(handles.vid1,'manual');
triggerconfig(handles.vid2,'manual');
triggerconfig(handles.vid3,'manual');
triggerconfig(handles.vid5,'manual');

handles.vid1.ROIPosition = bbe1(x1,:,:);
handles.vid2.ROIPosition = bbe2(x2,:,:);
handles.vid3.ROIPosition = [3.51 75.51 1168.98 567.98];
handles.vid5.ROIPosition = [35.51 0.51 261 239.98];

start(handles.vid1); start(handles.vid2);
start(handles.vid3);
start(handles.vid5);

if length(webcamlist)~=4
    error('Please check USB connections')
else
    disp('Four cameras connected')
end

%% GUI
hFig = figure('Name','Eye-Tracker - v1.0', 'color', [0.3 0.3 0.3], 'Resize', 'off', 'ToolBar', 'none', 'MenuBar', 'none');
hFig.Position(3:4) = [280 210];

vidRes = handles.vid3.VideoResolution;
nBands = handles.vid3.NumberOfBands;
handleToImageInAxes1 = image( zeros(vidRes(2), vidRes(1), nBands) );
hold off

preview(handles.vid3, handleToImageInAxes1);
disp('Loading status: 100%')

% BUTTONS
handles.dropdownmenuGUI = uicontrol('Style', 'popup',...
    'String', {'Select one function below','Baseline','Scan Session','Biofeedback'},...
    'Position', [5 150 160 50],...
    'Callback', @setmapa2);
handles.pare = uicontrol('Style', 'pushbutton', 'String', 'Exit',...
    'Position', [5 5 100 20],...
    'TooltipString','Exit',...
    'Interruptible','on',...
    'BackgroundColor',[1 0 0],'Callback',@stopi);

handles.calM=0;
handles.blM=0;
handles.scanS=0;
handles.nfbT=0;
handles.ii=1;
setGlobalCal(0);
handles.parou = 0;


    function setmapa2(~,~)




        if get(handles.dropdownmenuGUI, 'Value')==2
            disp('Baseline')

            try
                delete(handles.startT);
                delete(handles.bttndesemp);
                delete(handles.bttnpupE);
                delete(handles.bttnpupD);
                delete(handles.bttnBFB);
            catch
            end

            try
                delete(handles.startSS);
                delete(handles.bttndesemp);
                delete(handles.bttnpupE);
                delete(handles.bttnpupD);
            catch
            end

            handles.baseline = uicontrol('Style', 'pushbutton', 'String', 'Start Baseline',...
                'Position', [5 52.5 50 20],...
                'BackgroundColor',[0 1 0], 'Callback',@baseL);

            handles.bttnpupE = uicontrol('Style', 'pushbutton', 'String', 'Pupil: L',...
                'Position', [56 52.5 50 20],...
                'BackgroundColor',[0.65,0.65,0.65], 'Callback',@pupE);

            handles.bttnpupD = uicontrol('Style', 'pushbutton', 'String', 'Pupil: R',...
                'Position', [107 52.5 50 20],...
                'BackgroundColor',[0.65,0.65,0.65], 'Callback',@pupD);

            setappdata(handleToImageInAxes1,'UpdatePreviewWindowFcn',@mypreview_fcn2);

        end


        if get(handles.dropdownmenuGUI, 'Value')==3
            % setGlobalRECORDpup(2)

            disp('Scan Session')
            try
                delete(handles.baseline);
                delete(handles.bttnpupD);
                delete(handles.bttnpupE);
            catch
            end

            try
                delete(handles.startT);
                delete(handles.bttndesemp);
                delete(handles.bttnpupE);
                delete(handles.bttnpupD);
                delete(handles.bttnBFB);
            catch
            end

            handles.startSS = uicontrol('Style', 'pushbutton', 'String', 'Start',...
                'Position', [230 65 50 20],...
                'BackgroundColor',[0 1 0], 'Callback',@startSS);

            handles.bttndesemp = uicontrol('Style', 'pushbutton', 'String', 'Performance',...
                'Position', [5 45 80 20],...
                'BackgroundColor',[0.65,0.65,0.65], 'Callback',@desemp);

            handles.bttnpupE = uicontrol('Style', 'pushbutton', 'String', 'Pupil: L',...
                'Position', [85 45 50 20],...
                'BackgroundColor',[0.65,0.65,0.65], 'Callback',@pupE);

            handles.bttnpupD = uicontrol('Style', 'pushbutton', 'String', 'Pupil: R',...
                'Position', [135 45 50 20],...
                'BackgroundColor',[0.65,0.65,0.65], 'Callback',@pupD);

        end


        if get(handles.dropdownmenuGUI, 'Value')==4

            disp('Biofeedback session')
            try
                delete(handles.baseline);
                delete(handles.bttnpupE);
                delete(handles.bttnpupD);
            catch
            end

            try
                delete(handles.startSS);
                delete(handles.bttndesemp);
                delete(handles.bttnpupE);
                delete(handles.bttnpupD);
            catch
            end

            handles.startT = uicontrol('Style', 'pushbutton', 'String', 'Start',...
                'Position', [5 65 50 20],...
                'BackgroundColor',[0 1 0], 'Callback',@startBFB);

            handles.bttndesemp = uicontrol('Style', 'pushbutton', 'String', 'Performance',...
                'Position', [5 45 80 20],...
                'BackgroundColor',[0.65,0.65,0.65], 'Callback',@desemp);

            handles.bttnpupE = uicontrol('Style', 'pushbutton', 'String', 'Pupil: L',...
                'Position', [85 45 50 20],...
                'BackgroundColor',[0.65,0.65,0.65], 'Callback',@pupE);

            handles.bttnpupD = uicontrol('Style', 'pushbutton', 'String', 'Pupil: R',...
                'Position', [135 45 50 20],...
                'BackgroundColor',[0.65,0.65,0.65], 'Callback',@pupD);

            handles.bttnBFB = uicontrol('Style', 'pushbutton', 'String', 'BFB Target',...
                'Position', [5 25 70 20],...
                'BackgroundColor',[0.85,0.85,0.85], 'Callback',@BFB);

        end


        function mypreview_fcn2(~,~,handleToImageInAxes1)

            handles.data4=getsnapshot(handles.vid3);

            if getGlobalFieldc==1 && getGlobalBttnfc==1
                cameraParams=getGlobalFCparams;
                handles.data3 = getsnapshot(handles.vid3); %FIELD CAM
                [im, newOrigin] = undistortImage(handles.data3, cameraParams, 'OutputView', 'full');
                I3=imadjust(im,[0.8 0.9],[]);
                I2=imadjust(im,[0.6 0.7],[]);
                I3=im2bw(I3);
                I2=im2bw(I2); I2=~I2;

                Pbws1 = bwpropfilt(I3, 'Area', [35, 190]); %20 90, 11 90, 6 90 2400 2700
                Pbws2 = bwpropfilt(I2, 'Area', [1200, 1800]); %20 90, 11 90, 6 90   49000 51000
                S2_1 = regionprops(Pbws1, 'BoundingBox');
                S2_2 = regionprops(Pbws2, 'BoundingBox');
                box1=S2_1.BoundingBox;
                box2=S2_2.BoundingBox;

                cameraParams=getGlobalFCparams;
                imp=getGlobalIMP;

                u=1; %/
                try
                    while u<=length(imp) %/
                        imp2=imp(u).s+newOrigin; %(dist2)
                        [R, t] = extrinsics(imp2, cameraParams.WorldPoints, cameraParams); %imp(u).s imagePoints(:,:,u) worldPoints

                        imagePoints1 = [box1(1:2); ...
                            box1(1) + box1(3), box1(2)];

                        imagePoints2 = [box2(1:2); ...
                            box2(1) + box2(3), box2(2)];

                        worldPoints1 = pointsToWorld(cameraParams, R, t, imagePoints1);
                        worldPoints2 = pointsToWorld(cameraParams, R, t, imagePoints2);

                        center1_image = box1(1:2) + box1(3:4)/2;
                        center2_image = box2(1:2) + box2(3:4)/2;

                        center1_world  = pointsToWorld(cameraParams, R, t, center1_image);
                        center2_world  = pointsToWorld(cameraParams, R, t, center2_image);

                        center1_world = [center1_world 0];
                        center2_world = [center2_world 0];
                        distanceToCamera(u) = norm(center1_world - center2_world);
                        u=u+1;
                    end
                catch
                    distanceToCamera(u)=0;
                    u=u+1;
                end

                distanceToCamera(distanceToCamera==0)=[];
                setGlobalDesemp(mean(distanceToCamera)/10)
                setGlobalFExp(datetime('now'))
                delete(handles.bttndesemp)
                disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
                msgFC=['Trial:  ',num2str(getGlobalTrial), '  Performance:  ',num2str(getGlobalDesemp)];
                disp(msgFC)
                disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')

                handles.fccam=figure;
                handles.axFC = axes('Parent',handles.fccam);
                imshowpair(Pbws1,Pbws2,'Parent',handles.axFC)

                if getGlobalf==1
                    try
                        delete(handles.startSS)
                    catch
                    end
                    try
                        delete(handles.startT)
                    catch
                    end

                    setGlobalf(0)
                end

                setGlobalFieldc(0)
                setGlobalBttnfc(0);
            end

            if getGlobalW8t==1
                setGlobalINIT(1);
                setGlobalOculo(1); %BEGIN OCULOMOT
                setGlobalCounterp(1);

                setGlobalCRPC(1) %get 1th frame pc cam
                setGlobalW8t(0);

                setGlobalTrial(getGlobalTrial+1);
                bt=['Begin trial:  ', num2str(getGlobalTrial), '          ', datestr(now,'HH:MM:SS')];
                disp(bt)

                if getGlobalTrial>1 && getGlobalStopped==1 %end of swing
                    setGlobalOculo(2); %SAVE OCULOMOTOR
                    setGlobalTrial(getGlobalTrial-1)

                end

            end



            if getGlobalINIT==1 | getGlobalINIT==3 

                handles.data1 = getsnapshot(handles.vid1);  
                handles.data2 = getsnapshot(handles.vid2);  
                if getGlobalp1==1
                    [PUPrealCordX1, PUPrealCordY1, bbx1, fot] = PupSegmStart0(handles.data1);
                    handles.figF=figure;
                    handles.ax0=axes('Parent',handles.figF);
                    imshow(fot,'Parent',handles.ax0)
                    setGlobalp1(0)
                else
                    [PUPrealCordX1, PUPrealCordY1, bbx1] = PupSegmStart0(handles.data1);
                end

                if getGlobalp2==1
                    [PUPrealCordX2, PUPrealCordY2, bbx2, fot2] = PupSegmStart02(handles.data2);
                    handles.figF=figure;
                    handles.ax0=axes('Parent',handles.figF);
                    imshow(fot2,'Parent',handles.ax0)
                    setGlobalp2(0)
                else
                    [PUPrealCordX2, PUPrealCordY2, bbx2] = PupSegmStart02(handles.data2);
                end

                try
                    imagePointsE = [bbx1(1:2); ...
                        bbx1(1) + bbx1(3), bbx1(2)];

                    worldPointsE = pointsToWorld(getGlobalCPL, getGlobalRL, getGlobalTL, imagePointsE);

                    dE = worldPointsE(2, :) - worldPointsE(1, :);

                    setGlobalPupECm(hypot(dE(1), dE(2)));
                    setGlobalPupECm2(getGlobalPupECm-getGlobalPupBL)

                catch
                    setGlobalPupECm(0)
                    le=['Left Pupil BLINK?          ', datestr(now,'HH:MM:SS')];
                    disp(le)

                end

                try
                    imagePointsD = [bbx2(1:2); ...
                        bbx2(1) + bbx2(3), bbx2(2)];

                    worldPointsD = pointsToWorld(getGlobalCPR, getGlobalRR, getGlobalTR, imagePointsD);

                    dD = worldPointsD(2, :) - worldPointsD(1, :);
                    setGlobalPupDCm(hypot(dD(1), dD(2)));
                    setGlobalPupDCm2(getGlobalPupDCm-getGlobalPupBL)
                catch
                    setGlobalPupDCm(0)
                    de=['Right Pupil BLINK?          ', datestr(now,'HH:MM:SS')];
                    disp(de)
                end
            end

            if getGlobalStopped==2
                handles.data5=getsnapshot(handles.vid5);
                handles.I=rgb2gray(handles.data5);
                handles.I=imadjust(handles.I,[0.9 1],[]);
                handles.I=im2bw(handles.I);

                S2_1 = regionprops(handles.I, 'Centroid', 'Area');

                cvBLOB=[];

                if length(S2_1)>=1

                    u=1;
                    while u <= length(S2_1)
                        cvBLOB(u)=S2_1(u).Area;
                        u=u+1;
                    end
                    [~,pos_target]=max(cvBLOB);

                    postargetX=S2_1(pos_target).Centroid(1);
                    setGlobalOr(postargetX)

                    if getGlobalCRPC==1
                        msgPC0=['Pos. inicial taco:  ',num2str(postargetX), '          ', datestr(now,'HH:MM:SS')];
                        disp(msgPC0)
                        disp('-> SWING <-')
                        sound(handles.soundgo)
                        t1=datetime('now');
                        setGlobalT1(t1)

                        setGlobalPT(postargetX)
                        setGlobalPT2(S2_1(pos_target).Centroid(2))
                        setGlobalCRPC(0)
                    end

                    if getGlobalPT>postargetX+10
                        msgPC=['End of swing:  ',num2str(postargetX),'          ', datestr(now,'HH:MM:SS')];
                        disp(msgPC)

                        handles.bttndesemp = uicontrol('Style', 'pushbutton', 'String', 'Performance',...
                            'Position', [5 45 80 20],...
                            'BackgroundColor',[0.65,0.65,0.65], 'Callback',@desemp);

                        handles.pccam=figure;
                        handles.axPC = axes('Parent',handles.pccam);
                        imshow(handles.I,'Parent',handles.axPC)

                        setGlobalFieldc(1); 
                        setGlobalStopped(1); 
                        setGlobalINIT(2); 
                        setGlobalPT(-1000) 
                    end
                end

                if getGlobalRECORDpup==3

                    if getGlobalTrial>=6

                        cd pontodecontrole
                        z=1;
                        findpc=dir;
                        while z<=length(findpc)
                            if findpc(z).isdir==0
                                handles.PC=findpc(z).name;
                            end
                            z=z+1;
                        end
                        cd ..
                        setGlobalPC(str2num(handles.PC))
                    end
                        
                        if round((getGlobalPupECm+getGlobalPupDCm)/2,1)-round(getGlobalPupBL,1)==getGlobalPC %getGlobalPC
                            setGlobalCounterT(getGlobalCounterT+1); %tempo de alcance
                            t3=datetime('now');
                            setGlobalTbfb(t3);
                            bfbframes=['BFB Count: ', num2str(getGlobalCounterT)];
                            disp(bfbframes)
                            sound(handles.soundputt)
                        end
                    end
                
            else
                setGlobalOr(0)
            end


            if getGlobalRECORDpup==2

                if getGlobalINIT==1
                    handles.Dpup(getGlobalCounterp)=getGlobalPupDCm;
                    handles.Dpup2(getGlobalCounterp)=getGlobalPupECm;
                    handles.Dpup0(getGlobalCounterp)=getGlobalPupDCm2;
                    handles.Dpup02(getGlobalCounterp)=getGlobalPupECm2;                    
                    setGlobalCounterp(getGlobalCounterp+1)
                end

                if getGlobalOculo==1
                    handles.tacox(getGlobalCounterO)=getGlobalOr;
                    handles.eyeEx(getGlobalCounterO)=PUPrealCordX1;
                    handles.eyeEy(getGlobalCounterO)=PUPrealCordY1;
                    handles.eyeDx(getGlobalCounterO)=PUPrealCordX2;
                    handles.eyeDy(getGlobalCounterO)=PUPrealCordY2;
                    setGlobalCounterO(getGlobalCounterO+1)
                end

                if getGlobalOculo == 2
                    Ex=handles.eyeEx;
                    Ey=handles.eyeEy;
                    Dx=handles.eyeDx;
                    Dy=handles.eyeDy;
                    tacox=handles.tacox;
                    arqq=[getGlobalbb,'_o_',num2str(getGlobalTrial),'.mat'];
                    disp('Saving oculomotor measures...')                   
                    t2=datetime('now'); setGlobalT2(t2);
                    MLmatO=matfile(arqq,'Writable',true);
                    MLmatO.Ex=Ex;
                    MLmatO.Ey=Ey;
                    MLmatO.Dx=Dx;
                    MLmatO.Dy=Dy;
                    MLmatO.tacox=tacox;
                    setGlobalTacox(length(find(tacox>0)))
                    setGlobalExp(length(Dx))
                    Ex=[]; Ey=[]; Dx=[]; Dy=[]; tacox=[];

                    disp('#######################################################################################################################')
                    so=['Oculomotor measures saved:  ', num2str(getGlobalCounterO),'          ', datestr(now,'HH:MM:SS')];
                    disp(so)
                    disp('#######################################################################################################################')
                    setGlobalCounterO(1)
                    t3=between(getGlobalT2,getGlobalFExp); t4=char(t3); posfbInterval=t4(end-8:end-1);
                    t3a=between(getGlobalT1,getGlobalT2); t4a=char(t3a); planningPeriod=t4a(end-8:end-1);


                    if str2num(posfbInterval(1))>=1
                        t6=posfbInterval(1); posfbInterval=[]; posfbInterval=str2num(t4(end-6:end-1))+str2num(t6)*60;
                    else
                        posfbInterval=str2num(t4(end-6:end-1));
                    end

                    if str2num(planningPeriod(1))>=1
                        t6a=planningPeriod(1); planningPeriod=[]; planningPeriod=str2num(t4a(end-6:end-1))+planningPeriod(t6a)*60;
                    else
                        planningPeriod=str2num(t4a(end-6:end-1));
                    end

                    disp('Wait for exposition time')
setGlobalExposicao(planningPeriod);
pause(num2str(getGlobalExposicao)*pi)
                    disp('Done.')
                    
                    handles=rmfield(handles,'eyeEx');
                    handles=rmfield(handles,'eyeEy');
                    handles=rmfield(handles,'eyeDx');
                    handles=rmfield(handles,'eyeDy');
                    setGlobalOculo(1);
                    setGlobalStopped(2); 

                    Perfm=getGlobalDesemp;
                    save('ssperf.mat', 'Perfm', 'posfbInterval', 'planningPeriod',...
                        '-v7.3');
                    movefile('ssperf.mat', ['C:\dados\',getGlobalbb,'\',getGlobalbb,'_perf_',num2str(getGlobalTrial),'.mat'])
                    Perfm=[]; t6=[]; posfbInterval=[]; planningPeriod=[];
                    setGlobalTrial(getGlobalTrial+1)
                end

                if getGlobalINIT==2
                    Dpup2=handles.Dpup2;
                    Dpup=handles.Dpup;
                    Dpup02=handles.Dpup02;
                    Dpup0=handles.Dpup0;

                    save('sspup.mat', 'Dpup2','Dpup', 'Dpup02','Dpup0', ...
                        '-v7.3');
                    movefile('sspup.mat', ['C:\dados\',getGlobalbb,'\',getGlobalbb,'_pup_',num2str(getGlobalTrial),'.mat'])

                    disp('#######################################################################################################################')
                    sp=['Pupil planning phase saved:', num2str(getGlobalCounterp),'          ', datestr(now,'HH:MM:SS')];
                    disp(sp)
                    disp('#######################################################################################################################')
                    Dpup2=[];
                    handles=rmfield(handles,'Dpup');
                    handles=rmfield(handles,'Dpup2');
                    handles=rmfield(handles,'Dpup0');
                    handles=rmfield(handles,'Dpup02');
                    setGlobalCounterp(1)
                    setGlobalINIT(3);

                    disp('-> PERFORMANCE <-')
                end

                %% END
                if getGlobalTrial==101
                    if getGlobalbttn2==1
                        fn = 'handel.mat';
                        mS = matfile(fn);
                        sound(mS.y);
                        setGlobalbttn2(0)

                        z=1;
                        while z<=100
                            movefile(['C:\dados\',getGlobalbb,'\',getGlobalbb,'_perf_',num2str(z),'.mat'], ['C:\dados\',getGlobalbb,'\perfm'])
                            z=z+1;
                        end

                    end
                end

            end
            
            if getGlobalRECORDpup==3 

                if getGlobalINIT==1
                    handles.Dpup3(getGlobalCounterp)=round((getGlobalPupDCm+getGlobalPupECm)/2,1);
                    handles.Dpup30(getGlobalCounterp)=round((getGlobalPupDCm2+getGlobalPupECm2)/2,1);
                    setGlobalCounterp(getGlobalCounterp+1)
                end

                if getGlobalOculo==1
                    handles.tacox(getGlobalCounterO)=getGlobalOr;
                    handles.eyeEx(getGlobalCounterO)=PUPrealCordX1;
                    handles.eyeEy(getGlobalCounterO)=PUPrealCordY1;
                    handles.eyeDx(getGlobalCounterO)=PUPrealCordX2;
                    handles.eyeDy(getGlobalCounterO)=PUPrealCordY2;
                    setGlobalCounterO(getGlobalCounterO+1)
                end

                if getGlobalOculo == 2

                    Ex=handles.eyeEx;
                    Ey=handles.eyeEy;
                    Dx=handles.eyeDx;
                    Dy=handles.eyeDy;
                    tacox=handles.tacox;

                    arqq=[getGlobalbb,'_o_',num2str(getGlobalTrial),'.mat'];
                    disp('Saving oculomotor measures...')
                    t1=datetime('now');
                    MLmatO=matfile(arqq,'Writable',true);
                    MLmatO.Ex=Ex;
                    MLmatO.Ey=Ey;
                    MLmatO.Dx=Dx;
                    MLmatO.Dy=Dy;
                    MLmatO.tacox=tacox;
                    Ex=[]; Ey=[]; Dx=[]; Dy=[];

                    disp('#######################################################################################################################')
                    so=['Oculomotor measures saved:  ', num2str(getGlobalCounterO),'          ', datestr(now,'HH:MM:SS')];
                    disp(so)
                    disp('#######################################################################################################################')
                    setGlobalCounterO(1)
                    t2=datetime('now'); setGlobalT2(t2); t3=between(getGlobalT1,getGlobalT2); t4=char(t3); posfbInterval=t4(end-8:end-1);
                    t3a=between(getGlobalT1,getGlobalT2); t4a=char(t3a); planningPeriod=t4a(end-8:end-1);e

                    if getGlobalTrial>=5
                        tbfb=between(getGlobalT2,getGlobalTbfb); tbfb2=char(tbfb); timeToStart=tbfb2(end-8:end-1);
                        if str2num(timeToStart(1))>=1
                            tbfba=timeToStart(1); timeToStart=[]; timeToStart=str2num(tbfb2(end-6:end-1))+timeToStart(tbfba)*60;
                        else
                            timeToStart=str2num(tbfb2(end-6:end-1));
                        end
                        TX4=['~ Biofeedback maintainance: ',num2str(getGlobalCounterT), ' s'];
                        TX3=['~ Time to start: ',num2str(timeToStart), ' s'];
                        disp(TX4)
                        disp(TX3)
                        BFBt=getGlobalCounterT;

                    else

                        if str2num(planningPeriod(1))>=1
                            t6a=planningPeriod(1); planningPeriod=[]; planningPeriod=str2num(t4a(end-6:end-1))+planningPeriod(t6a)*60;
                        else
                            planningPeriod=str2num(t4a(end-6:end-1));
                        end

                        disp('Wait for exposition time')
                        setGlobalExposicao(planningPeriod);
                        pause(num2str(getGlobalExposicao)*pi)
                        disp('Done.')

                    end


                    if str2num(posfbInterval(1))>=1
                        t6=posfbInterval(1); posfbInterval=[]; posfbInterval=str2num(t4(end-6:end-1))+str2num(t6)*60;
                    else
                        posfbInterval=str2num(t4(end-6:end-1));
                    end

                    if str2num(planningPeriod(1))>=1
                        t6a=planningPeriod(1); planningPeriod=[]; planningPeriod=str2num(t4a(end-6:end-1))+planningPeriod(t6a)*60;
                    else
                        planningPeriod=str2num(t4a(end-6:end-1));
                    end

                    TX=['~ Post-feedback interval: ',num2str(posfbInterval), ' s'];
                    TX2=['~ Planning period: ',num2str(planningPeriod), ' s'];

                    disp(TX)
                    disp(TX2)
                    handles=rmfield(handles,'eyeEx');
                    handles=rmfield(handles,'eyeEy');
                    handles=rmfield(handles,'eyeDx');
                    handles=rmfield(handles,'eyeDy');
                    setGlobalOculo(1);
                    setGlobalStopped(2); %iniciar pc cam

                    Perfm=getGlobalDesemp;

                    if getGlobalTrial>=6
                        save('bfbperf.mat', 'Perfm', 'posfbInterval', 'planningPeriod', 'timeToStart', 'BFBt',...
                            '-v7.3');
                        movefile('bfbperf.mat', ['C:\dados\',getGlobalbb,'\',getGlobalbb,'_perf_',num2str(getGlobalTrial),'.mat'])
                        Perfm=[]; t6=[]; posfbInterval=[]; planningPeriod=[]; BFBt=[]; timeToStart=[];
                        setGlobalTrial(getGlobalTrial+1)
                        setGlobalCounterT(0)
                    else
                        save('bfbperf.mat', 'Perfm', 'posfbInterval', 'planningPeriod',...
                            '-v7.3');
                        movefile('bfbperf.mat', ['C:\dados\',getGlobalbb,'\',getGlobalbb,'_perf_',num2str(getGlobalTrial),'.mat'])
                        Perfm=[]; t6=[]; posfbInterval=[]; planningPeriod=[];
                        setGlobalTrial(getGlobalTrial+1)
                    end
                end

                if getGlobalINIT==2 
                    Perfm=getGlobalDesemp;
                    Dpup3=handles.Dpup3;
                    Dpup30=handles.Dpup30;
                    
                    TaxaTBS=getGlobalCounterT/getGlobalCounterp;
                    save('bfbtbs.mat', 'TaxaTBS',...
                        '-v7.3')
                    save('bfbpup.mat', 'Dpup3', 'Dpup30', ...
                        '-v7.3')
                    movefile('bfbpup.mat', ['C:\dados\',getGlobalbb,'\',getGlobalbb,'_pup_',num2str(getGlobalTrial),'.mat'])
                    movefile('bfbtbs.mat', ['C:\dados\',getGlobalbb,'\',getGlobalbb,'_tbs_',num2str(getGlobalTrial),'.mat'])
                    disp('#######################################################################################################################')
                    sp=['Pupil planning phase saved:', num2str(getGlobalCounterp),'          ', datestr(now,'HH:MM:SS')];
                    disp(sp)
                    disp('#######################################################################################################################')
                    Dpup3=[]; TaxaTBS=[];
                    handles=rmfield(handles,'Dpup3');
                    handles=rmfield(handles,'Dpup30');

                    setGlobalCounterp(1)
                    setGlobalINIT(3);

                    disp('-> PERFORMANCE <-')
                end

                if getGlobalTrial==101
                    if getGlobalbttn2==1
                        fn = 'handel.mat';
                        mS = matfile(fn);
                        sound(mS.y);
                        setGlobalbttn2(0)

                        z=1;
                        while z<=100
                            movefile(['C:\dados\',getGlobalbb,'\',getGlobalbb,'_perf_',num2str(z),'.mat'], ['C:\dados\',getGlobalbb,'\perfm'])
                            z=z+1;
                        end
             
                    end
                end
            end

            if getGlobalRECORDpup==1

                if getGlobalCounterp<=double(string(getGlobalBL))*30 % SAVE PUP BL
                    handles.Dpup(getGlobalCounterp)=(getGlobalPupECm+getGlobalPupDCm)/2;
                    setGlobalCounterp(getGlobalCounterp+1);
                else
                    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
                    msgBL2=['End of Baseline'];
                    disp(msgBL2)
                    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')

                    setGlobalCounterp(1)

                    handles.queryroi=1;
                    setGlobalCounterC(1)
                    while handles.queryroi==1

                        figure
                        setGlobalbREGx(handles.Dpup)
                        plot(handles.Dpup)
                        choice1 = questdlg('Quer cortar?', ...
                            'Focus of the eye', ...
                            'Yes','No','No');

                        % Handle response
                        switch choice1
                            case 'Yes'
                                [a,~]=ginput(2);
                                handles.Dpup(a(1):a(2))=0;
                                handles.Dpup(handles.Dpup==0)=[];
                                handles.queryroiI=1;
                            case 'No'
                                handles.queryroi=2;
                                handles.queryroiI=0;
                        end
                    end

                    handles.queryroi=1;
                    while handles.queryroi==1
                        figure
                        plot(handles.Dpup)
                        choice1 = questdlg('Denovo?', ...
                            'Focus of the eye', ...
                            'Yes','No','No');

                        % Handle response
                        switch choice1
                            case 'Yes'
                                [a,~]=ginput(2);
                                handles.Dpup(a(1):a(2))=0;
                                handles.Dpup(handles.Dpup==0)=[];
                            case 'No'
                                handles.queryroi=2;
                        end
                    end

                    figure
                    plot(handles.Dpup)


                    setGlobalPupBL(mean(handles.Dpup))

                    Dpup=handles.Dpup;
                    Dpupmean=getGlobalPupBL;
                    save('bl.mat', 'Dpup', 'Dpupmean', '-v7.3')
                    movefile('bl.mat', ['C:\dados\',getGlobalbb,'\bl.mat']);

                    bll=['Baseline: ', num2str(getGlobalPupBL)];
                    disp(bll)
                    handles=rmfield(handles,'Dpup');
                    setGlobalRECORDpup(0)
                end

            end

            set(handleToImageInAxes1, 'CData', handles.data4); %????


        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function baseL(~,~)
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
msgBL=['Start Baseline          ', datestr(now,'HH:MM:SS')];
disp(msgBL)
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')

setGlobalRECORDpup(1)
setGlobalCounterp(1)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUTTONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function startSS(~,~)
if getGlobalTrial>1
    setGlobalOculo(1)
    setGlobalRECORDpup(2)
    setGlobalCounterp(1)
    setGlobalStopped(2)
    setGlobalCounterO(1);
else
    setGlobalOculo(1)
    setGlobalCounterO(1);
    setGlobalRECORDpup(2)
    setGlobalCounterp(1)
    setGlobalStopped(2)
end
end

function startBFB(~,~)
if getGlobalTrial>1
    setGlobalOculo(1)
    setGlobalRECORDpup(3)
    setGlobalCounterp(1)
    setGlobalStopped(2)
    setGlobalCounterO(1);
else
    setGlobalOculo(1)
    setGlobalCounterO(1);
    setGlobalRECORDpup(3)
    setGlobalCounterp(1)
    setGlobalStopped(2)
end
end


function desemp(~,~)
setGlobalBttnfc(1)
setGlobalW8t(1);
end

function pupE(~,~)

fprintf('Pupil diameter (Left):  %g \n',getGlobalPupECm);
setGlobalp1(1)
end

function pupD(~,~)
fprintf('Pupil diameter (Right):  %g \n',getGlobalPupDCm);
setGlobalp2(1)
end

function BFB(~,~)
    fprintf('Pupil diameter:  %g \n',round(((getGlobalPupDCm+getGlobalPupECm)/2),1));
    fprintf('Pupil target:  %g \n',getGlobalPC);
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QUIT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stopi(~,~)

answer = questdlg('Are you sure you want to quit?', ...
    'Exit Eye-tracker', ...
    'Yes','No','No');

% Handle response
switch answer
    case 'Yes'

        imaqreset;
        clear
        clc
        close
        disp('Please disconnect the Eye-tracker')

    case 'No'

end
end