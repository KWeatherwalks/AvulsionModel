% function nbhd = getNeighbors(obj,idx)
% %getNeighbors returns 2 vectors containing the neighbors of a given channel
% %cell. NaNs indicate that the neighbor is not a floodplain cell (it is
% %either outside the domain or it is an active-channel cell)
% % @param idx:   a 2d vector indicating the channel cell to check
% %
% %   Diagram of neighbor locations:
% %   -------------------
% %   |  1  | idx |  2  |
% %   -------------------
% %   |  4  |  3  |  5  |
%   
%   % Rename object parameters for clarity
%   R = obj.currentRiverMatrix;
%   m = obj.numRows;
%   n = obj.numCols;
%   
%   ci = idx(1);    % the cell's row index
%   cj = idx(2);    % the cell's column index
%   
%   idi = nan(1,5); idj = nan(1,5); % to hold neighbor indices
%   
%   %% find neighbors
%   
%       % check if idx is in the lower left corner
%   if ci == m && cj == 1            % only need to check one neighbor
%     idi(2) = ci;   idj(2) = cj+1;   % neighbor 2
%     
%       % check if idx is in the lower right corner
%   elseif ci == m && cj == n        % only need to check one neighbor
%     idi(1) = ci;   idj(1) = cj-1;   % neighbor 1
%     
%       % check if idx is in the last row
%   elseif ci==m && cj~=1 && cj~=n  % only need to check two neighbors
%     idi(1) = ci;   idj(1) = cj-1;   % neighbor 1
%     idi(2) = ci;   idj(2) = cj+1;   % neighbor 2
%     
%       % check if idx is in the first column  
%   elseif cj == 1                  % only need to check three neighbors
%     idi(2) = ci;   idj(2) = cj+1;   % neighbor 2
%     idi(3) = ci+1; idj(3) = cj;     % neighbor 3
%     idi(5) = ci+1; idj(5) = cj+1;   % neighbor 5
%     
%       % check if idx is in the last column
%   elseif cj == n                  % only need to check three neighbors
%     idi(1) = ci;   idj(1) = cj-1;   % neighbor 1
%     idi(3) = ci+1; idj(3) = cj;     % neighbor 3
%     idi(4) = ci+1; idj(4) = cj-1;   % neighbor 4
%     
%       % otherwise check all
%   else                            
%     idi(1) = ci;   idj(1) = cj-1;   % neighbor 1
%     idi(2) = ci;   idj(2) = cj+1;   % neighbor 2
%     idi(3) = ci+1; idj(3) = cj;     % neighbor 3
%     idi(4) = ci+1; idj(4) = cj-1;   % neighbor 4
%     idi(5) = ci+1; idj(5) = cj+1;   % neighbor 5
%   
%   end %if-else
%   
%   %% Return neighborhood matrix
%   nbhd = [idi', idj'];
%   
% end %getNeighbors


function nbhd = getNeighbors(obj,idx)
%getNeighbors returns 2 vectors containing the neighbors of a given channel
%cell. NaNs indicate that the neighbor is not a floodplain cell (it is
%either outside the domain or it is an active-channel cell)
% @param idx:   a 2d vector indicating the channel cell to check
%
%   Diagram of neighbor locations:
%   -------------------
%   |  1  | idx |  2  |
%   -------------------
%   |  4  |  3  |  5  |
  
  % Rename object parameters for clarity
  m = obj.numRows;
  n = obj.numCols;
  
  ci = idx(1);    % the cell's row index
  cj = idx(2);    % the cell's column index
  
  idi = zeros(1,5); idj = zeros(1,5); % to hold neighbor indices
  
  %% find neighbors
  % set potential neighbors
  idi(1) = ci;    idj(1) = cj-1;
  idi(2) = ci;    idj(2) = cj+1;
  idi(3) = ci+1;  idj(3) = cj;
  idi(4) = ci+1;  idj(4) = cj-1;
  idi(5) = ci+1;  idj(5) = cj+1;
  
  % check edges
  for i = 1:5
    
    if idi(i)<1 || idi(i)>m || idj(i)<1 || idj(i)>n
      idi(i) = NaN; idj(i) = NaN;
    end %if
    
  end %for loop
      
  %% Return neighborhood matrix
  nbhd = [idi', idj'];
  
end %getNeighbors