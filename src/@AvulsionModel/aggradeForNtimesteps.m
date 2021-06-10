function fluxOutput = aggradeForNtimesteps(obj, N)
% Aggrades the current active channel for N time steps
% obj :         the avulsion model object 
% N :           the number of time steps
% fluxOutput :  a vector representing the flux leaving the channel [m^2/hr]

  %% initialize local parameters
  hasAvulsed = false;
  timeCounter = 0;
  fluxOutput = nan(1,N);  %[m^2/hr]
  
  %% get stratigraphy data (prior aggradation)
  prevTopo = obj.topographyLow;
  
  %% set initial channel elevations
  obj.resetActiveChannel;
  
  %% run algorithm until avulsion threshold is met
  for i = 1:N
    
    % aggrade channel and store amount of sediment output
    fluxOutput(i) = obj.aggradeChannel;
    
    % apply floodplain sediments
    obj.applyFloodplainSedimentation;
    
    % save avulsion locations (if any)
    AvLocs = obj.getAvulsionLocations;
    
    % increment counters to update progress
    timeCounter = timeCounter + 1;
    obj.timeElapsed = obj.timeElapsed + 1;
    
    %% check for avulsion
    if (~isempty(AvLocs))
      hasAvulsed = true;
      break;  % break for loop if avulsion occurs
    end %if
    
    
  end %while
  
  %% get stratigraphy data (post aggradation)
  postTopo = obj.topographyLow; % TODO - monitor the stratigraphy
  
  % set stratigraphy data
  obj.appendStratigraphyData(prevTopo,postTopo);
  
  % set aggraded channel elevations
  obj.activeChannelAggraded = obj.currentChannelElevations;
  
  
  %% Avulsion threshold has been met. Update model parameters
  if hasAvulsed
    
    % set time of avulsion
    obj.appendTimeBetweenAvulsions(timeCounter);
    
    % Gather data for avulsion locations
    obj.numAvulsions = obj.numAvulsions + 1;
    obj.avulsionLocationHistory{obj.numAvulsions} = AvLocs;
    
    
    %display message indicating avulsion has occurred
    fprintf(['Avulsion threshold met. \t' ...
          'The channel will stop aggrading now\n\n']);
    
  end % if hasAvulsed
  
end %aggradeUntilAvulsion