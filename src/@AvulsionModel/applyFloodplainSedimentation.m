function applyFloodplainSedimentation(obj)
%applyFloodplainSedimentation
% obj:    the avulsion model object
% method: integer indicating the floodplain sedimentation profile
%           0 - uniform
%           1 - depth-dependent
  
  method = obj.fpProfile;
  m = obj.numRows;
  n = obj.numCols;
  h = obj.channelDepth;
  R = obj.currentRiverMatrix;
  Tlo = obj.topographyLow;
  Thi = obj.topographyHigh;

%% Apply floodplain sedimentation if the cell is a floodplain cell
  
  % Base floodplain deposit
  fpDeposit = obj.fpSedimentationRate * obj.timeStepSize;    

  % Choose method
  switch method
    
    case 0  % constant, uniform
      
      % Apply fpDeposit only to floodplain cells
      Tlo(~R) = Tlo(~R) + fpDeposit;
      Thi(~R) = Thi(~R) + fpDeposit;

%{      
      for i = 1:m
        for j = 1:n
          
          if (R(i,j) ~= 1)
            Tlo(i,j) = Tlo(i,j) + fpDeposit;
            Thi(i,j) = Thi(i,j) + fpDeposit;
          end %if
          
        end %for j (inner)
      end %for i (outer)
%}

    case 1  % depth-dependent
      
      %{
      T = Thi;
      T(~R) = 0;
      etaTop = max(T');
      
      for i = 1:length(etaTop)
        
      end
      %}
      
      for i = 1:m
        
        % find river channel cells
        rCells = R(i,:)==1;
        
        % set etaTop equal to highest levee of channel for this row
        if ~isempty(rCells)
          etaTop = max(Thi(i,rCells));
        else
          etaTop = max(Thi(i,:));
        end %if
        
        % loop through floodplain columns
        for j = find(rCells==0)
          
          if ~(etaTop < Tlo(i,j))
            dh = fpDeposit + fpDeposit*(etaTop - Tlo(i,j))/h;
            Tlo(i,j) = Tlo(i,j)+dh;
          end %if
          
          if ~(etaTop < Thi(i,j))
            dh = fpDeposit + fpDeposit*(etaTop - Thi(i,j))/h;
            Thi(i,j) = Thi(i,j)+dh;
          end %if
          
        end %for j (inner)
        
      end %for i (outer)
      
    case 2  % constant, uniform, modified Thi
      
      Tlo(~R) = TLo(~R) + fpDeposit;
      Thi(~R & Tlo>=Thi) = Thi(~R & Tlo>=Thi) + fpDeposit; 
      
%{
      for i = 1:m
        for j = 1:n
          
          if (R(i,j) ~= 1)
            
            % deposit sediment on floodplain cells
            Tlo(i,j) = Tlo(i,j) + fpDeposit;
            
            if Tlo(i,j) >= Thi(i,j)
              Thi(i,j) = Thi(i,j) + fpDeposit;
            end %if
            
          end %if
          
        end %for j (inner)
      end %for i (outer)
%}
      
  end %switch  

  
  %% update parameters
  obj.setTopographyLow(Tlo);  % update the low topography
  obj.setTopographyHigh(Thi); % update the high topography
  
end %applyFloodplainSedimentation