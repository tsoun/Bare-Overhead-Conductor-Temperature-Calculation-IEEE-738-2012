function mpc = Copy_of_case360

    % Load data files
    % run(fullfile('C:\Users\thano\Desktop\Code 26-9-24\LoadData', 'loadBusData.m'));
    % run(fullfile('C:\Users\thano\Desktop\Code 26-9-24\LoadData', 'loadBranchData.m'));
    % run(fullfile('C:\Users\thano\Desktop\Code 26-9-24\LoadData', 'loadTFData.m'));
    % run(fullfile('C:\Users\thano\Desktop\Code 26-9-24\LoadData', 'loadLoadData.m'));
    % run(fullfile('C:\Users\thano\Desktop\Code 26-9-24\LoadData', 'loadSolarData.m'));
    t = load('C:\Users\thano\Desktop\Code 26-9-24\Second Step 2nd version\time.mat');
    branchData = load('C:\Users\thano\Desktop\Code 26-9-24\Second Step\branches.mat');
    busesData = load('C:\Users\thano\Desktop\Code 26-9-24\Second Step\buses.mat');
    loads = load('C:\Users\thano\Desktop\Code 26-9-24\Second Step\loads.mat');
    realLoads = load('C:\Users\thano\Desktop\Code 26-9-24\Second Step 2nd version\finalLoadData.mat');
    reactiveLoads = load('C:\Users\thano\Desktop\Code 26-9-24\Second Step 2nd version\reactiveLoads.mat');
    
    %% Matpower Case Format: 2
    mpc.version = '2';

    %% System MVA base
    mpc.baseMVA = 100;

    %% Bus data initialization
    mpc.bus = busesData.bus();
    mpc.bus(:,3) = 0;
    mpc.bus(:,4) = 0;

    %% Branch Data Initialization
    mpc.branch = branchData.branch();

    %% Isolate Buses
    branch_buses = unique([mpc.branch(:,1); mpc.branch(:,2)]);
    isolated_buses = setdiff(mpc.bus(:,1), branch_buses);
    mpc.bus(ismember(mpc.bus(:,1), isolated_buses), :) = [];

    %% Generator Data Initialization
    mpc.gen = [ 1, 0.1, 0, 12, -12, 1, 100, 1, 5, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
                17, 0.1, 0, 300, -300, 1, 100, 1, 25, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
                44, 0.2, 0, 25, -25, 1, 100, 1, 25, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
                120, 0.01, 0, 300, -300, 1, 100, 1, 3, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
                358, 0.01, 0, 300, -300, 1, 100, 1, 3, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
                173, 0.05, 0, 300, -300, 1, 100, 1, 3, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
                261, 0.005, 0, 300, -300, 1, 100, 1, 3, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
                108, 0.012, 0, 25, -25, 1, 100, 1, 3, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
                314, 0.001, 0, 300, -300, 1, 100, 1, 3, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
                264, 0.2, 0, 300, -300, 1, 100, 1, 10, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    for i = 2:size(mpc.gen, 1)
        bus_number = mpc.gen(i, 1); % Get the bus number from the generator
        mpc.bus(mpc.bus(:, 1) == bus_number, 2) = 2; % Set the bus type to 2 for the corresponding bus
    end

    %% Clean Up Generators for Isolated Buses
    mpc.gen(:,8) = 1;  % apf
    mpc.gen(:,7) = 100;  % mBase
    mpc.gen(ismember(mpc.gen(:,1), isolated_buses), :) = [];

    %% Plot
    % Step 1: Identify all buses involved in branches
    branch_buses = unique([mpc.branch(:, 1); mpc.branch(:, 2)]);  % All buses connected by branches

    % Step 2: Identify isolated buses (buses not connected by any branch)
    connected_buses = setdiff(branch_buses, isolated_buses);

    % Step 3: Filter branches to exclude those connected to isolated buses
    fbus = mpc.branch(:, 1);  % From bus
    tbus = mpc.branch(:, 2);  % To bus

    % Exclude branches that involve isolated buses
    valid_indices = ismember(fbus, connected_buses) & ismember(tbus, connected_buses);
    filtered_fbus = fbus(valid_indices);
    filtered_tbus = tbus(valid_indices);

    % Step 4: Create a directed graph from the filtered buses
    G = digraph(filtered_fbus, filtered_tbus);

    % Step 5: Identify and remove any isolated nodes (buses with no connections)
    node_degrees = indegree(G) + outdegree(G);  % Get the degree of each node in the graph
    isolated_nodes = find(node_degrees == 0);  % Find nodes with no connections

    % Remove isolated nodes from the graph
    G = rmnode(G, isolated_nodes);

    % Step 6: Generate bus labels (either bus numbers or names)
    % Assuming 'connected_buses' are the bus numbers/names after removing isolated buses
    bus_labels = string(connected_buses);  % Create bus labels from bus numbers/names

    % Step 7: Plot the graph with bus names as node labels and without arrowheads
    % figure;
    h = plot(G, 'Layout', 'force', 'ArrowSize', 0, 'LineWidth', 2, 'MarkerSize', 4); % Increased line width

    % Assign custom node labels (bus names or numbers)
    h.NodeLabel = bus_labels;

    % Set title and axis labels
    title('Network Branches of the MATPOWER Case (Excluding Isolated Buses)');
    % xlabel('Bus Index');
    % ylabel('Bus Index');
    grid on;

    % Step 8: Find bus IDs with outdegree zero
    out_degrees = outdegree(G);  % Get outdegree of all nodes
    outdegree_zero_nodes = out_degrees == 0;  % Find nodes with outdegree zero
    % Get the corresponding bus IDs
    bus_ids_outdegree_zero = connected_buses(outdegree_zero_nodes);


    % Step 10: Add a legend
    hold on;  % Hold on for adding legend

    % Create a legend for node types
    scatter(nan, nan, 100, [1 0 0], 'filled', 'DisplayName', 'Load Bus');  % Red for load bus
    scatter(nan, nan, 100, [0 1 0], 'filled', 'DisplayName', 'Generator Bus');  % Green for generator bus

    % Display the legend
    legend('Location', 'Northeast');

    hold off;  % Release hold

    %% Load Update
    
    loadsi = [3, 6, 9, 15, 18, 21, 23, 26, 29, 39, 42, 46, 51, 57, 60, 74, 84, 87, 89, 95, ...
         103, 106, 109, 113, 123, 129, 136, 140, 143, 150, 152, 157, 160, 163, 167, ...
         169, 171, 174, 178, 181, 184, 186, 190, 195, 198, 200, 203, 205, 209, 212, ...
         214, 217, 219, 222, 227, 234, 239, 242, 249, 251, 257, 264, 276, 284, 287, ...
         291, 294, 300, 303, 306, 319, 322, 325, 329, 337, 340, 348, 351, 354, 356, ...
         99, 120, 271, 297];

    for i = 1:length(loadsi)
        bus_index = find(mpc.bus(:, 1) == loadsi(i));
        if ~isempty(bus_index)
            mpc.bus(bus_index, 3) = realLoads.final_array1(randi([1,41]),t.t+1);  % Pd
            mpc.bus(bus_index, 4) = reactiveLoads.final_array1(randi([1,41]),t.t+1);   % Qd
        else
            warning(['Bus ID ' num2str(loadsi(i)) ' not found in mpc.bus.']);
        end
    end
    % 
    % mpc.bus(find(mpc.bus(:, 1) == 360), 3) = 0.5;
    % mpc.bus(find(mpc.bus(:, 1) == 68), 3) = 0.01;
    % mpc.bus(find(mpc.bus(:, 1) == 354), 3) = 0.05;

    % Define the 24-hour residential load profile (typical household demand pattern)
    % residential_load_curve = [0.4, 0.35, 0.3, 0.3, 0.35, 0.5, 0.7, 0.8, 1.0, 0.9, ...
    %                           0.8, 0.7, 0.6, 0.55, 0.6, 0.8, 1.0, 1.0, 0.9, 0.75, ...
    %                           0.6, 0.5, 0.45, 0.4];  % Values as a fraction of peak load
    % 
    % % Get the current hour of the day (adjust based on the current simulation time)
    % current_hour = mod(t.t, 1440) / 60;  % Adjust for your simulation time steps
    % 
    % % Interpolate to get the load factor for the current hour
    % load_factor = residential_load_curve(floor(current_hour) + 1);
    % 
    % % % Extract 'from' and 'to' buses from the branch data
    % % from_buses = mpc.branch(:, 1);
    % % to_buses = mpc.branch(:, 2);
    % % 
    % % % Get the unique bus IDs in the network
    % % all_buses = unique([from_buses; to_buses]);
    % % 
    % % % Identify buses with outgoing connections (out-degree > 0)
    % % buses_with_outgoing = unique(from_buses);
    % % 
    % % % Identify buses with no outgoing connections (out-degree = 0)
    % % bus_ids_outdegree_zero = setdiff(all_buses, buses_with_outgoing);  % These are the load buses
    % % 
    % % Now you can proceed with your load update function
    % loadsi = bus_ids_outdegree_zero;
    % num_buses = length(loadsi);  % Total number of load buses
    % % 
    % % % Total desired active power during peak hours (25 MW)
    % % total_peak_power = 25;  % MW
    % % mean_Pd_peak = total_peak_power / num_buses;  % Mean Pd per bus during peak hours
    % % 
    % % % Calculate appropriate standard values for Pd and Qd
    % % % Set the desired mean active power demand per bus
    % % standard_Pd = mean_Pd_peak;  % Set this to match your desired average (25 MW total)
    % % standard_Qd = 5;              % Standard reactive power demand (in kVar) - adjust as needed
    % 

    % disp(realLoads.final_array1)
    for i = 1:41
        bus_index = find(mpc.bus(:, 1) == realLoads.final_array1(i,1));
        if ~isempty(bus_index)
            mpc.bus(bus_index, 3) = realLoads.final_array1(i,t.t+1);  % Pd in MW
            mpc.bus(bus_index, 4) = reactiveLoads.final_array1(i,t.t+1);  % Qd in MVAr
        else
            warning(['Bus ID ' num2str(realLoads.final_array1(i,1)) ' not found in mpc.bus.']);
        end
    end
    % 
    % 
    % % Step 9: Initialize node colors based on loads and generators
    % nodeColors = zeros(length(connected_buses), 3);  % Initialize node color array to default (grey)
    % 
    % % Check for generators and loads on buses
    % generator_indices = ismember(mpc.gen(:, 1), connected_buses);  % Find buses with generators
    % generator_buses = mpc.gen(generator_indices, 1);  % Get generator bus IDs
    % load_indices = ismember(mpc.bus(:, 1), connected_buses);  % Logical index for connected buses
    % loads = mpc.bus(load_indices, 3) + 1i * mpc.bus(load_indices, 4);  % Complex loads
    % 
    % % Set node colors based on loads and generators
    % for i = 1:length(connected_buses)
    %     if abs(loads(i)) > 0  % Check if the load is non-zero
    %         nodeColors(i, :) = [1 0 0]; % Red for load
    %     elseif ismember(connected_buses(i), generator_buses)  % Check if the bus has a generator
    %         nodeColors(i, :) = [0, 1, 0]; % Green for generator
    %     end
    % end
    % 
    % % Apply node colors to the plot
    % h.NodeColor = nodeColors;

    %% Check Total Load and Generation
    total_load = sum(mpc.bus(:, 3));  % Total active load
    total_generation = sum(mpc.gen(:, 2));  % Total generation

    fprintf('Total Active Load: %f\n', total_load);
    fprintf('Total Generation: %f\n', total_generation);

save('networkData.mat', 'mpc')
end
