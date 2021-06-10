function plotStratigraphy(obj)
  %% Construct rectangles:
  %         top
  %         ---
  %   left  | | right
  %         ---
  %       bottom
  
  %% object fields used
  n = obj.numCols;
  
  % read in stratigraphy data
  S = obj.stratigraphyData;

  % set the background color of the plot
  bgColor = [218 165  32]/255;
  % set the river sediment color
  cellColor = [255 255 51]/255;
  
  %% loop through each stratigraphy row
  for i = 1:length(S)
    
    % set channel bodies for this row
    CBs = S{i}{2};
    
    % find the number of channel bodies
    sizeS = cellfun(@size,CBs,'uni',false);
    nCB = sum(cellfun(@(x) x(1), sizeS));
    
    % initialize matrices for XData and YData
    XData = zeros(4,nCB); YData = zeros(4,nCB);

    % counter for indexing the data
    last = 0;
    
    % display progress
    progressBar = waitbar(0,'Generating image...');
    
    %% Loop through channel bodies
    for j = 1:n
      
      % check if there are any channel bodies to add
      if size(CBs{j},1)>0
        
        % update indices
        first = last+1;
        last = last + size(CBs{j},1);
        
        % set x location
        XData(1:2, first:last) =  j-1;  % left side
        XData(3:4, first:last) =  j;    % right side
        
        % set y location
        YData(1, first:last) = CBs{j}(:,1)';  % bottom
        YData(2, first:last) = CBs{j}(:,2)';  % top
        YData(3, first:last) = CBs{j}(:,2)';  % top
        YData(4, first:last) = CBs{j}(:,1)';  % bottom
        
      end %if
      
      % update progress
      waitbar(j/n,progressBar);
      
    end %for
    
    %%
    % plot the results
    figure('units','normalized','outerposition',[0 0 .8 .8]); % set window size for figure
    set(gca,'Color', bgColor);
    set(gca,'XMinorTick','on');
    
    % axis limits
    xlim([0 n+1]); ylim([ min(YData(1,:)) , max(YData(2,:)) ]);
    title(sprintf('Stratigraphy at row %d', S{i}{1}));
    xlabel('Column #'); ylabel('Elevation above "sea level" (meters)');
    
    % plot using patch
    patch(XData,YData,cellColor, 'EdgeColor', 'None');
    
    % close progress bar
    delete(progressBar);
    
  end %for (loop over stratigraphy rows)
    
end %plotStratigraphy