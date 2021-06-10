function plotAvulsionSize(obj)
  
  figure('units','normalized','outerposition',[0 0 .5 .5]); % set window size for figure
  h = histogram(obj.avulsionLengths);
  h.Normalization = 'probability';
  h.BinMethod = 'integers';
  h.DisplayStyle = 'stairs';
  title('Distribution of avulsion lengths');
  xlabel('Avulsion size [# cells]');
  ylabel('Frequency'); yticks(0:.1:1);

end %plotAvulsionSize