clear
clc
load('TRAINED.mat')
setGlobalT1(5)
setGlobalT2(5)

simOpts = rlSimulationOptions(...
    'MaxSteps',100,...
    'NumSimulations',100)
env.StepFcn='mSF';
experience = sim(env,agent,simOpts);
totalReward = sum(experience.Reward);
