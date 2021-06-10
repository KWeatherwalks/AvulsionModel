function plotRiver(obj)
%riverplot Generates an image of a river channel in a topography
% R: matrix containing river(2), floodplain(0), and previous channel(1)

  R = obj.currentRiverMatrix;
  figure('units','normalized','outerposition',[0 0 .8 .8]); % set window size for figure
  m = size(R,1);
  n = size(R,2);
  
  %% Adjust R so that all elements show up in plot
  R  = vertcat(R(1:m,:), zeros(1,n));
  R = horzcat(R(:,1:n), zeros(m+1,1));
  
  %% colormap to distinguish floodplain cells from river channel cells
  
  cmap = [1 1 102/255;                % floodplain
          173/255 216/255 230/255];   % current river
        
  colormap(cmap);     % color the image
  surf(R);            % generate 3D surface plot...
  view(0,-90)         % and display a bird's-eye view
  
  %% gridlines/ticks
  ax = gca;
  set(ax, 'XTick', 0.5+1:n)
  set(ax, 'XTickLabel', 1:n)
  set(ax, 'XTick', [])
  
  set(ax, 'YTick', 0.5+1:m)
  set(ax, 'YTickLabel', 1:m)
  set(ax, 'YTick', [])
  
  axis(ax, 'image')
  
  %% colorbar legend
  labels = {'Floodplain', 'Current Channel'};
  hcb = colorbar('Ticks', max(max(R))*[1/3 2/3], 'TickLabels', labels);
  hcb.AxisLocation = 'in';
  
  %% title
  years = obj.timeElapsed * obj.timeStepSize / (24 * 365.25);
  days = rem(years,1) * 365.25;
  formatSpec = 'Channel location after %1$12d years %2$4.1f days';
  titleString = sprintf(formatSpec, floor(years), days);
  title(titleString);
  
end