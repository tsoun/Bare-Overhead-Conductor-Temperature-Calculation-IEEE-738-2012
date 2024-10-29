function plotNetworkBranches(mpc, temperatures)
    %% Step 1: Identify all buses involved in branches
    branch_buses = unique([mpc.branch(:, 1); mpc.branch(:, 2)]);
    isolated_buses = setdiff(mpc.bus(:, 1), branch_buses);
    mpc.bus(ismember(mpc.bus(:, 1), isolated_buses), :) = [];  % Remove isolated buses from mpc
    
    %% Step 2: Identify isolated buses (buses not connected by any branch)
    connected_buses = setdiff(branch_buses, isolated_buses);
    
    %% Step 3: Filter branches to exclude those connected to isolated buses
    fbus = mpc.branch(:, 1);  % From bus
    tbus = mpc.branch(:, 2);  % To bus
    
    % Exclude branches that involve isolated buses
    valid_indices = ismember(fbus, connected_buses) & ismember(tbus, connected_buses);
    filtered_fbus = fbus(valid_indices);
    filtered_tbus = tbus(valid_indices);
    
    %% Step 4: Create a directed graph from the filtered buses
    G = digraph(filtered_fbus, filtered_tbus);
    
    %% Step 5: Identify and remove any isolated nodes (buses with no connections)
    node_degrees = indegree(G) + outdegree(G);  % Get the degree of each node in the graph
    isolated_nodes = find(node_degrees == 0);  % Find nodes with no connections
    
    % Remove isolated nodes from the graph
    G = rmnode(G, isolated_nodes);
    
    %% Step 6: Generate bus labels (either bus numbers or names)
    bus_labels = string(connected_buses);  % Create bus labels from bus numbers/names
    
    %% Step 7: Plot the graph with bus names as node labels and without arrowheads
    figure;
    h = plot(G, 'Layout', 'force', 'ArrowSize', 0, 'LineWidth', 3, 'MarkerSize', 5); % Use 'force' layout
    
    % Assign custom node labels (bus names or numbers)
    h.NodeLabel = bus_labels;
    
    % Increase edge length by modifying the node positions
    % Get the positions of the nodes
    x = h.XData;
    y = h.YData;
    
    % Scale factor to increase distance
    scale_factor = 3;  % Increase this value to lengthen edges further
    
    % Update node positions
    h.XData = x * scale_factor;
    h.YData = y * scale_factor;
    
    %% Step 8: Set edge colors based on temperatures and annotate edges
    % Step 2: Initialize edge colors
    num_edges = size(mpc.branch, 1);  % Get the number of branches
    edge_colors = zeros(num_edges, 3);  % RGB colors
    
    % Step 3: Iterate through each branch and set colors based on temperature
    for i = 1:num_edges
        % Get the bus IDs from the branch
        from_bus_id = mpc.branch(i, 1);  % From bus ID
        to_bus_id = mpc.branch(i, 2);    % To bus ID
        
        % Find the corresponding branch index for temperatures
        branch_index = find(mpc.branch(:, 1) == from_bus_id & mpc.branch(:, 2) == to_bus_id);
        
        % Default color (e.g., gray) in case no temperature data is found
        edge_colors(i, :) = [0.5, 0.5, 0.5];  % Default to gray
    
        if ~isempty(branch_index)
            temp = max(temperatures(branch_index, :));  % Get the maximum temperature for the branch
            
            % Set edge color based on temperature
            if temp <= 40
                edge_colors(i, :) = [0, 0.5, 1];  % Light blue for temperatures 0-40
            elseif temp > 40 && temp <= 80
                edge_colors(i, :) = [1, 1, 0];    % Yellow for temperatures 40-80
            elseif temp > 80 && temp <= 200
                edge_colors(i, :) = [1, 0.5, 0];  % Orange for temperatures 80-200
            else
                edge_colors(i, :) = [1, 0, 0];    % Red for temperatures above 200
            end
            
            % Get positions for annotation
            from_idx = find(connected_buses == from_bus_id);
            to_idx = find(connected_buses == to_bus_id);
            
            % Calculate midpoint for annotation
            mid_x = (h.XData(from_idx) + h.XData(to_idx)) / 2;
            mid_y = (h.YData(from_idx) + h.YData(to_idx)) / 2;
    
            % Annotate the midpoint with temperature
            % text(mid_x, mid_y, sprintf('%.1f °C', temp), 'Color', 'k', 'FontWeight', 'bold', 'FontSize', 8, ...
            %      'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
            
            % Plot the edge with the determined color
            line([h.XData(from_idx), h.XData(to_idx)], ...
                 [h.YData(from_idx), h.YData(to_idx)], ...
                 'LineWidth', 1.5, 'Color', edge_colors(i, :), 'HandleVisibility', 'off');
        end
    end




    % Apply edge colors to the plot
    h.EdgeColor = [1 1 1];  % Set edge colors

    % Step 9: Initialize node colors based on loads and generators
    nodeColors = zeros(length(connected_buses), 3);  % Initialize node color array to default (grey)

    % Check for generators and loads on buses
    generator_indices = ismember(mpc.gen(:, 1), connected_buses);  % Find buses with generators
    generator_buses = mpc.gen(generator_indices, 1);  % Get generator bus IDs
    load_indices = ismember(mpc.bus(:, 1), connected_buses);  % Logical index for connected buses
    loads = mpc.bus(load_indices, 3) + 1i * mpc.bus(load_indices, 4);  % Complex loads

    % Set node colors based on loads and generators
    for i = 1:length(connected_buses)
        if abs(loads(i)) > 0  % Check if the load is non-zero
            nodeColors(i, :) = [1 0 0]; % Red for load
        elseif ismember(connected_buses(i), generator_buses)  % Check if the bus has a generator
            nodeColors(i, :) = [0, 1, 0]; % Green for generator
        end
    end

    % Apply node colors to the plot
    h.NodeColor = nodeColors;

    % Step 10: Add a legend
    hold on;  % Hold on for adding legend

    % Create a legend for node types
    scatter(nan, nan, 100, [1 0 0], 'filled', 'DisplayName', 'Load Bus');  % Red for load bus
    scatter(nan, nan, 100, [0 1 0], 'filled', 'DisplayName', 'Generator Bus');  % Green for generator bus

    % Create a legend for edge temperature ranges
    plot(nan, nan, 'LineWidth', 3, 'Color', [0 0.5 1], 'DisplayName', 'Branch Temp: 0-40');  % Light Blue
    plot(nan, nan, 'LineWidth', 3, 'Color', [1 1 0], 'DisplayName', 'Branch Temp: 40-80');  % Yellow
    plot(nan, nan, 'LineWidth', 3, 'Color', [1 0.5 0], 'DisplayName', 'Branch Temp: 80-200');  % Orange
    plot(nan, nan, 'LineWidth', 3, 'Color', [1 0 0], 'DisplayName', 'Branch Temp: >200');  % Red

    % Display the legend
    legend('Location', 'BestOutside');

    hold off;  % Release hold

    % Set title and axis labels for the main plot
    title('Network Branches of the MATPOWER Case (Excluding Isolated Buses)');
    grid on;

    %% Extract PDF file
    % Set figure size
    set(gcf, 'Units', 'Inches', 'Position', [0, 0, 11, 8.5]); % Landscape size
    
    % Set larger figure size for higher detail (increase dimensions)
    set(gcf, 'Units', 'Inches', 'Position', [0, 0, 22, 17]); % Twice the original size
    
    % Adjust axes to fill the figure
    axis tight;
    set(gca, 'Position', [0, 0, 1, 1]); % Set the axes to fill the figure
    
    % Add a title
    annotation('textbox', [0.02, 0.1, 1, 1], 'String', 'Δίκτυο Διανομής ΜΤ, τμ. Ζαρκαδιά - Τοξότες - Ξάνθη', ...
               'EdgeColor', 'none', 'FontSize', 20, 'FontWeight', 'bold', ...
               'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
    
    % Add a subtitle
    annotation('textbox', [0.02, 0.05, 1, 1], 'String', 'Γραμμή 33X - Ιστορικά δεδομένα για τη γραμμή για την 1-7-2019', ...
               'EdgeColor', 'none', 'FontSize', 16, ...
               'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
    
    % Set up a larger paper size and orientation for saving
    set(gcf, 'PaperUnits', 'Inches');
    set(gcf, 'PaperSize', [22, 17]); % Twice the original landscape size for higher detail
    set(gcf, 'PaperPosition', [0, 0, 22, 17]); % Position of the plot on the paper
    
    % Add a legend
    hold on;  % Hold on for adding legend
    
    % Create arrays for node and edge types
    legendEntries = [];  % Store handles for the legend
    
    % Create a plot for the legend, but only once
    h_load_bus = scatter(nan, nan, 200, [1 0 0], 'filled', 'DisplayName', 'Ζυγός PV');  % Double the marker size for load bus
    h_gen_bus = scatter(nan, nan, 200, [0 1 0], 'filled', 'DisplayName', 'Ζυγός PQ');  % Double the marker size for generator bus
    h_temp_0_40 = plot(nan, nan, 'LineWidth', 6, 'Color', [0 0.5 1], 'DisplayName', 'Θερμ. Αγωγού: 0-40°C');  % Double the line width for light blue
    h_temp_40_100 = plot(nan, nan, 'LineWidth', 6, 'Color', [1 1 0], 'DisplayName', 'Θερμ. Αγωγού: 40°C-80°C');  % Double the line width for yellow
    h_temp_100_150 = plot(nan, nan, 'LineWidth', 6, 'Color', [1 0.5 0], 'DisplayName', 'Θερμ. Αγωγού: 80°C-200°C');  % Double the line width for orange
    h_temp_above_150 = plot(nan, nan, 'LineWidth', 6, 'Color', [1 0 0], 'DisplayName', 'Θερμ. Αγωγού: >200°C');  % Double the line width for red
    
    % Collect handles in an array for the legend
    legendEntries = [h_load_bus, h_gen_bus, h_temp_0_40, h_temp_40_100, h_temp_100_150, h_temp_above_150];
    
    % Create the legend in the top right corner
    legendHandle = legend(legendEntries, 'Location', 'northeast');
    
    % Double the font size of the legend
    legendHandle.FontSize = 20;  % Double the original font size
    
    hold off;  % Release hold

    % Save the plot as a high-resolution PDF in landscape orientation
    filename = 'network_plot_temps.pdf'; % Specify the filename
    print(gcf, filename, '-dpdf', '-r600', '-vector'); % Save as PDF with 600 DPI resolution for more detail
    close(gcf);
end
