clear("all")

delta_phis = zeros(1,16);
phi_depth = 100;

shelf = "";

for n=1:16
    filename = "experiments/experiment_data/"+string(n)+"_"+shelf+".mat";
    load(filename);
    
    
    % model-specific time
    dtau = 0.1; % time step (in days)
    tau_f = 2; % time to end the simulation (in days)
    tau = 0:dtau:tau_f; % resulting time vector for simulation
    
    start = length(p.t_save) - tau_f / dtau;
    
    % say depth is the same and we have 10 cells for our coastal model
    % big cube
    Ni = 50; % let's say for now that we have the same # of layers
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
    
    S_end_s = S(:,end);
    S_start_s = S(:,1);
    
    % get stratification
    [rho_start_s, rho_end_s, phi_start_s, phi_end_s] = get_stratification(S_end_s, S_start_s, p);
    
    % calculate anomaly
    delta_phi_s = phi_end_s - phi_start_s;

    phi_idx = (phi_depth / p.H/ p.N)*p.H;
    
    delta_phis(n) = delta_phi_s(phi_idx);
end

Experiment = [1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16];
Type = ["marine";"marine";"marine";"marine";"marine";"marine";"marine";"marine";"land";"land";"land";"land";"land";"land";"land";"land"];
Depth = ["shallow";"shallow";"shallow";"shallow";"deep";"deep";"deep";"deep";"shallow";"shallow";"shallow";"shallow";"deep";"deep";"deep";"deep"];
Sill = ['Y';'N';'Y';'N';'Y';'N';'Y';'N';'Y';'N';'Y';'N';'Y';'N';'Y';'N'];
FW_input = [1;1;3;3;1;1;3;3;1;1;3;3;1;1;3;3];
Delta_phi = delta_phis.';

T = table(Experiment, Type, Depth, FW_input, Sill, Delta_phi);
T = sortrows(T, {'Depth','FW_input','Sill','Type'});
writetable(T,'delta_phi_constantshelf_allruns.xlsx')
