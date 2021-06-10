function plotAggradedChannel(obj)
%plotChannelElevations plots the channel elevations vs. the channel cells

cellLengths = obj.activeChannelCellLengths;
IC = obj.activeChannelInitial;
AC = obj.activeChannelAggraded;
numCells = length(IC);

   %% build a vector where each entry is the distance from the origin
  xx = zeros(1,numCells);
  for i = 2:numCells
    xx(i) = xx(i-1) + cellLengths(i-1);
  end %for
  
  %% plot the channel elevations vs. channel cells
  figure('units','normalized','outerposition',[0 0 1 1]);
  plot(xx,IC,'b');  % 1st plot
  
  ax = gca;
  xlabel({'Channel length','(in meters)'})
  ylabel({'Riverbed height','(in meters)'})
  ylim([-1 10])
  yticks(-1:1:10)
  
  
  %% shift tick marks so cell appears properly between adjacent ticks
  xt = zeros(1,numCells+1); % for shifting x tick marks
  
  for i = 2:length(xt)-1
    xt(i) = xx(i-1) + .5 * (xx(i)-xx(i-1));
  end %for
  
  xt(length(xt)) = obj.currentChannelLength; % set last tick mark
  ax.XTick = xt;
  
  %% adjust text labels for x-axis
  ax.XTickLabelRotation=90;
  ax.XAxis.TickLabelFormat = '%,.0f';
  
  %% plot the aggraded channel
  hold on;
  plot(xx,AC,'r');  %2nd plot
  plot(xx,AC-IC);   %3rd plot
  legend('Initial','Aggraded','[Aggraded] - [Initial]');
  scatter(xx,IC,'.b'); %TODO
  grid on;
  
  %% title
  years = obj.timeElapsed * obj.timeStepSize / (24 * 365.25);
  days = rem(years,1) * 365.25;
  formatSpec = 'Channel aggradation after %1$12.0f years %2$4.1f days';
  titleString = sprintf(formatSpec, floor(years), days);
  title(titleString);
  
end %plotChannelElevations