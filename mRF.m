function [InitialObservation, LoggedSignal] = mRF()

cd tt
findtt=dir;
TT=str2num(findtt(3).name);
cd ..

cd pupi
z=1;
findp=dir;
while z<=length(findp)
    if findp(z).isdir==0
        P=findp(z).name;
    end
    z=z+1;
end
P=str2num(P);
cd ..

cd dd
finddd=dir;
D=str2num(finddd(3).name);
cd ..

tent = TT;
desemp = D;
pup = P;

LoggedSignal.State = [tent;desemp;pup];
InitialObservation = LoggedSignal.State;
disp('fim reset mrf')
end