function generateRiverMovie(M, fps, filename)
%generateRiverMovie
  close all
  disp('Setting up movie...');
  
  % set-up video information
  movieType = 'Motion JPEG AVI';
  numFrames = sum(~cellfun(@isempty,M),2);
  videoPath = [filename, '.avi'];
  
  % suppress plot visibility
  set(0,'DefaultFigureVisible','off');  % all subsequent figures "off"
  
  %% Set-Up Movie
  
  video = VideoWriter(videoPath,movieType);
  video.FrameRate = fps;
  video.Quality = 10;
  
  open(video); disp('Video ready for writing...');
  pause(2);
  progressBar = waitbar(0, 'Generating Movie');
  tic % track runtime
  
  %% Generate Movie
  % build array
  for i = 1:numFrames
    
    % plot commands
    generatePlot(full(M{i})); drawnow
    
    % save frame
    writeVideo(video, getframe(gcf));
    
    % close figures
    close all
    
    % update progress bar
    waitbar(i/numFrames);
    
  end %for
  
  %% Complete and Save Movie
  % end of runtime
  writeTime = toc;
  close(video);
  
  % close progress bar
  close(progressBar);
  
  % display writeTime
  fprintf('Movie generated in %.2f seconds\n', writeTime);
  
  % unsuppress plot visibility
  set(0,'DefaultFigureVisible','on');  % all subsequent figures "on"
  
  disp('Movie generated successfully.');
  
end %generateMovie

%% helper function to generate plot
function generatePlot(R)
  
  m = size(R,1);
  n = size(R,2);
  
  % Adjust R so that all elements show up in plot
  R  = vertcat(R(1:m,:), zeros(1,n));
  R = horzcat(R(:,1:n), zeros(m+1,1));
  
  % open figure window % set window size for figure
  figure('units','normalized','outerposition',[0 0 .8 .8]);
  
  % set colormap
  cmap = [218 165  32;    % floodplain
           57  88 121];   % river
  colormap(cmap/255);     % color the image
  
  surf(R);            % generate 3D surface plot...
  view(0,-90)         % and display a bird's-eye view
  
  % gridlines/ticks
  ax = gca;
  set(ax, 'XTick', 0.5+1:n); set(ax, 'XTickLabel', 1:n)
  set(ax, 'XTick', []);
  set(ax, 'YTick', 0.5+1:m); set(ax, 'YTickLabel', 1:m)
  set(ax, 'YTick', []);
  axis(ax, 'image');
  
%{
  %% title
  years = obj.timeElapsed * obj.timeStepSize / (24 * 365.25);
  days = rem(years,1) * 365.25;
  formatSpec = 'Channel location after %1$12d years %2$4.1f days';
  titleString = sprintf(formatSpec, floor(years), days);
  title(titleString);
%}

end %generatePlot