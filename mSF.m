function [NextObs,Reward,IsDone,LoggedSignals] = mSF(Action,LoggedSignals)

m=1;
while m==1
    cd tt
    findtt=dir;
    TT=str2num(findtt(3).name);
    cd ..
    setGlobalT2(TT) 

    if getGlobalT1==getGlobalT2
        cd pupi
        z=1;
        findp=dir;
        while z<=length(findp)
            if findp(z).isdir==0
                PP=findp(z).name;
            end
            z=z+1;
        end
        PP=str2num(PP);
        pup=[PP];
        cd ..

        cd pupil
        z=1;
        findpl=dir;
        while z<=length(findpl)
            if findpl(z).isdir==0
                PL=findpl(z).name;
            end
            z=z+1;
        end
        PL=str2num(PL);
        cd ..

        cd dd
        findd=dir;
        D=str2num(findd(3).name);
        desemp=[D];
        cd ..

        cd ddL
        finddl=dir;
        DL=str2num(finddl(3).name);
        cd ..

        Force=Action;

        if (PP-PL) <0 && (D-DL) <0
            RewardForNotFalling = (PP-PL)*(D-DL);

        elseif (PP-PL) >0 && (D-DL) >0
            PenaltyForFalling = (PP-PL)*(D-DL);

            PenaltyForFalling = -PenaltyForFalling;

        else
            PenaltyForFalling = 0;
        end

        LoggedSignals.State = [TT;D;PP]; 
        NextObs = LoggedSignals.State;

        rR=PP-PL < 0 && D-DL < 0;

        if ~rR
            Reward = PenaltyForFalling;
        else
            Reward = RewardForNotFalling;
        end

        Y1 = ['## Pupil gain (L): ',num2str(PL), 'mm  Pupil gain (A): ', num2str(PP), 'mm   //   Error (L): ', num2str(DL), ' Error (A): ', num2str(D)];
        Y = ['## Changes -> Pup: ',num2str(PP-PL),'mm Error:', num2str(D-DL)];
        Z = ['## Reward: ', num2str(Reward)];
        V = ['## Action: ', num2str(Force), 'mm'];
        disp(Y1)
        disp(Y)
        disp(Z)
        disp(V)

        cd pontodecontrole
        z=1;
        findpc=dir;
        while z<=length(findpc)
            if findpc(z).isdir==0
                PC=findpc(z).name;
            end
            z=z+1;
        end
        movefile(num2str(PC),'000')
        movefile('000',num2str(Action))
    end
    cd ..

    cd pupil
    z=1;
    findpl=dir;
    while z<=length(findpl)
        if findpl(z).isdir==0
            PL=findpl(z).name;
        end
        z=z+1;
    end
    delete(PL)
    cd ..

    cd pupi
    z=1;
    findp=dir;
    while z<=length(findp)
        if findp(z).isdir==0
            PP=findp(z).name;
        end
        z=z+1;
    end
    movefile(num2str(PP),['C:\dados\pupil\',num2str(PP)])
    cd ..

    cd ddl
    findDL=ls;
    DL=findDL(3,1:end);
    delete(DL)
    cd ..

    cd dd
    movefile(num2str(findd(3).name),['C:\dados\ddL\',num2str(findd(3).name)])
    cd ..

    tTt=1;
    IsDone = tTt == 1;
    m=2;
    setGlobalT1(getGlobalT1+1) %% tt rl
end

cd pupi 
while m==2
    disp('waiting trial to finish')
    pause(3)
    nextt=dir;
    if length(nextt)>2
        m=3;
    end
end
cd ..

end
