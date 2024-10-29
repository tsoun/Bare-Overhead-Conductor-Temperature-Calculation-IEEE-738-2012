%% Thanasis Tsounakis
% University of Patras 2023
% This function calculates the transient temperature of a conductor in a given environment.
% It is designed for Substation T-5E in Xanthi, related to line 33x.

function temperatures = tempCalc(Dt, I, type)
    %% Create environment instance and set parameters
    % tic;  % Start timer for performance measurement
    temperatures = [];  % Initialize temperature array
    mode = 'transient';  % Mode of operation
    
    % Set up environment parameters
    env = Environment('clear');
    env.epsilon = 0.2;  % Surface emissivity
    env.alpha = 0.1;    % Absorption coefficient
    env.T_a = 15;       % Ambient temperature in °C
    env.K_th = 1;       % Thermal conductivity coefficient
    env.V_w = 1.5;      % Wind velocity in m/s
    env.Beta = 30;      % Angle related to environmental factors
    
    % Time calculations
    t = 283 * 24 * 60 * 60 + 50 * 60;  % Total time in seconds
    N = floor(t / (24 * 3600));         % Days since epoch
    s = rem(t, 24 * 3600);               % Remaining seconds in the current day
    omega = (s - 12 * 3600) / 3600 * 15; % Solar angle (degrees)
    
    %% Create conductor instances
    % Data acquired from various sources for Rondine ACSR conductor
    rondine = Conductor();  % Instantiate conductor object
    rondine.wAl = 0.072;                    % Weight of aluminum [kg/m]
    rondine.wSt = 0.034;                    % Weight of steel [kg/m]
    rondine.latitude = 36.98;                % Geographical latitude [degrees]
    rondine.R_T_low = 1.093 * 1e-3;         % Resistance at low temperature [Ohm/m]
    rondine.R_T_high = 1.3156 * 1e-3;       % Resistance at high temperature [Ohm/m]
    rondine.T_high = 75;                     % High temperature limit [°C]
    rondine.T_low = 25;                      % Low temperature limit [°C]
    rondine.Z_l = 120;                       % Latitude angle [degrees]
    rondine.H_e = 50;                        % Elevation height [m]
    rondine.D_C = 2.32 * 1e-3;              % Conductor diameter [cm]
    rondine.D_0 = 6.96 * 1e-3;              % Outer diameter [cm]
    rondine.mCpAl = rondine.wAl * 955;      % Heat capacity of aluminum [J/m-°C]
    rondine.mCpSt = rondine.wSt * 476;      % Heat capacity of steel [J/m-°C]
    rondine.mCp = rondine.mCpAl + rondine.mCpSt;  % Total heat capacity [J/m-°C]
    rondine.name = 'ACSR Rondine ⌀ 6.96mm (3x16mm2 ΔΕΗ-GR)'; 
    rondine.T_avg = env.T_a;                % Average temperature [°C]
    rondine.rating = 130;                    % Current rating [A]
    
    % Struzzo ACSR
    struzzo             = Conductor();
    struzzo.wAl         = 0.422;                        % [kg/m]
    struzzo.wSt         = 0.193;                        % [kg/m]
    struzzo.latitude    = 36.98;                        % [degrees]
    struzzo.R_T_low     = 0.0567/(1000*0.3048);         % [Ohm/m]
    struzzo.R_T_high    = 0.0693/(1000*0.3048);         % [Ohm/m]
    struzzo.T_high      = 75;                           % [C]
    struzzo.T_low       = 25;                           % [C]
    struzzo.Z_l         = 120;                          % [degrees]
    struzzo.H_e         = 500;                          % [m]
    struzzo.D_C         = 6.36*1e-3;                    % [cm]
    struzzo.D_0         = 17.28*1e-3;                   % [cm]
    struzzo.mCpAl       = struzzo.wAl*955;              % [J/m-C]
    struzzo.mCpSt       = struzzo.wSt*476;              % [J/m-C]
    struzzo.mCp         = struzzo.mCpAl+struzzo.mCpSt;  % [J/m-C]
    struzzo.name        = 'ACSR Struzzo ⌀ 17.24mm (3x95mm2 ΔΕΗ GR-86)'; 
    struzzo.T_avg       = env.T_a;                      % [C]
    struzzo.rating      = 448;                          % [A]
    
    % Data acquired from various sources for Rondine ACSR conductor
    corvo = Conductor();  % Instantiate conductor object
    corvo.wAl = 0.185;                    % Weight of aluminum [kg/m]
    corvo.wSt = 0.0874;                    % Weight of steel [kg/m]
    corvo.latitude = 36.98;                % Geographical latitude [degrees]
    corvo.R_T_low = 0.000413;         % Resistance at low temperature [Ohm/m]
    corvo.R_T_high = 0.000576;       % Resistance at high temperature [Ohm/m]
    corvo.T_high = 75;                     % High temperature limit [°C]
    corvo.T_low = 25;                      % Low temperature limit [°C]
    corvo.Z_l = 120;                       % Latitude angle [degrees]
    corvo.H_e = 50;                        % Elevation height [m]
    corvo.D_C = 3.44 * 1e-3;              % Conductor diameter [cm]
    corvo.D_0 = 10.32 * 1e-3;              % Outer diameter [cm]
    corvo.mCpAl = corvo.wAl * 955;      % Heat capacity of aluminum [J/m-°C]
    corvo.mCpSt = corvo.wSt * 476;      % Heat capacity of steel [J/m-°C]
    corvo.mCp = corvo.mCpAl + corvo.mCpSt;  % Total heat capacity [J/m-°C]
    corvo.name = 'ACSR Corvo ⌀ 10.32mm (3x35mm2 ΔΕΗ-GR)'; 
    corvo.T_avg = env.T_a;                % Average temperature [°C]
    corvo.rating = 250;                    % Current rating [A]
    
    time = length(I);  % Number of time steps

    % Call function to plot transient temperature
    if strcmp(type, 'rondine')
        temperatures = plotTransientTemp(rondine, env, time, I, N, omega, t, Dt);
    elseif strcmp(type, 'struzzo')
        temperatures = plotTransientTemp(struzzo, env, time, I, N, omega, t, Dt);
    else
        temperatures = plotTransientTemp(corvo, env, time, I, N, omega, t, Dt);
    end
    
    % toc;  % End timer

    %% Function to plot transient temperature
    function [temperatures] = plotTransientTemp(cdr, env, time, I, N, omega, t, Dt)
        cdr.T_s = cdr.T_avg;  % Set initial surface temperature
        cdr = calculate_resistance(cdr);  % Calculate initial resistance
        temperatures = [];
        
        % Calculate initial temperature considering the current
        cdr.T_s = cdr.T_avg - 0.5 * I(1)^2 * cdr.R / (4 * pi * env.K_th);
        
        tempsLoaded = loadTempData();  % Load ambient temperature data
        
        % Ensure ambient temperatures match the length of the time series
        if length(tempsLoaded) > time
            tempsLoaded = tempsLoaded(1:time);  % Adjust to match time series length
        end
        
        % Temperature computation loop
        for i = 1:time
            env.T_a = tempsLoaded(i);  % Update ambient temperature
            temperatures = [temperatures; cdr.T_s];  % Store current temperature
            % Calculate transient temperature for the conductor
            [cdr, env] = transient_conductor_temperature(cdr, env, Dt, I(i), N, omega, t + Dt * i);
        end
        
        % % Create the time vector in minutes
        % time_minutes = (0:1:i-1) * Dt / 60;  % Convert seconds to minutes
        % 
        % % Start time for the plot
        % startTime = datetime('11/10/2020 00:50 AM', 'InputFormat', 'dd/MM/yyyy hh:mm a');
        % timeVector = startTime + minutes(time_minutes);  % Create time vector based on start time
        % 
        % % Ensure the time vector matches the length of the data
        % if length(timeVector) > length(tempsLoaded)
        %     timeVector = timeVector(1:length(tempsLoaded));  % Adjust if necessary
        % end
        % 
        % % Plotting the data
        % yyaxis left
        % plot(timeVector, temperatures, 'LineWidth', 1.5);  % Plot conductor temperature
        % ylabel('Θερμοκρασία Αγωγού (°C)');
        % ylim([0 max(temperatures) * 1.1]);  % Set y-axis limits
        % hold on
        % 
        % % Plot ambient temperatures
        % yyaxis left
        % plot(timeVector, tempsLoaded, 'b', 'LineWidth', 0.5);
        % ylabel('Θερμοκρασία Περιβάλλοντος (°C)');
        % 
        % % Plot the current on the right y-axis
        % yyaxis right
        % plot(timeVector, I(1:i), 'LineWidth', 1.5);
        % ylabel('Ένταση Ρεύματος Γραμμής (A)');
        % ylim([0 max(I) + abs(max(I) - min(I)) * 0.2]);
        % 
        % % Format the x-axis
        % xlabel('Χρόνος (min)');
        % xticks(timeVector(1:60:end));  % Set ticks at hourly intervals
        % xtickformat('HH:mm a');  % Format x-axis labels as hour:minute AM/PM
        % xlim([timeVector(1) timeVector(end)]);  % Set x-axis limits
        % 
        % % Add grid, title, and legend
        % grid on;
        % title('Μεταβατική Θερμοκρασία Αγωγού');
        % legend('Θερμοκρασία Αγωγού', 'Θερμοκρασία Περιβάλλοντος', 'Ένταση Ρεύματος');
    end

    %% Function to read external data
    function [time, I] = readData(filename)
        run(filename);  % Load data from the specified file
        I = I{:,:};  % Extract current data
        time = length(I);  % Determine length of current data
    end
    
    %% Load weather data (ambient temperature)
    function [T] = loadTempData()
        T = loadTemps(length(I));  % Load temperature data
    end

    %% Calculate transient conductor temperature
    function [cdr, env] = transient_conductor_temperature(cdr, env, Dt, I, N, omega, t)
        % Calculate various parameters related to the conductor's thermal behavior
        cdr.K_angle = 1.194 - sind(env.Beta) - 0.194 * cosd(2 * env.Beta) + ...
            0.368 * sind(2 * env.Beta);
        cdr.T_film = (cdr.T_s + env.T_a) / 2;  % Film temperature
        
        % Calculate fluid properties based on temperature
        env.rho_f = (1.293 - 1.525 * 10^(-4) * cdr.H_e + ...
                      6.379 * 10^(-9) * (cdr.H_e)^2) / (1 + 0.00367 * cdr.T_film);
        env.mu_f = (1.458 * 10^(-6) * (cdr.T_film + 273)^(1.5)) / (cdr.T_film + 383.4);
        env.k_f = 2.424 * 10^(-2) + 7.477 * 10^(-5) * cdr.T_film - ...
                   4.407 * 10^(-9) * cdr.T_film^2;
        
        env.N_Re = cdr.D_0 * env.rho_f * env.V_w / env.mu_f;  % Reynolds number
        q_c1 = cdr.K_angle * (1.01 + 1.347 * env.N_Re^(0.52)) * env.k_f * ...
               (cdr.T_s - env.T_a);  % Convection heat transfer (first term)
        q_c2 = cdr.K_angle * 0.754 * env.N_Re^(0.6) * env.k_f * ...
               (cdr.T_s - env.T_a);  % Convection heat transfer (second term)
        env.q_c = max(q_c1, q_c2);  % Maximum convection heat transfer
        
        q_cn = 3.645 * env.rho_f^(0.5) * cdr.D_0^(0.75) * (cdr.T_s - env.T_a)^(1.25);
        if env.V_w == 0
            env.q_c = q_cn;  % Adjust if wind velocity is zero
        end
        
        % Calculate radiative heat transfer
        env.q_r = (17.8 * cdr.D_0 * env.epsilon * ...
                    (((cdr.T_s + 273) / 100)^4 - ((env.T_a + 273) / 100)^4));
        
        % Solar angle calculations
        env.delta = 23.46 * sind((284 + N) / 365 * 360);  % Solar declination angle
        env.x = (sind(omega)) / (sind(cdr.latitude) * cosd(omega) - ...
                                 cosd(cdr.latitude) * tand(env.delta));
        
        % Calculate azimuth angle
        env.C = 0;
        env.C(omega > 0) = env.C + 180;  % Adjust for solar angle
        env.C(env.x < 0) = env.C + 180;  % Further adjustment for azimuth
        cdr.Z_c = env.C + atand(env.x);  % Conductor azimuth angle
        env.H_c = asind(cosd(cdr.latitude) * cosd(env.delta) * cosd(omega) + ...
                        sind(cdr.latitude) * sind(env.delta));  % Altitude angle
        env.theta = acosd(cosd(env.H_c) * cosd(cdr.Z_c - cdr.Z_l));  % Angle to horizontal
        
        % Calculate solar energy contribution
        H_polynomial = [1, env.H_c, env.H_c^2, env.H_c^3, env.H_c^4, env.H_c^5, env.H_c^6];
        env.Q_s = dot(env.A, H_polynomial);  % Solar energy polynomial evaluation
        env.K_solar = 1 + 1.148 * 1e-4 * cdr.H_e;  % Solar factor
        env.Q_se = env.K_solar * env.Q_s;  % Effective solar energy
        env.q_s = env.alpha * env.Q_se * sind(env.theta) * cdr.D_0;  % Solar heat transfer
        env.q_s(env.q_s < 0) = 0;  % Prevent negative solar heat transfer
        
        % Calculate the new temperature
        cdr = calculate_resistance(cdr);  % Update conductor resistance
        
        % Update temperature based on heat balance
        cdr.DT_C = (env.q_s - env.q_c - env.q_r + cdr.R * I^2) / cdr.mCp * Dt;
        cdr.T_avg = cdr.T_avg + cdr.DT_C;  % Update average temperature
        
        % Update surface temperature
        cdr.T_s = cdr.T_avg - 0.5 * I^2 * cdr.R / (4 * pi * env.K_th);
    end
end
