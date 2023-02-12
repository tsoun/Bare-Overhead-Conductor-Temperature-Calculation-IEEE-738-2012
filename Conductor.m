classdef Conductor
    properties
        latitude
        longitude
        R_T_high
        R_T_low
        T_high
        T_low
        D_0
        D_C
        T_s
        T_avg
        R
        Z_c
        ampacity
        Z_1
        H_e
        D_c
        K_angle
        T_film
        DT_C
    end
    methods
        function obj = calculate_resistance(obj)
            obj.R = (obj.R_T_high - obj.R_T_low) / (obj.T_high - obj.T_low) * (obj.T_avg - obj.T_low) + obj.R_T_low;
        end
        function obj = calc_ampacity(obj, env)
            obj.ampacity = sqrt((env.q_c + env.q_r - env.q_s) / obj.R);
        end
        function T_cond = calculateTemperature(obj, env, I)
            tolerance = 1e-5; 
            T_trial = 50;
            
            % Loop until the I is within tolerance (Steps 2-7)
            while abs(I) > tolerance
                
                % Conductor resistance calculation (Step 3)
                obj.R_cond = obj.R * (1 + env.alpha * (T_trial - env.T_a));
                
                % Convection and radiation heat loss calculation (Step 4)
                env.q_c = env.h * (T_trial - env.T_a);
                env.q_r = 5.67 * 10^-8 * T_trial^4;
                
                % Heat balance equation calculation (Step 5)
                I = sqrt((obj.q_s + q_c + q_r) / obj.R_cond);
                
                % Check if I is within tolerance (Step 6)
                if abs(I) <= tolerance
                    break;
                end
                
                % Update trial temperature (Step 7)
                T_trial = T_trial + 0.1 * I;
                
            end
            
            % Final result
            T_cond = T_trial;
        end
    end
end