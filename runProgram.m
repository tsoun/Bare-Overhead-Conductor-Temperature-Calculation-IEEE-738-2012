% Delete the previous data file
tic;
delete('I_from_amp_data.mat');
delete('networkData.mat')

% Measure the time taken for power flow runs
freq = 97;
for i = 1:freq
    t = i;
    save('time.mat', 't');
    run('runPowerFlow.m');
end

% Load necessary data
Dt = 60;
load('networkData.mat');
load('I_from_amp_data.mat');
branchTypeData = importBranchTypeData();

% Initialize the temperatures matrix: rows for branches, columns for time (1 min intervals)
numBranches = size(current, 1);
temperatures = zeros(numBranches, 1441);  % 1441 time points (1-minute intervals)

% Measure the time taken for temperature calculations
for branch = 1:numBranches
    % Access branch type using table syntax
    branchType = branchTypeData.BranchType{branch};

    % Determine the type of branch
    switch branchType
        case 'OHL (3X95ACSR)'
            type = 'Struzzo';
        case 'OHL (3X16ACSR)'
            type = 'Rondine';
        case 'OHL (3X35ACSR)'
            type = 'Corvo';
        otherwise
            type = 'Rondine';  % Default type
    end

    % Define original and new time points
    t_original = 1:size(current, 2);
    t_new = linspace(1, size(current, 2), 1441);
    
    % Interpolate current data for this branch
    current_interpolated = interp1(t_original, current(branch, :), t_new, 'linear');
    
    % Calculate branch temperatures using the interpolated current data
    branchTemperatures = tempCalc(Dt, current_interpolated, type);
    
    % Store results for the branch
    temperatures(branch, :) = branchTemperatures;
end

% Call the plotting function with the required parameters
plotNetworkBranches(mpc, temperatures);
disp('Heat warning map successfully exported to network_plot_temps.pdf.');
toc;
save('line33temperatures.mat', 'temperatures');

% Clear temporary variables
clear t_new t_original Dt current_interpolated;