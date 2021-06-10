% pre-conditions: 
%   obj AvulsionModel object created
%   initialTopography generated
% post-condition:
%   set topographyLow
%   set currentChannelIDs
%   set currentRiverMatrix
%   set currentChannelElevations
%   set initialChannelElevations
%   set currentChannelCellLengths
%   set currentChannelLength
%   set initialChannelIDs
%   set initialRiverMatrix
%   set initialRiverTopography

function generateInitialChannel(obj,startCol)
  
  % Rename key variables and parameters for clarity within this function
  m = obj.numRows;            % number of rows
  n = obj.numCols;            % number of cols
  R = zeros(m,n);             % matrix
  Thi = obj.topographyHigh;   % matrix
  
  % Initialize channel indices at starting point
  cIDi(1) = 1;                % start at top row
  cIDj(1) = startCol;         % number indicating the start column
  R(1,startCol) = 1;          % flip initial cell 'on'
  k = 1;                      % counter for channel cells
  
  
  %% loop to build channel
  while cIDi(k)<m
    idx = [cIDi(k), cIDj(k)];
    
    % Calculate the slopes
    [sl, nbhd] = obj.getSlopes(idx);
    
    % Find minimum slope (steepest descent) and its index
    [minSl, nbr] = min(sl);
    
    % Go to next value (if possible)
    if minSl > 0                  
      % break loop if neighbors have positive slope
      break;
      
    else
      cIDi(k+1) = nbhd(nbr,1);    % set next-channel-entry row index
      cIDj(k+1) = nbhd(nbr,2);    % set next-channel-entry column index
    
    end %if-else
    
    % adjust current river matrix
    R(cIDi(k+1), cIDj(k+1)) = 1;  % set river matrix entry to 'on'
    
    % increment counter
    k = k+1;
  
  end %while
  
  %% Update model fields
  obj.setTopographyLow(Thi-R);
  obj.setCurrentChannelIDs(cIDi, cIDj);
  obj.setCurrentRiverMatrix(R);
  obj.setCurrentChannelElevations;
  obj.initialChannelElevations = obj.currentChannelElevations;
  obj.setCurrentChannelCellLengths;
  obj.initialChannelCellLengths = obj.currentChannelCellLengths;
  obj.setCurrentChannelLength;
  obj.initialRiverMatrix = obj.currentRiverMatrix;
  obj.initialRiverTopography = obj.topographyLow;
  obj.setVisitedCells;
  obj.appendNumCellsVisited;

end %generateInitialChannel