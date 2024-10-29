% Set up options for the power flow analysis
mpopt = mpoption('pf.nr.max_it', 100, 'pf.tol', 1e-2);
results = runpf('Copy_of_case360.m', mpopt);

% System base power (in MVA)
S_base = 100;

% Extract branch power flows (in MW and MVAr)
PF = results.branch(:, 14);  % Real power flow at 'from' bus (MW)
QF = results.branch(:, 15);  % Reactive power flow at 'from' bus (MVAr)
PT = results.branch(:, 16);  % Real power flow at 'to' bus (MW)
QT = results.branch(:, 17);  % Reactive power flow at 'to' bus (MVAr)

% Convert power flows to p.u.
PF_pu = PF / S_base;  
QF_pu = QF / S_base;  
PT_pu = PT / S_base;  
QT_pu = QT / S_base;  

% Extract branch IDs from the results
branch_ids = (1:size(results.branch, 1))'; % Create branch number array

% Extract bus numbers from the branch data
from_bus_ids = results.branch(:, 1);  
to_bus_ids = results.branch(:, 2);    

% Extract bus voltages
bus_numbers = results.bus(:, 1);      
V_bus = results.bus(:, 8);            

% Map the bus IDs in the branch matrix to the corresponding indices in the bus matrix
[~, from_bus_indices] = ismember(from_bus_ids, bus_numbers);
[~, to_bus_indices] = ismember(to_bus_ids, bus_numbers);      

% Find the voltage at the 'from' and 'to' buses
V_from = V_bus(from_bus_indices);  
V_to = V_bus(to_bus_indices);      

% Calculate complex power flows in p.u.
S_from_pu = PF_pu + 1i * QF_pu;  
S_to_pu = PT_pu + 1i * QT_pu;    

% Calculate the current magnitude for each branch
I_from = abs(S_from_pu ./ V_from);  

% Base voltage for the system (in kV)
V_base = 20;  
I_from_amp = I_from * (S_base * 1e6) / (sqrt(3) * V_base * 1e3);  

