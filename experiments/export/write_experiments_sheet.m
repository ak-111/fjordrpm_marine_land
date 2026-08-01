% Loads experiments saved in experiments.m
% Makes a sheet with headings 'Experiment','Type','Depth','FW_input','Sill','Q_in','ΔS_to_Sout','H_outs','H_ins','Δφ (at chosen depth)'
% 1 sheet for each shelf type (specified below)

shelf = "c";
num = 16;
sst = 5000; % steady state index
phi_depth = 100; % depth(m) at which to save delta_phi
 
[Q_in_ss, S_out_ss, delta_S_ss] = deal(zeros(num,1));
H_outs = zeros(num,1);
H_ins = zeros(num,1);
 
% set up categories
Experiment = zeros(num,1);
Type = strings(num,1);
Depth = strings(num,1);
Sill = strings(num,1);
FW_input = zeros(num,1);
delta_phis = zeros(num,1);
 
for n = 1:num
    filename = "experiments/experiment_data/"+n+"_"+shelf+".mat";
    load(filename, 's','p','f');
 
    if p.Hgl == p.H
        type = "marine";
        fw = max(f.Qsg);
    else
        type = "land";
        fw = max(f.Qr);
    end
 
    % flux through layers, mean
    Q_Vs_ss = mean(s.QVs(:,sst:end),2);
 
    Q_in_ss(n) = mean(s.Qin(sst:end));
    S_out_ss(n) = mean(s.Sout(sst:end));
    delta_S_ss(n) = mean(s.Sin(sst:end)-s.Sout(sst:end));
 
    % H_out and H_in
    H_outs(n) = find_outflow_layer(s, type, sst);
    [~, H_ins(n)] = max(Q_Vs_ss);
 
    % Get potential energy anomaly
    S_start = s.S(:,1);
    S_end = mean(s.S(:,sst:end),2);
    [~,~,phi_start,phi_end] = get_stratification(S_start, S_end, p);
    zs = (1:p.N)' .* p.H0;
    
    phi_idx = (phi_depth / p.H/ p.N)*p.H; %get the layer index at chosen depth!
    delta_phis(n) = phi_end(phi_idx) - phi_start(phi_idx);  
 
    % save variation labels for writing to sheet
    Experiment(n) = n;
    Type(n) = type;
    if p.H == 250, Depth(n) = "shallow"; else, Depth(n) = "deep"; end
    if p.sill, Sill(n) = "Y"; else, Sill(n) = "N"; end
    FW_input(n) = fw;

end
 
T = table(Experiment, Type, Depth, FW_input, Sill, Q_in_ss, delta_S_ss./S_out_ss, H_outs, H_ins, delta_phis, ...
    'VariableNames', {'Experiment','Type','Depth','FW_input','Sill','Q_in','ΔS_to_Sout','H_outs','H_ins','Δφ (100m)'});
writetable(T,'experiments_'+shelf+'.xlsx','Sheet','Sheet1');