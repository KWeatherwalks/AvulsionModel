function generateTopographyMovie(M, fps, filename)
%generateRiverMovie
  
  disp('Setting up movie...');
  %
  movieType = 'Motion JPEG AVI';
  numFrames = sum(~cellfun(@isempty,M),2);
  videoPath = [filename, '.avi'];
  
  % suppress plot visibility
  set(0,'DefaultFigureVisible','off');  % all subsequent figures "off"
  
  %% Generate Movie
  
  video = VideoWriter(videoPath,movieType);
  video.FrameRate = fps;
  video.Quality = 30;
  
  open(video); disp('Video ready for writing...');
  pause(2);
  progressBar = waitbar(0, 'Generating Movie');
  tic % track runtime
  
  % loop through cell array
  for i = 1:numFrames
    
    % plot commands
    generatePlot(M{i}); drawnow
    
    % save frame
    writeVideo(video, getframe(gcf));
    
    % close figures
    close all
    
    % update progress bar
    waitbar(i/numFrames);
    
  end %for
  
  % runtime
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
function generatePlot(T)
  
  figure('units','normalized','outerposition',[0 0 .8 .8]); % set window size for figure
  
  surf(T);
  view(0,-90);

end %generatePlot