%%RUNMODEL.m
%{
    RUNMODEL.m is a driver for the avulsion model.
    This program simulates fluvial and floodplain sedimentation while
    tracking the topography of a 2D domain.

    TODO: add ability to alter initial conditions via this driver.
%}

%% For Laptop only - Force awake via High Performance Power Profile
% system('powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c');

%% Housekeeping
clear variables
close all hidden
% NOTE: set path for one level above @AvulsionModel

% suppress plot visibility
set(gcf,'Visible','off')              % turns current figure "off"
set(0,'DefaultFigureVisible','off');  % all subsequent figures "off"

%% Get input from user
% set path for data collection files
prompt = 'Please provide a name for the data collection folder: ';
newFolder = input(prompt,'s');
mkdir(newFolder);
   
% prompt user for sigma
sigma = input('Please enter a sigma value [m/yr]:  ');

% prompt user for floodplain sedimentation rate
fpR = input(['Please enter the uniform floodplain sedimentation ' ...
            'rate (as a fraction of sigma):  ']);

% prompt user for floodplain method
disp('Please enter a floodplain method:')
disp('0 - constant/uniform,')
disp('1 - depth-dependent, or')
disp('2 - constant/uniform with previous channel filling.');
method = input('');

% prompt user for slope
slope = input('Please enter a (negative) slope value [-]:  ');

          
% prompt user for length of time to run model
stratMeters = input('How many meters of stratigraphy?:  ');

%% Instantiate the model
disp('Initializing model...');

tic   % begin timer to track runtime

% create an instance of the class AvulsionModel
% A = AvulsionModel(sigma, fpR, method, slope);
A = AvulsionModel(sigma, fpR, method);
% set the number of time steps to run
nTimeSteps = ceil(A.timeStepsPerMeter * stratMeters);

%% Ask user if this number of time steps is acceptable
fprintf('The program will run for %d time steps.\n', nTimeSteps);
fprintf('Estimated time: %.2f minutes.\n', nTimeSteps * 7e-4 / 60);
cont = input('Continue? (Y/N)  ', 's');
if strcmpi(cont,'Y') || strcmpi(cont,'YES')
  clear cont;
else
  error('Program canceled');
end %if-else

%% Set up initial data

% generate initial river channel
A.generateInitialChannel(floor(A.numCols/2));

% display 2-d domain
A.plotRiver; drawnow
% save fig to .fig file
savefig(gcf, strcat(newFolder,'\initialRiver.fig')); close;

% plot the initial channel elevations
A.plotInitialChannel; drawnow
% save figure to .fig file
savefig(gcf, strcat(newFolder,'\initialChannel.fig')); close;

% preallocate cell array to store topography data
maxMovLength = 10000;
topoCellLow = cell(1,maxMovLength);
topoCellHigh = cell(1,maxMovLength);
riverCell = cell(1,maxMovLength);

disp('Model initialized.');

%% Run avulsion model
disp('Running avulsion model...');

% display progress bar
progressBar = waitbar(0, 'Running Avulsion Model');

counter = 1;

while A.timeElapsed < nTimeSteps
  
  if counter < maxMovLength
    % capture topography
    topoCellLow{counter} = A.topographyLow;
    topoCellHigh{counter} = A.topographyHigh;
    % capture river matrix
    riverCell{counter} = sparse(A.currentRiverMatrix);
  end %if
  
  % run aggradation until avulsion
  A.aggradeUntilAvulsion;
  
  % avulse to new channel
  A.avulseToNewChannel;
  
  % Update status
  waitbar(A.timeElapsed/nTimeSteps);
  
  % update counter
  counter = counter+1;
  
end %while

% close progress bar
delete(progressBar);

disp('Avulsion model run completed.');


%% save data
disp('Saving data...');

% workspace data
save([newFolder '\A.mat'], 'A', 'stratMeters', 'fpR', 'sigma'); 
disp('Avulsion object saved successfully.');

save([newFolder '\topoCellHigh.mat'], 'topoCellHigh');
disp('topoCellHigh saved successfully.'); clear topoCellHigh;

save([newFolder '\topoCellLow.mat'], 'topoCellLow');
disp('topoCellLow saved successfully.'); clear topoCellLow;

save([newFolder '\riverCell.mat'] ,'riverCell');
disp('riverCell saved successfully.'); clear riverCell;

disp('saving plots...');
% save topoHigh plot
surf(A.topographyHigh); view(0,-90); drawnow;
% save figure to .fig file
savefig(gcf, strcat(newFolder,'\topoHighFinal','.fig')); close;

% save topoLow plot
surf(A.topographyLow); view(0,-90); drawnow
% save figure to .fig file
savefig(gcf, strcat(newFolder,'\topoLowFinal','.fig')); close;
disp('plots saved successfully.');

% make plots visible again
close all;
set(0,'DefaultFigureVisible','on');  % all subsequent figures "on"

% plot stratigraphy
A.plotStratigraphy
for r = 1:length(A.stratigraphyData)
  
  s = sprintf('\\stratRow%d',A.stratigraphyData{r}{1});
  savefig(r, strcat(newFolder, s, '.fig'));
  fprintf('stratigraphy plot %d of %d saved successfully.\n',...
                                  r,length(A.stratigraphyData));
  
end

disp('Data saved successfully.');


%% Complete program
runTime = toc;  % end timer
minutes = runTime/60; seconds = mod(runTime, 60);
fprintf('Program finished in %.0f minutes, %.2f seconds.\n',minutes,seconds);
set(0,'DefaultFigureVisible','on');  % all subsequent figures "on"
clear all

%% end TESTCLASSMODEL

%% Switch Power Profile back to default
% system('powercfg -setactive 49ef8fc0-bb7f-488e-b6a0-f1fc77ec649b');