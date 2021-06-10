% Code for testing the model on a 1x30 domain
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% !!!!  Make sure that the file AvulsionModel.m     !!!!
% !!!!  is adjusted so that the following parameters!!!!
% !!!!  have the appropriate values:                !!!!
% !!!!  numRows = 30;                               !!!!
% !!!!  numCols = 1;                                !!!!
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% Instantiate model object
A = AvulsionModel(.5,1/4,0);          % Tested - GOOD

% Set the initial channel (trivial in this case)
A.generateInitialChannel(1);          % Tested - GOOD

% Show planview of the floodplain
A.plotRiver;                          % Tested - GOOD

% Show the cross-section profile of the river channel
A.plotInitialChannel;                 % Tested - GOOD
hold on;  % keep figure active and update as we go

% Initialize slope data
s1 = nan(1,7); s2 = nan(1,7); s3 = nan(1,7);  % Tested - GOOD

% Initialize Sediment Output tracking
TotalSedimentOut = zeros(1,9);        % Tested - GOOD

% Initialize AreaUnderAggraded curve tracking
AreaUnderAggraded = zeros(1,9);       % Tested - GOOD

% Initialize Flux Output leaving system
FluxOutput = zeros(1,9000);           % Tested - GOOD

%% Aggrade the channel 
for i = 1:9
% Run the model for 1000 time steps, then display the new channel
% track qOUTn 
  FluxOutput(1000*(i-1)+(1:1000)) = A.aggradeForNtimesteps(1000);

TotalSedimentOut(i) = sum(FluxOutput(1000*(i-1)+(1:1000))) * A.timeStepSize;

  % get slope information
  temp = A.getSlopes([1,1]);   % Slope at input
  s1(i) = temp(3);
  temp = A.getSlopes([15,1]);  % Slope at middle of domain
  s2(i) = temp(3);
  temp = A.getSlopes([29,1]);  % Slope at output
  s3(i) = temp(3);
  
  % track the area under the aggraded profile
  AreaUnderAggraded(i) = sum(A.currentChannelCellLengths(1:29) ...
                            .* A.currentChannelElevations(1:29));

  % plot active channel 
    % build a vector where each entry is the distance from the origin
    xx = zeros(1,length(A.activeChannelInitial)); 
    for j = 2:length(A.activeChannelInitial)
      xx(j) = xx(j-1) + A.activeChannelCellLengths(j-1);
    end %for
  plot(xx, A.activeChannelAggraded, 'LineWidth', 1.5)

end
% adjust final figure
legend('Initial Profile', 'after 1000 steps', 'after 2000 steps', ...
      'after 3000 steps', 'after 4000 steps', 'after 5000 steps', ...
      'after 6000 steps', 'after 7000 steps', 'after 8000 steps', ...
      'after 9000 steps');

% title
years = A.timeElapsed * A.timeStepSize / (24 * 365.25);
days = rem(years,1) * 365.25;
formatSpec = 'Channel aggradation after %1$12.0f years %2$4.1f days';
titleString = sprintf(formatSpec, floor(years), days);
title(titleString); hold off;

%% plot slopes
figure(); hold on;
plot(s1,'.', 'MarkerSize', 24);
plot(s2,'.', 'MarkerSize', 24);
plot(s3,'.', 'MarkerSize', 24); hold off;
  % title and axes
  title('Slopes vs. timesteps'); 
  legend('at source', 'near middle', 'at output', ...
      'Location', 'best');
  xlabel('timesteps (in thousands)'); ylabel('slope');
  
%% plot flux output
figure();
plot(FluxOutput, '.', 'MarkerSize', 12, 'LineWidth', 2);
  % title and axes
  title('sediment flux output over time');
  xlabel('timesteps'); ylabel({'flux output', '(in meters squared per hour)'});
  
  
  
%% Mass Balance
  % calculate Sediment-In
  tt = 1000:1000:9000;
  TotalSedimentIn = A.sedimentFluxIn * A.timeStepSize * tt;
  
  % Area under initial profile
  AreaUnderInitial = sum(A.initialChannelCellLengths(1:29) ...
                          .*  A.initialChannelElevations(1:29));
  
  % Plot the results
  figure();
  scatter(tt, TotalSedimentIn-cumsum(TotalSedimentOut), 48, 'filled'); hold on; 
  scatter(tt, AreaUnderAggraded-AreaUnderInitial, 20, 'filled'); hold off;
  xlim([0 9000]);
  title('Mass Balance Test');
  xlabel('time steps'); ylabel('(meters squared)');
  legend('TotalSediment Difference', 'Area Difference', ...
          'Location', 'best');