function plotNetworkMainLine(mpc, temperatures, latitudes, longitudes)
    %% Step 1: Identify all buses involved in branches
    branch_buses = unique([mpc.branch(:, 1); mpc.branch(:, 2)]);
    isolated_buses = setdiff(mpc.bus(:, 1), branch_buses);
    mpc.bus(ismember(mpc.bus(:, 1), isolated_buses), :) = [];  % Remove isolated buses from mpc

    %% Step 2: Identify isolated buses (buses not connected by any branch)
    connected_buses = setdiff(branch_buses, isolated_buses);

    %% Step 3: Filter branches to exclude those connected to isolated buses
    fbus = mpc.branch(:, 1);  % From bus
    tbus = mpc.branch(:, 2);  % To bus
    valid_indices = ismember(fbus, connected_buses) & ismember(tbus, connected_buses);
    filtered_fbus = fbus(valid_indices);
    filtered_tbus = tbus(valid_indices);

    %% Step 4: Create a directed graph from the filtered buses
    G = digraph(filtered_fbus, filtered_tbus);

    %% Step 5: Plot the graph on a geographic map
    figure('Units', 'Inches', 'Position', [0, 0, 11, 8.5], 'PaperPositionMode', 'auto');
    ax = geoaxes;  % Use geographic axes
    hold(ax, 'on');

    % Plot branches as geographic lines
    num_edges = numedges(G);
    edge_colors = zeros(num_edges, 3);  % Initialize edge color array
    for i = 1:num_edges
        % Get the bus IDs from the edges
        from_bus_id = G.Edges.EndNodes(i, 1);
        to_bus_id = G.Edges.EndNodes(i, 2);
        
        % Find the corresponding indices in connected_buses (since latitudes and longitudes match connected_buses)
        from_bus_idx = find(connected_buses == from_bus_id);
        to_bus_idx = find(connected_buses == to_bus_id);

        % If indices are not found, skip the plotting for this branch
        if isempty(from_bus_idx) || isempty(to_bus_idx)
            continue;  % Skip if the bus index is not found
        end

        % Get the corresponding branch index for temperatures
        branch_index = find(mpc.branch(:,1) == from_bus_id & mpc.branch(:,2) == to_bus_id);

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

            % Plot the edge between the buses
            geoplot(ax, [latitudes(from_bus_idx), latitudes(to_bus_idx)], ...
                    [longitudes(from_bus_idx), longitudes(to_bus_idx)], ...
                    'LineWidth', 1.5, 'Color', edge_colors(i, :), 'HandleVisibility', 'off');
        end
    end

    % Plot buses as geographic points
    lat_connected = latitudes(ismember(mpc.bus(:, 1), connected_buses));
    lon_connected = longitudes(ismember(mpc.bus(:, 1), connected_buses));

    % Set node colors based on loads and generators
    node_colors = repmat([0.5 0.5 0.5], length(connected_buses), 1);  % Default grey color
    generator_buses = mpc.gen(:, 1);  % Buses with generators
    load_indices = ismember(mpc.bus(:, 1), connected_buses);
    loads = mpc.bus(load_indices, 3) + 1i * mpc.bus(load_indices, 4);  % Complex loads

    for i = 1:length(connected_buses)
        bus_id = connected_buses(i);
        if ismember(bus_id, generator_buses)
            node_colors(i, :) = [0, 1, 0];  % Green for generator bus
        elseif abs(loads(i)) > 0
            node_colors(i, :) = [1, 0, 0];  % Red for load bus
        end
    end

    % Scatter plot for buses
    geoscatter(ax, lat_connected, lon_connected, 60, node_colors, 'filled', 'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');

    % Plot bus IDs (node labels) inside each bus point
    for i = 1:length(lat_connected)
        text(lat_connected(i), lon_connected(i), num2str(connected_buses(i)), ...
            'FontSize', 4, 'FontWeight', 'bold', 'Color', 'w', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end

    % Set a valid basemap for faster rendering
    geobasemap(ax, 'satellite');

    %% Step 6: Create a legend
    hold on;

    % Legend for node types
    load_legend = geoscatter(nan, nan, 100, [1 0 0], 'filled', 'MarkerEdgeColor', 'k', 'DisplayName', 'Ζυγός Φορτίου');
    gen_legend = geoscatter(nan, nan, 100, [0 1 0], 'filled', 'MarkerEdgeColor', 'k', 'DisplayName', 'Ζυγός Παραγωγής');

    % Legend for edge temperature ranges
    temp_legend1 = geoplot(nan, nan, 'LineWidth', 3, 'Color', [0 0.5 1], 'DisplayName', 'Θερμ. Γραμμής: 0-40°C');
    temp_legend2 = geoplot(nan, nan, 'LineWidth', 3, 'Color', [1 1 0], 'DisplayName', 'Θερμ. Γραμμής: 40-80°C');
    temp_legend3 = geoplot(nan, nan, 'LineWidth', 3, 'Color', [1 0.5 0], 'DisplayName', 'Θερμ. Γραμμής: 80-200°C');
    temp_legend4 = geoplot(nan, nan, 'LineWidth', 3, 'Color', [1 0 0], 'DisplayName', 'Θερμ. Γραμμής: >200°C');

    legend([load_legend, gen_legend, temp_legend1, temp_legend2, temp_legend3, temp_legend4], 'Location', 'BestOutside');

    % Existing code for plotting network branches

    % Add Zarkadia, Toxotes, and Xanthi to the map
    cityNames = {'Ζαρκαδιά', 'Τοξότες', 'Ξάνθη'};
    cityLatitudes = [41.018356, 41.0889, 41.125251];
    cityLongitudes = [24.641216, 24.8053, 24.871739];
    
    for i = 1:length(cityNames)
        % Plot the city names on the geographic map
        text(cityLatitudes(i), cityLongitudes(i), cityNames{i}, 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'w');
    end
    
    % Rest of your code
    hold off;

    % Set title and grid
    title('Εργαλείο Αξιολόγησης Κινδύνου Πυρκαγιάς σε Δίκτυο ΜΤ');
    subtitle('Εξετάζοντας τη γραμμή 33Χ και τις διακλαδώσεις της στο τμήμα Χρυσούπολη - Ζαρκαδιά - Ξάνθη');
    grid on;

    %% Extract PDF file
    set(gca, 'LooseInset', [0,0,0,0]);  % Remove all margins from the plot
    set(gcf, 'PaperUnits', 'Inches', 'PaperSize', [11, 8.5]);  % Match paper size with figure size
    print(gcf, 'network_plot_high_res_sat_hot.png', '-dpng', '-r600');  % Save as PNG
    close(gcf);  % Close figure after saving to free up resources
end
