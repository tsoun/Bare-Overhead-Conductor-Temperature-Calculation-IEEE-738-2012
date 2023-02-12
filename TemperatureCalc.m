%%% ΠΑΝΕΠΙΣΤΗΜΙΟ ΠΑΤΡΩΝ %%%
%%% ΑΘΑΝΑΣΙΟΣ ΤΣΟΥΝΑΚΗΣ %%%
%%% ΔΙΠΛΩΜΑΤΙΚΗ ΕΡΓΑΣΙΑ %%%
%
%
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Αρχικοποίηση προβλήματος
clear;
clc;
temperatures = [];

env = Environment('clear');
cdr = Conductor();

env.epsilon = 0.8;
env.alpha = 0.8;
env.T_a = 40;
env.K_th = 1;
env.mC_p = 1310;
env.V_w = 0.61;
cdr.latitude = 30;
cdr.R_T_low = 7.283 * 1e-5;
cdr.R_T_high = 8.688 * 1e-5;
cdr.T_high = 75;
cdr.T_low = 25;
cdr.Z_1 = 90;
cdr.H_e = 0;
cdr.D_c = 10.4 * 1e-3;
cdr.D_0 = 28.12 * 1e-3;
env.Beta = 0;

Dt = 60;

% I: το διάνυσμα του μέτρου της έντασης του ρεύματος ανά κάθε χρονική
% στιγμή δειγματοληψίας
I = zeros([240 1]);
for i = 1:240
    I(i) = 800;
    if i > 100
        I(i) = 1200;
    end
end
cdr.T_avg = env.T_a;

t = 161*24*60*60+11*60*60;
N = floor(t/(24*3600));
s = rem(t, 24*3600);
omega = (s - 12 * 3600) / 3600 * 15;
% fprintf("At t=%ds:\tI=%dA\tT_avg=%.3fC.\n", t, I, cdr.T_avg);

cdr = calculate_resistance(cdr);
cdr.T_s = cdr.T_avg - 0.5 * I(1)^2 * cdr.R / (4 * pi * env.K_th);

temperatures(1) = cdr.T_avg;
for i = 1:239
    DTold = cdr.DT_C;
    fprintf("%d-th iteration:\t", i + 1);
    [cdr, env] = transient_conductor_temperature(cdr, env, Dt, I(i), N, omega, t+60*i);
    DTnew = cdr.DT_C;
    temperatures(i+1) = cdr.T_avg;
    if abs(DTold - DTnew) < 1e-5
        break
    end
end

%T_cond = calculateTemperature(cdr, env, I);

cdr = calc_ampacity(cdr, env);

% Εκτύπωση των δεδομένων σε άξονες θερμοκρασία - χρόνος
yyaxis left
plot(0:1:i, temperatures, 'LineWidth', 1.5);
ylabel('Θερμοκρασία Αγωγού (C)');
ylim([min(temperatures)*0.9 max(temperatures)*1.1])
hold on
yyaxis right
ylabel('Ένταση Ρεύματος Γραμμής (A)');
ylim([-abs(min(I)-max(I))*0.2+min(I) max(I)+abs(min(I)-max(I))])
plot(0:1:i, I(1:i+1), 'LineWidth', 1.5);
xlabel('Χρόνος (min)');
xlim([0 i]);
title('Μεταβατική Θερμοκρασία Αγωγού')
grid on;

