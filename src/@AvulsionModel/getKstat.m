function K = getKstat(obj,row)
% KFUNCTION calculates Ripleys K function
% K = kfunction(dataXY,xK,box,method) - returns vector K containing value
% of Ripley's K-function of dataXY in the distances in xK.
% dataXY - N-by-2 vector where N is number of datapoints. Each row
% corresponds to x and y coordinates of each datapoint
% xK - corresponds to the distances where K function should be computed.
% K is the same size as xK...
% box - rectangular boudnary of the data: box = [xlim1, xlim2, ylim1,
% ylim2]
%
% 2017: We use a weighting factor for computing the K-statistic
  
  a = 0;  b = obj.numCols*obj.spatialStepSize;
  xK = a : (b-a)/1000 : b;
  box = [0 b, 0 205];   % fix ylimits for meters of stratigraphy
  
  points = obj.strat2Points(row); % convert strat data to centroids
  dataXY = points(:,1:2);   % x-y coordinates of centroids
  N = size(dataXY,1);       % number of data points
  weights = points(:,3);    % weighting factor for centroids

  %%
  rbox = min([  dataXY(:,1)'-box(1);
                box(2)-dataXY(:,1)';
                dataXY(:,2)'-box(3);
                box(4)-dataXY(:,2)'   ]);
  % rbox is the nearest distance of each datapoint to the box
  
  % no edge correction, with weighting factor
  K = zeros(length(xK),1);
  DIST = squareform(pdist(dataXY,'euclidean'));
  Nk = length(K);
  
  %% Calculate the K-statistic vector
  progressBar = waitbar(0, 'Computing K-statistic');
  for k=1:length(K)
    
    % Find all of the centroids falling within the radius and 
    % multiply by the weighting factor
    S = (DIST < xK(k)) .* weights; % weighted summand
    
    % Calculate the sum of all these weighted centroids
    K(k) = sum(sum(S))/N;
    
    % update progress
    waitbar(k/Nk,progressBar);
    
  end %for
  delete(progressBar);
  
  %% Return K stat
  lambda = N/((box(2)-box(1))*(box(4)-box(3)));
  K = K/lambda;

end