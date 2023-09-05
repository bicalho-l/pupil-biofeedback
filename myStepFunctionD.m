function [NextObs,Reward,IsDone,LoggedSignals] = myStepFunctionD(Action,LoggedSignals)
disp('begin step')

load('pdrl3.mat')

cd tt
findtt=dir;
TT=str2num(findtt(3).name);
movefile(num2str(TT),num2str(TT+1))

cd ..
TT=TT+1;

cd pp
findp=dir;
P=str2num(findp(3).name);
cd ..

Action=[];
Action = pupil{P}(TT)-pupil{P}(TT-1);

if (pupil{P}(TT)-pupil{P}(TT-1)) <0 && (desempenho{P}(TT)-desempenho{P}(TT-1)) <0
    RewardForNotFalling = (pupil{P}(TT)-pupil{P}(TT-1))*(desempenho{P}(TT)-desempenho{P}(TT-1));
elseif (pupil{P}(TT)-pupil{P}(TT-1)) >0 && (desempenho{P}(TT)-desempenho{P}(TT-1)) >0
    PenaltyForFalling = (pupil{P}(TT)-pupil{P}(TT-1))*(desempenho{P}(TT)-desempenho{P}(TT-1));
    PenaltyForFalling = -PenaltyForFalling;
else
    PenaltyForFalling = 0;
end

LoggedSignals.State = [TT;desempenho{P}(TT);pupil{P}(TT)]; %,Action
NextObs = LoggedSignals.State;


rR=pupil{P}(TT)-pupil{P}(TT-1) < 0 && desempenho{P}(TT)-desempenho{P}(TT-1) < 0;

if ~rR
    Reward = PenaltyForFalling;
else
    Reward = RewardForNotFalling;
end

V = ['## Action:', num2str(Action)]; %rnd
X = ['## Trial: ',num2str(TT),' Person:', num2str(P)];
Y1 = ['## Pup (U): ',num2str(pupil{P}(TT-1)), ' Pup (A): ', num2str(pupil{P}(TT)), '      Error (L): ', num2str(desempenho{P}(TT-1)), ' Error (A): ', num2str(desempenho{P}(TT))];
Y = ['## Pup: ',num2str(pupil{P}(TT-1)-pupil{P}(TT)),' Error:', num2str(desempenho{P}(TT-1)-desempenho{P}(TT))];
Z = ['## Reward: ', num2str(Reward)];
disp(V)
disp(X)
disp(Y1)
disp(Y)
disp(Z)

tTt=1;
IsDone = tTt == 1;
end
