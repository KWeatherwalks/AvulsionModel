% 07/13 This file is broken and needs to be reworked to agree with the new
% method for storing stratigraphy data.

function plotStratasPoints(obj,row)
  
  n = obj.numCols;
  dX = obj.spatialStepSize;
  points = obj.strat2Points(row);
  
  %% plot figure
  figure('units','normalized','outerposition',[0 0 .8 .8]); % set window size for figure
  scatter(points(:,1), points(:,2), 1e-6*points(:,3), 'k', 'filled');
  xlim([0 n*dX]); ylim([0 max(points(:,2))+1]);
  xlabel({'Channel body location', '(meters)'});
  ylabel({'Elevation above "sea level" ', '(in meters)'});
  
  title({'Stratigraphy as weighted centroids of channel bodies',...
        sprintf('row %d', row)});

end %plotStratasPoints