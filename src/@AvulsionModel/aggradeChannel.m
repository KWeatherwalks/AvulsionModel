function qOUTn = aggradeChannel(obj)
%aggradeChannel runs the numerical scheme for the one-dimensional diffusion
%equation
% Also add floodplain sedimentation in a different function or
%   change the function name to domainSedimentation?
%   obj: an AvulsionModel object
%
%   qOUTn:  a value representing the sediment flux leaving the last cell 

  %% Initial profile parameters
  H = obj.topographyLow;
  sigma = obj.sigma;
  dX = obj.spatialStepSize;
  dT = obj.timeStepSize;
  Qsin = obj.sedimentFluxIn;
  nu = obj.diffusionCoeff;
  tm = size(H, 1);             % total number of rows in matrix
  tn = size(H, 2);             % total number of columns in matrix

  cIDi = obj.currentChannelIDs(1,:); % channel row indices
  cIDj = obj.currentChannelIDs(2,:); % channel column indices

  K = getKVector(obj);            % for diagonal channel cells
  nMax = length(cIDi);            % number of cells in channel
  
  dH = zeros(tm,tn);              % change in height over 2d domain

  % preallocate sediment flux in/out vectors
  qIN = zeros(1,nMax);
  qOUT = zeros(1,nMax);
    
  %% Loop through numerical solution
  for k = 1:nMax-1
    % for clarity and consistency with equation(1) in the paper.
    i = cIDi(k);                    % row index for channel
    j = cIDj(k);                    % column index for channel
%     m = cIDj(k)-cIDj(k-1);          % for upstream column adjustments
    m = cIDi(k+1)-cIDi(k);          % for side-stream row adjustments
    n = cIDj(k+1)-cIDj(k);          % for downstream column adjustments
    
    
    % Calculate sediment fluxes
    if k == 1
      qIN(1) = Qsin;
    else
      %         qIN(k)= -nu/dX * (ETA(i,j) - ETA(i-1,j+m)) / K(k-1);
      qIN(k) = qOUT(k-1);
    end %if-else
    
    qOUT(k)= -nu/dX * (H(i+m,j+n) - H(i,j)) / K(k); %[m^2/hr]
    
    %% Impose Non-erodible substrate
    if obj.nonErodibleSubstrate == true
      if qOUT(k) > qIN(k)
        qOUT(k) = qIN(k);
      end %if(inner)
    end %if(outer)
    
    %% Calculate change in channel height
    dH(i,j) = dT/dX * (qIN(k) - qOUT(k))/K(k);
    
  end %for
  
  % Calculate downstream boundary solutions
  %qOUTn = qOUT(nMax-1)-sigma*dX;        % (qIN - qDeposited)
  qOUTn = qOUT(nMax-1); %TESTING PURPOSE ONLY
  dH(cIDi(nMax),cIDj(nMax)) = sigma*dT; % simulate sea level rise
  
  
  % update model parameters
  obj.setTopographyLow(obj.topographyLow+dH);
  obj.setTopographyHigh(obj.topographyHigh+dH);
  obj.setCurrentChannelElevations;
  obj.setVisitedCells;
  
end %aggradeChannel

function K = getKVector(obj)
%buildKvector returns an array of multipliers to adjust the slope.
%           Diagonal adjacent cells need to be multiplied by sqrt(2).
  K = obj.currentChannelCellLengths ./ obj.spatialStepSize;
end %getKVector