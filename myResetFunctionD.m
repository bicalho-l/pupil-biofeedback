function [InitialObservation, LoggedSignal] = myResetFunctionD()
if getGlobalT1>=5

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

    % State variables as logged signals.
    LoggedSignal.State = [tent;desemp;pup];
    InitialObservation = LoggedSignal.State;

else

    load('pdrl3.mat')

    cd tt
    findtt=dir;
    TT=str2num(findtt(3).name);
    cd ..

    cd pp
    findpp=dir;
    P=str2num(findpp(3).name);
    cd ..

    if TT==100
        cd tt
        movefile(num2str(TT),num2str(TT-99))
        cd ..
        TT=2;

        cd pp
        movefile(num2str(P),num2str(P+1))
        cd ..
        P=P+1;
    end

    if P==24
        cd pp
        movefile(num2str(P),num2str(P-23))%15
        cd ..
        P=1;
    end

    tent = TT;
    desemp = desempenho{P}(TT);
    pup = pupil{P}(TT);

    LoggedSignal.State = [tent;desemp;pup];
    InitialObservation = LoggedSignal.State;
end
end