% Super simple coast model with same number of layers but different
% width and length (much bigger)
%   takes a run and uses Q_out and S_out as input for coast
%   coast relaxes to fjord conditions
%
%   note to self: in the future, we want to link up a bunch of coast boxes,
%   which means we'd also consider flow from ocean/neighbor boxes instead of just fjord

clear("all")

%load experiment (see sheet for experiment type)
file = "8_ls";
filename = "experiments/experiment_data/"+file+".mat";
load(filename);

% model-specific time
dtau = 0.1; % time step (in days)
tau_f = 300; % time to end the simulation (in days)
tau = 0:dtau:tau_f; % resulting time vector for simulation

start = length(p.t_save) - tau_f / dtau;

% say depth is the same and we have 10 cells for our coastal model
% big cube
Ni = p.N; % let's say for now that we have the same # of layers
Wi = 15e3; %15 km
Li = 15e3;
Hi = p.H / Ni;
Hs = (p.H / Ni) * ones(Ni, 1);
V_i = Li * Wi * Hi;
V = p.L * p.W * (p.H/p.N);

% decide later if averaging
Q_f = s.QVs(:,start:end); % final volume flux through shelf
Qout_f = (Q_f < 0) .* Q_f; % final outward volume flux 
Qout_f = abs(Qout_f); % now this is a positive flow into coastal cells
Qout_f = Qout_f .* 86400; % to go from m^3 s^-1 to m^3 days^-1

% S_f
Sout_f = (Qout_f .* s.S(:,start:end)) ./ Qout_f; 
S_shelf = s.Ss(:,start:end);
Sout_f(isnan(Sout_f)) = S_shelf(isnan(Sout_f)); % replace Nan entries with shelf salinity at those entries


S = zeros(Ni, length(tau));

S(:,1) = S_shelf(:,1);

for i=1:length(tau)-1
    % timestep all layers
    S(:,i+1) = S(:,i) + ((1/V_i)* Qout_f(:,i) .* ((Sout_f(:,i) - S(:,i)) .* dtau));

end


% suffix s means shelf 
S_start = s.S(:,1);
S_end = s.S(:,end);
S_start_s = S(:,1);
S_end_s = S(:,end);


% get stratification
[rho_start, rho_end, phi_start, phi_end] = get_stratification(S_start, S_end, p);
[rho_start_s, rho_end_s, phi_start_s, phi_end_s] = get_stratification(S_start_s, S_end_s,p);

% plot change in salinity over time, first 4 layers (can change)
figure();
subplot(2,1,1); hold on
plot(tau,S(1:4,:));
plot(tau,Sout_f(1:4,:),'--');
legend({'coast 1','coast 2','coast 3','coast 4','fjord 1','fjord 2','fjord 3', 'fjord 4'},'NumColumns',2)
xlabel('time (days)');
ylabel('Salinity')

subplot(2,1,2);hold on
% calculate anomaly
delta_phi_s = phi_end_s - phi_start_s;
delta_phi = phi_end - phi_start;

% plot differences in anomalies
plot(delta_phi,-p.zs, 'LineWidth',2);
plot(delta_phi_s,-p.zs, 'LineWidth',2);
title("Anomaly $\Delta \phi (z)$", "Interpreter","latex");
legend({'fjord','coast'})

% savefig("coast_strat_"+file+".fig");
