%%AvulsionModel.m is the class file containing all parameters and
%%specifications for running the avulsion model simulation.

classdef AvulsionModel < handle 
  %% private properties (accessible only to the object)
  properties (SetAccess = private)
    % initial parameters
    %%NOTE: ADD UNITS TO THESE PROPERTIES
    numRows = 30;                         % m [-]
    numCols = 30;                         % n [-]
    spatialStepSize = 105;                % dX [m]
    timeStepSize = 16.5;                  % dT [hr]
    diffusionCoeff = 9.69697*3600/105;    % nu [m^2/hr]
    sedimentFluxIn = 0.01*3600/105;       % Qsin [m^2/hr]
    sigma = .5/(365.25*24);               % sigma [m/hr]
    noiseMaximum = 2e-4;                  % noiseMax [m] Default: 2e-3
    nonErodibleSubstrate = false;         % nonerodible
    channelDepth = 1;                     % default channel depth [m]
    avulsionThreshold = 1;                % thresh [m]
    fpSedimentationRate = 1/4;            % [-] relative to sigma (sea-level rise rate) [m/hr]
    
    fpProfile = 0;  % floodplain sedimentation profile 
                    %(0-uniform, 1-depth dependent)
    
    % counter for tracking the total time since instantiation of the model.
    timeElapsed = 0;                      % [-]
    
    % if true, then the noise remains from the initial topography,
    % if false, then the channel must be carved, smoothed and
    channelNoiseOn = true;                % channelNoise  [-]
    % NOTE: false doesn't make much sense here since we want to
    % let the downstream boundary be 0 initially.
    
    % parameters dependent on the above initial parameters
    initialSlope;               % beta [-]
    topographyHigh;             % high elevations matrix [m]
    topographyLow;              % low elevations matrix [m]
    noiseMatrix;                % initial noise added to elevations [m]
    initialTopography;          % initial elevations matrix [m]
    initialChannelElevations;   % initial river channel elevations [m]
    initialChannelCellLengths;  % distance between cells in river [m]
    initialRiverMatrix;         % initial river matrix representation [-]
    initialRiverTopography;     % initial topography after river carved [m]
    currentChannelElevations;   % current river channel elevations [m]
    currentChannelIDs;          % current river channel indices [-]
    currentChannelCellLengths;  % distance between cells in river [m]
    currentChannelLength;       % current river channel length [m]
    currentRiverMatrix;         %
    activeChannelInitial;       % active channel elevations prior aggradation [m]
    activeChannelAggraded;      % active channel elevations after aggradation [m]
    activeChannelCellLengths;   % distance between cells in river [m]
    timeStepsPerMeter;          % minimum number of time steps necessary
                                %to generate one meter of stratigraphy
    
    activeAvulsionLocations;    % active channel avulsion locations
    avulsionLocationHistory;    % cell array holding the avulsion location indices
    numAvulsions = 0;           % number of avulsions which have occurred
    visitedCells;               % matrix of cells visited by channels
    
    % cell array to track stratigraphy data %%TODO
