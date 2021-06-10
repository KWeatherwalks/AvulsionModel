% 07/13 This file is broken and needs to be reworked to agree with the new
% method for storing stratigraphy data.

%function to transform strat data into weighted points
function points = strat2Points(obj,row)
% points = [xPos, yPos, weight]
  
  switch row
    case 1
      stratData = obj.stratigraphyData1;
    case 2
      stratData = obj.stratigraphyData2;
    case 3
      stratData = obj.stratigraphyData3;
  end %switch
  %%
  
  % get the x position (in meters)
  xPos = stratData{1} * obj.spatialStepSize;  % in meters
  
  % get the y position (in meters)
  yPos = (stratData{2}(:,1) + stratData{2}(:,2))/2;   % in meters
  
  % get the thicknesses for each channel body
  thickness = stratData{2}(:,2) - stratData{2}(:,1);
  
  % find the minimum of the channel body thicknesses
  minThickness = min(thickness);
  
  % get the weighting factor
  % <thickness> / <minThickness>
  weight = thickness / minThickness;
  
  % return result
  points = [xPos, yPos, weight];

end %strat2Points