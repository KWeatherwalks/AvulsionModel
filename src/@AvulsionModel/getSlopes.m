function [S, nbhd] = getSlopes(obj, idx)
%getSlopes calculates the slope values for each neighbor of ix
%   obj:  an AvulsionModel object
%   idx:  a 2d vector with the row and column index to examine

%   Diagram of neighbor locations:
%   -------------------
%   |  1  | idx |  2  |
%   -------------------
%   |  4  |  3  |  5  |



  T = obj.topographyLow;
  nbhd = obj.getNeighbors(idx);
  dX = obj.spatialStepSize;
  
  % initialize 
  S = nan(5,1);
  
  % loop through neighbors of cell idx
  for i = 1:5
    
    if ~isnan(nbhd(i,1))
      
      % set slope between two cells
      S(i) = (T(nbhd(i,1), nbhd(i,2)) - T(idx(1,1),idx(1,2))) / dX;
      % adjust if neighbor is 4 or 5
      if i == 4 || i == 5
        S(i) = S(i)/sqrt(2);
      end %if
          
    end %if
    
  end %for loop

end %getSlopes