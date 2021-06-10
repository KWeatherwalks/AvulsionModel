function aggradeUntilAvulsion(obj)
% Aggrades the current active channel until the avulsion threshold is met
  
  %% initialize local parameters
  hasAvulsed = false;
  timeCounter = 0;
  
  %% get stratigraphy data (prior aggradation)
  prevTopo = obj.topographyLow;%TODO
  
  %% set initial channel elevations
  obj.resetActiveChannel;
  
  %% run algorithm until avulsion threshold is met
  while ~hasAvulsed
    
    % aggrade channel and apply floodplain sediments
    aggradeChannel(obj);
%     applyFloodplainSedimentation(obj);
    
    % save avulsion locations (if any)
    AvLocs = obj.getAvulsionLocations;
    
    % increment counters to update progress
    timeCounter = timeCounter + 1;
    obj.timeElapsed = obj.timeElapsed + 1;
    
    %% check for avulsion
    if (~isempty(AvLocs))
%       hasAvulsed = true;
      break; %test purposes 
    end %if
    obj.applyFloodplainSedimentation;
    
  end %while
  
  %% get stratigraphy data (post aggradation)
  postTopo = obj.topographyLow; %TODO
  
  %% Avulsion threshold has been met. Update model parameters
  
  % set time of avulsion
  obj.appendTimeBetweenAvulsions(timeCounter);
  
  % set aggraded channel
  obj.activeChannelAggraded = obj.currentChannelElevations;
  
  % set stratigraphy data
  obj.appendStratigraphyData(prevTopo,postTopo);%TODO
  
  % Gather data for avulsion locations
  obj.numAvulsions = obj.numAvulsions + 1;
  obj.avulsionLocationHistory{obj.numAvulsions} = AvLocs;
  
end %aggradeUntilAvulsion