%% Υπολογισμός μεγεθών
function [cdr, env] = transient_conductor_temperature(cdr, env, Dt, I, N, omega, t)
    % TRANSIENT CONDUCTOR TEMPERATURE: Εύρεση της θερμοκρασίας του αγωγού
    % συναρτήσει του χρόνου, για βηματική αλλαγή στο ρεύμα αγωγού, σταθερές 
    % περιβαλλοντικές συνθήκες.
    % cdr: αντικείμενο (object) της κλάσης (class) Conductor() (βλ.
    % Conductor.m)
    % env: στιγμιότυπο αντικειμένου (object instance) της κλάσης (class)
    % Environment() (βλ. Environment.c)
    % Dt: το χρονικό διάστημα μεταξύ δύο διαδοχικών στιγμών πρόβλεψης της
    % θερμοκρασίας (βλ. την εξίσωση ΔT_avg)
    % I: το διαρρέον ρεύμα της γραμμής
    % N: η ημέρα του έτους
    % omega: γωνία ώρας ως προς τo μεσημέρι
    % t: χρονική στιγμή
    cdr.K_angle = 1.194 - sind(env.Beta) - 0.194 * cosd(2 * env.Beta) + 0.368 * sind(2 * env.Beta);
    cdr.T_film = (cdr.T_s + env.T_a) / 2;

    env.rho_f = (1.293 - 1.525 * 10^(-4) * cdr.H_e + 6.379 * 10^(-9) * ( ...
        cdr.H_e) .^ 2) / (1 + 0.00367 * cdr.T_film);
    env.mu_f = (1.458 * 10^(-6) * (cdr.T_film + 273)^(1.5)) / ( ...
        cdr.T_film + 383.4);
    env.k_f = 2.424 * 10^(-2) + 7.477 * 10^(-5) * cdr.T_film - 4.407 * 10^(-9) * cdr.T_film^2;
    
    env.N_Re = cdr.D_0 * env.rho_f * env.V_w / env.mu_f;
    q_c1 = cdr.K_angle * (1.01 + 1.347 * env.N_Re^(0.52)) * env.k_f * (cdr.T_s ...
        - env.T_a);
    q_c2 = cdr.K_angle * 0.754 * env.N_Re^(0.6) *  env.k_f * (cdr.T_s ...
        - env.T_a);
    env.q_c = max(q_c1, q_c2);
    q_cn = 3.645 * env.rho_f^(0.5) * cdr.D_0^(0.75) * (cdr.T_s - env.T_a)^(1.25);
    env.q_r = (17.8 * cdr.D_0 * env.epsilon * (((cdr.T_s + 273) / 100)^4 - ...
        ((env.T_a + 273) / 100)^4));
    
    env.delta = 23.46 * sind((284 + N) / 365 * 360);
    env.x = (sind(omega)) / (sind(cdr.latitude) * cosd(omega) - ...
        cosd(cdr.latitude) * tand(env.delta));
    
    env.C = 0;
    env.C(omega > 0) = env.C + 180;
    env.C(env.x < 0) = env.C + 180;
    cdr.Z_c = env.C + atand(env.x);
    env.H_c = asind(cosd(cdr.latitude) * cosd(env.delta) * cosd(omega) + ...
        sind(cdr.latitude) * sind(env.delta));
    env.theta = acosd(cosd(env.H_c) * cosd(cdr.Z_c - cdr.Z_1));
    
    H_polynomial = [1 env.H_c env.H_c^2 env.H_c^3 env.H_c^4 env.H_c^5 env.H_c^6];
    env.Q_s = dot(env.A,H_polynomial);
    env.K_solar = 1 + 1.148*1e-4 * cdr.H_e;
    env.Q_se = env.K_solar * env.Q_s;
    env.q_s = env.alpha * env.Q_se * sind(env.theta) * cdr.D_0;
    env.q_s(env.q_s<0) = 0;

    cdr = calculate_resistance(cdr);
        
    cdr.DT_C = (env.q_s - env.q_c - env.q_r + cdr.R * I^2) / env.mC_p * Dt;
    cdr.T_avg = cdr.T_avg + cdr.DT_C;
    fprintf("t=%ds:\tI=%dA\tT_avg=%.3fC\tdeltaT_avg=%.3fC\tR(%.3f)=%eΩ.\n", ...
        t+Dt, I, cdr.T_avg, cdr.DT_C, cdr.T_avg, cdr.R);
    cdr.T_s = cdr.T_avg - 0.5 * I^2 * cdr.R / (4 * pi * env.K_th);
end