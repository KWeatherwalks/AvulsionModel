function avulseToNewChannel(obj)
%avulseToNewChannel performs a steepest descent algorithm
%   obj:  an AvulsionModel object
  
  % Rename key variables and parameters for clarity within this function
  m = obj.numRows;              % number of rows
  n = obj.numCols;              % number of cols
  R = obj.currentRiverMatrix;   % m-by-n matrix
  Tlo = obj.topographyLow;      % m-by-n matrix
  Thi = obj.topographyHigh;     % m-by-n matrix
  cLoc = obj.currentChannelIDs; % 2-by-L matrix
  cDepth = obj.channelDepth;    % numeric
  AvLoc = obj.activeAvulsionLocations;  % matrix
  
  % set index for choosing the first avulsion location
  index = 1; %randi(size(AvLoc,1));
  % set variables for row and column destination, and origin channelID#
  Ai = AvLoc(index,1); Aj = AvLoc(index,2); Ao = AvLoc(index,5);
  % adjust channelID# to update channel IDs vector
  k = Ao + 1;
  
  %% construct matrix of avulsion location indices
  isAvLoc = zeros(m,n);
  for i = 1:length(AvLoc(:,5))
    % store matrix entry as the row index of AvLoc
    isAvLoc(cLoc(1,AvLoc(i,5)), cLoc(2,AvLoc(i,5))) = i;
  end % for
  
  %% initialize new river matrix
  D = zeros(m,n);
  for i = 1:Ao
    
    % set new channel IDs
    cIDi(i) = cLoc(1,i);
    cIDj(i) = cLoc(2,i);
    % set new river matrix entry to 'on'
    D(cLoc(1,i),cLoc(2,i)) = 1;
    
  end %for
  
  %% run steepest descent from the avulsion location
  
  % counter for # of cells involved before reoccupation of channel
  avulsionSize = 1;
  
  % set starting point
  cIDi(k) = Ai; cIDj(k) = Aj;
  % lower by one channel depth
  Thi(Ai,Aj) = Tlo(Ai,Aj);  %%%%%TEST
  Tlo(Ai,Aj) = Thi(Ai,Aj) - cDepth;
  % set new river matrix entry to 'on'
  D(Ai,Aj) = 1;
  
  while cIDi(k)<m
    
    % set current index vector
    idx = [cIDi(k), cIDj(k)];
    
    if isAvLoc(idx(1),idx(2))
      
      % Go to avulsion location
      cIDi(k+1) = AvLoc(isAvLoc(idx(1),idx(2)), 1);
      cIDj(k+1) = AvLoc(isAvLoc(idx(1),idx(2)), 2);
      
      % adjust current river matrix
      D(cIDi(k+1), cIDj(k+1)) = 1;  % set river matrix entry to 'on'
      
      % lower by one channel depth
      Thi(cIDi(k+1),cIDj(k+1)) = Tlo(cIDi(k+1),cIDj(k+1));  %%%%%TEST
      Tlo(cIDi(k+1),cIDj(k+1)) = Thi(cIDi(k+1),cIDj(k+1)) - cDepth;
      
      % adjust length of avulsion
      avulsionSize = avulsionSize + 1;
      
    else % use steepest descent approach
      
      % Calculate the slopes
      [sl, nbhd] = obj.getSlopes(idx);
      
      % Find the minimum slope (steepest descent) and its index
      [minSl, nbr] = min(sl);
      
      % Go to next value (if possible)
      if minSl > 0
        % break loop if all neighbors have positive slope
        break;
        
      else
        cIDi(k+1) = nbhd(nbr,1);    % set next-channel-entry row index
        cIDj(k+1) = nbhd(nbr,2);    % set next-channel-entry column index
        
        % adjust current river matrix
        D(cIDi(k+1), cIDj(k+1)) = 1;  % set river matrix entry to 'on'
        
        % adjust topography of new channel
        if ~R(cIDi(k+1), cIDj(k+1))
          
          % lower by one channel depth
          Thi(cIDi(k+1),cIDj(k+1)) = Tlo(cIDi(k+1),cIDj(k+1));  %%%%%TEST
          Tlo(cIDi(k+1),cIDj(k+1)) = Thi(cIDi(k+1),cIDj(k+1)) - cDepth;
          
          % adjust length of avulsion
          avulsionSize = avulsionSize + 1;
          
        end %if
        
      end %if-else
    
    end %if-else
    
    % increment counter
    k = k+1;
    
  end %while
  
  %% update parameters
  obj.setTopographyLow(Tlo);
  obj.setTopographyHigh(Thi); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%TEST
  obj.setCurrentChannelIDs(cIDi,cIDj);
  obj.setCurrentRiverMatrix(D);
  obj.appendNumCellsVisited;
  obj.setCurrentChannel;
  obj.appendAvulsionLengths(avulsionSize);

end %avulseToNewChannel