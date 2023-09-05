obsInfo = getObservationInfo(env);
actInfo = getActionInfo(env);

initOpts = rlAgentInitializationOptions('NumHiddenUnit',128);
agent = rlACAgent(obsInfo,actInfo,initOpts);
critic = getCritic(agent);
agent  = setCritic(agent,critic);

actorNet = getModel(getActor(agent));
criticNet = getModel(getCritic(agent));

criticNet.Layers
plot(actorNet)
plot(criticNet)
getAction(agent,{rand(obsInfo(1).Dimension)})

trainOpts = rlTrainingOptions(...
    'Verbose',false, ...
    'Plots','training-progress',...
    'StopTrainingCriteria','EpisodeCount',...
    'StopTrainingValue',100*24,...
    'ScoreAveragingWindowLength',1,...
    'MaxStepsPerEpisode',1,...
    'MaxEpisodes',100*24);

trainingStats = train(agent,env,trainOpts);