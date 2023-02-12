classdef Environment
    properties
        alpha
        epsilon
        T_a
        mC_p
        Vw
        rho_f
        mu_f
        k_f
        N_Re
        q_c
        q_s
        Q_s
        Q_se
        q_r
        delta
        x
        C
        H_c
        theta
        Beta
        A
        K_solar
        K_th
        V_w
    end
    methods
        function obj = Environment(setting)
            if (strcmp(setting, 'clear'))
                obj.A = [-42.2391; 63.8044; -1.9220; 3.46921*1e-2; -3.61118*1e-4; 1.94318*1e-6; -4.07608*1e-9];
            elseif (strcmp(setting, 'industrial'))
                obj.A = [53.1821; 14.2110; 6.6138*1e-1; -3.1658*1e-2; 5.4654*1e-4; -4.3446*1e-6; 1.3236*1e-8];
            end
        end
    end
end