%     stratigraphyData = { {10,cell(1,39)}, {20,cell(1,39)}, {30,cell(1,39)}, {39,cell(1,39)} };
    stratigraphyData;
    

    % vector holding the avulsion lengths
    avulsionLengths = [];
    
    % vector with the time between avulsions
    timeBetweenAvulsions = [];
    
    % vector with the number of cells visited at each avulsion
    numCellsVisited = [];
    
  end %private properties
  
  %% public methods
  methods
    
    % Constructor
    function obj = AvulsionModel(sigma, fp, fpMethod, slope, stratRows)
      % sigma:      numeric   the downstream boundary condition [m/hr]
      % fp:         numeric   the fraction of sigma related to uniform 
      %                       floodplain sedimentation rate.
      % fpMethod:   numeric   0-uniform, 1-depth dependent
      % stratRows:  vector    the rows at which to gather stratigraphy data
      
      % Set the default initial slope
      obj.initialSlope  = -obj.sedimentFluxIn/obj.diffusionCoeff;   % numeric [-]
      
      % Set default stratigraphy data rows
      obj.stratigraphyData = {{ceil(obj.numRows/4),cell(1,obj.numCols)},...
                          {ceil(obj.numRows/2),cell(1,obj.numCols)}, ...
                          {ceil(obj.numRows*3/4),cell(1,obj.numCols)}, ...
                          {ceil(obj.numRows),cell(1,obj.numCols)} };
      
      % NOTE: case 0 is the default constructor, so nothing to do!
      switch nargin
        case 1 
          obj.sigma = sigma/(365.25*24);  % numeric [m/hr]
        case 2
          obj.sigma = sigma/(365.25*24);  % numeric [m/hr]
          obj.fpSedimentationRate = fp;   % numeric [-] (fraction of sigma)
        case 3
          obj.sigma = sigma/(365.25*24);  % numeric [m/hr]
          obj.fpSedimentationRate = fp;   % numeric [-] (fraction of sigma)
          obj.fpProfile = fpMethod;       % numeric [-] 0-uniform,1-depthdep
        
        case 4
          obj.sigma = sigma/(365.25*24);  % numeric [m/hr]
          obj.fpSedimentationRate = fp;   % numeric [-] (fraction of sigma)
          obj.fpProfile = fpMethod;       % numeric [-] 0-uniform,1-depthdep, 2-uniform*
          obj.initialSlope = slope;       % numeric [-] 
          
        case 5
          obj.sigma = sigma/(365.25*24);  % numeric [m/hr]
          obj.fpSedimentationRate = fp;   % numeric [-] (fraction of sigma)
          obj.fpProfile = fpMethod;       % numeric [-] 0-uniform,1-depthdep
          obj.initialSlope = slope;       % numeric [-]
          
          % construct stratigraphyData cell array
          for i = 1:length(stratRows)
            obj.stratigraphyData{i} = {stratRows(i), cell(1,obj.numCols)};
          end %for
          
      end %switch
      
      % Set the floodplain sedimentation rate
      obj.fpSedimentationRate = obj.fpSedimentationRate * obj.sigma; % numeric [m/hr]
      
      % Set the current river matrix representation initially to null
      obj.currentRiverMatrix = zeros(obj.numRows,obj.numCols);  % matrix
      obj.visitedCells = obj.currentRiverMatrix;                % matrix
      
      % Set the initial topography
      obj.noiseMatrix = obj.noiseMaximum * rand(obj.numRows,obj.numCols)/2;
      obj.initialTopography = obj.generateTopography;   % matrix
      obj.topographyHigh = obj.initialTopography;       % matrix
      obj.topographyLow = obj.initialTopography;        % matrix
      
      % Set the conversion factor for generating stratigraphy thickness
      if obj.fpSedimentationRate ~= 0
        obj.timeStepsPerMeter = 1/(obj.fpSedimentationRate * obj.timeStepSize);
      else
        obj.timeStepsPerMeter = 1/(obj.sigma * obj.timeStepSize);
      end %if-else
      
    end %constructor
    
    %% Accessors
    %% Mutators
    
    function setFPrate(obj, p)
      % p is a fraction of sigma
      obj.fpSedimentationRate = p * obj.sigma;
    end
    
    function setTopographyLow(obj, T)
      assert(all(size(T) == [obj.numRows, obj.numCols]), ...
            'dimensions must match numRows and numCols');
      obj.topographyLow = T;
    end %setTopographyLow
    
    
    function setTopographyHigh(obj, T)
      assert(all(size(T) == [obj.numRows, obj.numCols]), ...
            'dimensions must match numRows and numCols   ');
      obj.topographyHigh = T;
    end %setTopographyHigh
    
    
    function setCurrentChannelIDs(obj, ci, cj)
      obj.currentChannelIDs = [ci; cj];
    end %setCurrentChannelIDs
    
    
    function setCurrentChannel(obj)
      %setCurrentChannel sets the currentChannel parameters
      setCurrentChannelCellLengths(obj);
      setCurrentChannelLength(obj);
      setCurrentChannelElevations(obj);
    end %setCurrentChannel
    
    
    function setCurrentChannelCellLengths(obj)
      %setCurrentChannelCellLengths sets the distance between cells in the
      %river channel. Note that the last cell will have the default cell
      %length dX since it is at the bottom boundary of the domain.
      cLoc = obj.currentChannelIDs;
      length = size(cLoc,2);
      C = obj.spatialStepSize * ones(1,length);
      
      for index = 1:length-1
        
        if cLoc(1,index) ~= cLoc(1,index+1) && cLoc(2,index) ~= cLoc(2,index+1)
          C(index) = C(index) * sqrt(2);
        end %if-else
        
      end %for
      
      obj.currentChannelCellLengths = C;
    
    end %setCurrentChannelCellLengths
    
    
    function setCurrentChannelLength(obj)
      obj.currentChannelLength = sum(obj.currentChannelCellLengths);
    end %setCurrentChannelLength
    
    
    function setCurrentChannelElevations(obj)
      %setCurrentChannelElevations sets the vector containing the current
      %river channel elevations.
      length = size(obj.currentChannelIDs,2);
      C = zeros(1,length);
      
      for index = 1:length
        i = obj.currentChannelIDs(1,index);
        j = obj.currentChannelIDs(2,index);
        C(index) = obj.topographyLow(i,j);
      end %for
      
      obj.currentChannelElevations = C;
    
    end %setCurrentChannelElevations
    
    
    function setCurrentRiverMatrix(obj,R)
      obj.currentRiverMatrix = R;
    end %setCurrentRiverMatrix
    
    function resetActiveChannel(obj)
      obj.activeChannelInitial = obj.currentChannelElevations;
      obj.activeChannelAggraded = obj.activeChannelInitial;
      obj.activeChannelCellLengths = obj.currentChannelCellLengths;
    end %resetActiveChannel
    
    
    function setVisitedCells(obj)
      obj.visitedCells = obj.visitedCells + obj.currentRiverMatrix;
    end %setVisitedCells
    
    
    function appendNumCellsVisited(obj)
      obj.numCellsVisited = [obj.numCellsVisited, nnz(obj.visitedCells)];
    end %setNumCellsVisited
    
    
    function setNonErodible(obj, bl)
      obj.nonErodibleSubstrate = bl;
    end %setNonErodible
    
    function incrementTimeElapsed(obj)
      obj.timeElapsed = obj.timeElapsed + 1;
    end %incrementTimeElapsed
    
    
    function appendTimeBetweenAvulsions(obj, time)
      obj.timeBetweenAvulsions = [obj.timeBetweenAvulsions, time];
    end % appendTimeBetweenAvulsions
    
    
    function appendAvulsionLengths(obj, length)
      obj.avulsionLengths = [obj.avulsionLengths, length];
    end %appendAvulsionLengths
    
    
  end %public methods
  
  
  %% private methods
  methods (Access = private)
    
    function returnMatrix = generateTopography(obj)
      %generateTopography takes an AvulsionModel object as input
      %                   and generates a topography matrix.
      % obj: the avulsion model object
      
      % FIX RNG SEED FOR TEST PURPOSES ONLY!
      % Set this to shuffle in order to generate random data
      rng(31); %TODO
%       rng shuffle;
      
      % Initialize a matrix
      T = zeros(obj.numRows, obj.numCols);
      
      % Loop through rows
      for i = 1:obj.numRows
        
        for j = 1:obj.numCols
          % y = a*x + b form
          T(i,j) = obj.initialSlope*(i-1) - obj.initialSlope*(obj.numRows-1);
        end %for(inner)
      
      end %for(outer)
      
      % Add random noise
      T = T + obj.noiseMatrix;
      %noiseMaximum has to be smaller than initialSlope*spatialStepSize to
      %ensure that steepest descent algorithm fills the entire domain.
      
      % Scale by cell width and ...
      % Uniformly increase the 2d domain by the threshold amount so that
      % positive values are maintained when the initial river channel is
      % carved into the topography
      returnMatrix = T * obj.spatialStepSize + obj.avulsionThreshold;
      %NOTE: NEED TO MULTIPLY BY THE spatialStepSize TO GET THIS IN
      %THE FORM THAT WE WANT. I.e. the magnitude desired
      
    end %generateTopography
    
  end %private methods
  
end %AvulsionModel