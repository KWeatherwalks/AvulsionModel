function plotActiveChannel(obj)
%plotChannelElevations plots the channel elevations vs. the channel cells

IC = obj.activeChannelInitial;

cellLengths = obj.activeChannelCellLengths;
lenXX = length(IC);

   %% build a vector where each entry is the distance from the origin
  xx = zeros(1,lenXX);
  for i = 2:lenXX
    xx(i) = xx(i-1) + cellLengths(i-1);
  end %for
  
  %% plot the channel elevations vs. channel cells
  figure('units','normalized','outerposition',[0 0 1 1]);
  plot(xx,IC,'b');
  
  ax = gca;
  xlabel({'Channel length','(in meters)'})
  ylabel({'Riverbed height','(in meters)'})
  ylim([-1 10])
  yticks(-1:1:10)
  
  
  %% shift tick marks so cell appears properly between adjacent ticks
  xt = zeros(1,length(IC)+1); % for shifting x tick marks
  
  for i = 2:length(xt)-1
    xt(i) = xx(i-1) + .5 * (xx(i)-xx(i-1));
  end %for
  
  xt(length(xt)) = obj.currentChannelLength; % set last tick mark
  ax.XTick = xt;
  
  %% adjust text labels for x-axis
  ax.XTickLabelRotation=90;
  ax.XAxis.TickLabelFormat = '%,.0f';
  
    legend('Active Riverbed');
    %hold on; scatter(xx,IC,'.b'); %TODO
    grid on;
    
  %% title
  title('Active channel elevations');
  
end %plotInitialChannel