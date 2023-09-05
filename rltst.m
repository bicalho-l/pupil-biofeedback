load('pdrl3.mat')

clear
clc
ObservationInfo = rlNumericSpec([3 1]);
ObservationInfo.Name = 'pupil States';
ObservationInfo.Description = 'trial, desemp, pup';

minPC=0.01;
maxPC=1;
ActionInfo = rlFiniteSetSpec([-minPC:-0.01:-maxPC]);
ActionInfo.Name = 'pup reduction';

cd tt
findtt=dir;
TT=str2num(findtt(3).name);
if TT >1
    movefile(num2str(TT),num2str(1))
end
cd ..

cd pp
findpp=dir;
P=str2num(findpp(3).name);
if P >1
    movefile(num2str(P),num2str(1))
end
cd ..

env = rlFunctionEnv(ObservationInfo,ActionInfo,'myStepFunctionD','myResetFunctionD');