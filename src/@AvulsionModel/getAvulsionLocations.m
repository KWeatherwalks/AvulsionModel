function AvLoc = getAvulsionLocations(obj)
% @param obj: The avulsion model object
% @return AvLoc: matrix with avulsion locations and origins
% Diagram of return matrix
%   destination |   origin   | channel cell index
%   [ row, col  ,  row, col  ,  cell# ]

  Thi = obj.topographyHigh;
  Tlo = obj.topographyLow;
  cLoc = obj.currentChannelIDs;
  R = obj.currentRiverMatrix;
  thresh = obj.avulsionThreshold;
  
  cIDi = cLoc(1,:); % the row indices of the channel
  cIDj = cLoc(2,:); % the column indices of the channel
  Ai = [];          % to hold row index of avulsion destination
  Aj = [];          % to hold column index of avulsion destination
  Aoi = [];         % to hold row index of avulsion origin
  Aoj = [];         % to hold column index of avulsion origin
  cL = [];          % to hold channelCellID of avulsion origin
  k = 1;
  
  %% Check the neighbors of each channel cell and possible avulsion events
  for i=1:length(cLoc)-1
    
    % find the neighboring cells of the i-th cell of the active channel
    nbhd = obj.getNeighbors([cIDi(i), cIDj(i)]);
    
    for j=1:5
      
      if ~isnan(nbhd(j,1))
        
        % calculate the difference in height between channel cell and its
        % floodplain neighbor
        aDiff = Thi(cIDi(i),cIDj(i)) - Tlo(nbhd(j,1),nbhd(j,2));
        % calculate the difference in height between channel cell and the
        % next channel cell
        cDiff = Thi(cIDi(i),cIDj(i)) - Tlo(cIDi(i+1),cIDj(i+1));
        
        % update avulsion locations and origin
        if (aDiff > thresh && ...
            aDiff > cDiff  && R(nbhd(j,1),nbhd(j,2)) ~= 1)
          
          Ai(k) = nbhd(j,1);  Aj(k) = nbhd(j,2);
          Aoi(k) = cIDi(i);   Aoj(k) = cIDj(i);
          cL(k) = i;
          k = k+1;
          
        end %if diff>thresh
        
      end %if ~isnan
    
    end %for (inner)
  
  end %for (outer)
  
  %% return matrix
  %       location , origin, cell#
  AvLoc = [Ai', Aj', Aoi', Aoj', cL'];
  
  %% update model parameters
  obj.activeAvulsionLocations = AvLoc;
  
end %getAvulsionLocations