%% Extract PDF file
% % Set figure size
% set(gcf, 'Units', 'Inches', 'Position', [0, 0, 11, 8.5]); % Landscape size
% 
% % Set larger figure size for higher detail (increase dimensions)
% set(gcf, 'Units', 'Inches', 'Position', [0, 0, 22, 17]); % Twice the original size
% 
% % Adjust axes to fill the figure
% axis tight;
% set(gca, 'Position', [0, 0, 1, 1]); % Set the axes to fill the figure
% 
% % Add a title
% annotation('textbox', [0.02, 0.1, 1, 1], 'String', 'Δίκτυο Διανομής ΜΤ, τμ. Ζαρκάδια - Τοξότης, νομός Ξάνθης', ...
%            'EdgeColor', 'none', 'FontSize', 20, 'FontWeight', 'bold', ...
%            'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
% 
% % Add a subtitle
% annotation('textbox', [0.02, 0.05, 1, 1], 'String', 'Γραμμή 33X', ...
%            'EdgeColor', 'none', 'FontSize', 16, ...
%            'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
% 
% % Set up a larger paper size and orientation for saving
% set(gcf, 'PaperUnits', 'Inches');
% set(gcf, 'PaperSize', [22, 17]); % Twice the original landscape size for higher detail
% set(gcf, 'PaperPosition', [0, 0, 22, 17]); % Position of the plot on the paper
% 
% % Save the plot as a high-resolution PDF in landscape orientation
% filename = 'network_plot_large.pdf'; % Specify the filename
% print(gcf, filename, '-dpdf', '-r600', '-painters'); % Save as PDF with 600 DPI resolution for more detail
% 
% % Optionally, close the figure after saving
% close(gcf);

% Create HTML content
htmlContent = ['<!DOCTYPE html>' ...
               '<html lang="en">' ...
               '<head>' ...
               '<meta charset="UTF-8">' ...
               '<meta name="viewport" content="width=device-width, initial-scale=1.0">' ...
               '<title>Αποτελέσματα Ανάλυσης Φορτίου</title>' ...
               '<style>' ...
               'body { font-family: Arial, sans-serif; margin: 0; padding: 20px; }' ...
               '.container { max-width: 1200px; margin: 0 auto; padding: 0 20px; }' ...  % Added container for margins
               'h1 { color: #333; }' ...
               'h2 { color: #555; }' ...
               'table { border-collapse: collapse; width: 100%; margin: 20px 0; }' ...
               'th, td { border: 1px solid #ccc; padding: 12px; text-align: center; }' ...
               'th { background-color: #4CAF50; color: white; }' ...
               'tr:nth-child(even) { background-color: #f2f2f2; }' ...
               'tr:hover { background-color: #ddd; }' ...
               'p { font-size: 14px; color: #666; }' ...
               '</style>' ...
               '</head>' ...
               '<body>' ...
               '<div class="container">' ...  % Opening the container div
               '<h1>Ανάλυση Ροής Φορτίου στο δίκτυο ΜΤ της γραμμής 33-Χ</h1>' ...
               '<h2>Γραμμή 33-Χ, Ζαρκάδια - Τοξότες (ν. Ξάνθης)</h2>' ...
               '<embed src="network_plot_large.pdf" width="100%" height="600px" />' ...  % Embed PDF file
               '<h2>Σύνοψη Ανάλυσης Ροής Φορτίου</h2>' ...
               '<table>' ...
               '<tr><th>Αναγνωριστκό ζυγού</th><th>Ζυγός αναχώρησης</th><th>Ζυγός άφιξης</th><th>P (MW)</th><th>Q (MVAr)</th><th>Ένταση ρεύματος (A)</th></tr>'];

% Populate power flow results into HTML
for i = 1:size(results.branch, 1)
    htmlContent = [htmlContent, ...
                   sprintf('<tr><td>%d</td><td>%d</td><td>%d</td><td>%.2f</td><td>%.2f</td><td>%.2f</td></tr>', ...
                   branch_ids(i), results.branch(i, 1), results.branch(i, 2), PF(i), QF(i), I_from_amp(i))];
end

% Close the power flow results table
htmlContent = [htmlContent, '</table>'];

% Add bus data
htmlContent = [htmlContent, '<h2>Δεδομένα Ζυγών</h2>' ...
               '<table>' ...
               '<tr><th>Αναγνωριστικό ζυγού</th><th>Τάση (p.u.)</th><th>Γωνία (μοίρες)</th></tr>'];

% Populate bus data into HTML
for i = 1:length(V_bus)
    htmlContent = [htmlContent, ...
                   sprintf('<tr><td>%d</td><td>%.4f</td><td>%.2f</td></tr>', ...
                   results.bus(i, 1), results.bus(i, 8), results.bus(i, 9))];
end

% Close the bus data table
htmlContent = [htmlContent, '</table></div></body></html>'];  % Closing the container div

% Write the HTML content to a file
htmlFileName = 'Power_Flow_Results.html';
fid = fopen(htmlFileName, 'w');
if fid == -1
    error('Failed to create HTML file: %s', htmlFileName);
end
fprintf(fid, '%s', htmlContent);
fclose(fid);

% Display a message indicating success
fprintf('Power flow results exported to %s\n', htmlFileName);
% Define the filename for the .mat file
I_from_amp_filename = 'I_from_amp_data.mat';  % Set your desired filename here

% Check if the .mat file already exists
if isfile(I_from_amp_filename)
    % Load existing data
    loaded_data = load(I_from_amp_filename, 'current');
    current = loaded_data.current; % Extract existing data
    % Append new data as a new column
    current = [current, I_from_amp];  % Append new column (no transpose needed)
else
    % If file does not exist, initialize the data as a column vector
    current = I_from_amp(:);  % Ensure it's a column vector
end

% Save the updated data back to the .mat file
save(I_from_amp_filename, 'current');  % Save the array to a .mat file
% 
% fprintf('Current saved to %s\n', I_from_amp_filename);
