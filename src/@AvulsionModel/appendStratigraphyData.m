function appendStratigraphyData(obj,prevTopoLow,postTopoLow)  
% prevTopoLow:  the matrix
% obj.stratigraphyData{i}{j}{k} where
%   i: indexed stratigraphy row (not actual row of domain)
%   j: 1-actual row, 2-channel body start/end data
%   k: column index with channel body data

  R = obj.currentRiverMatrix;
  stratData = obj.stratigraphyData;
  nRows = length(stratData);
  
  % loop through all stratRows
  for i = 1:nRows
    
    % get row
    row = stratData{i}{1};
    
    % get strat data relevant to this row
    S = stratData{i}{2};
    
    % find the strat bodies in the river matrix
    ids = find(R(row,:)==1);
    
    % find the 'bottom(s)' of the channel bodies
    y0 = prevTopoLow(row,ids);
    % find the 'top(s)' of the channel bodies
    y1 = postTopoLow(row,ids);
    
    for k = 1:length(ids)
    
      % check if channel body is aggradation or erosion
      if y1(k) > y0(k) % add channel bodies if aggradation exists
      
        % get length of matrix (and check if empty)
        len = size(S{ids(k)},1);
        
        % check if ending height of previous channel body is the same as
        % the initial height of the new channel body
        if len > 0 && S{ids(k)}(len,2) >= y0(k)
          
          % check if previous startpoint is above new endpoint and correct
          if S{ids(k)}(len,1) > y1(k)
            
            % report 
            
            
            % replace previous channel body with new channel body
            S{ids(k)}(len,:) = [y0(k) y1(k)];
            
          else
            % replace last endpoint with new endpoint, but
            % keep the previous startpoint.
            S{ids(k)}(len,2) = y1(k);
          end %if-else (inner)
          
        else % otherwise add a new channel body
          
          S{ids(k)}(len+1,:) = [y0(k) y1(k)];
          
        end %if-else (outer)
        
      end %if y1<y0
      
    end %for k (inner)
    
    % update object parameters
    obj.stratigraphyData{i}{2} = S;
    
  end %for i (outer)
      
end %appendStratigraphyData