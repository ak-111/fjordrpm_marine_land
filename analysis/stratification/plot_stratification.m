% Generates independent plots for stratification -- Density, φ, and Δφ

close('all')
 
filenames = ["7_ls"];
labels = ["marine c","marine ls","land c","land ls"];
 
for i = 1:length(filenames)
    load("experiments/experiment_data/"+filenames(i)+".mat", 's','p','f');
 
    S_end = s.S(:,end); % take slices from last timestep
    S_start = s.S(:,1); % and first timestep
 
    [rho_start, rho_end, phi_start, phi_end] = get_stratification(S_start, S_end, p);
 
    delta_phi = phi_end - phi_start;
 
    figure();
 
    z = 800;
    h = z / p.H * p.N;
 
    subplot(1,3,1); hold on
    plot(rho_start(1:h), -p.zs(1:h), 'LineWidth',2);
    plot(rho_end(1:h), -p.zs(1:h), 'LineWidth',1.5);
    title("Density $\rho (z)$", "Interpreter","latex");
    legend({'start','end'});
 
    subplot(1,3,2); hold on
    plot(phi_start(1:h), -p.zs(1:h), 'LineWidth',2);
    plot(phi_end(1:h), -p.zs(1:h), 'LineWidth',1.5);
    title("Strat. Index $\phi (z)$", "Interpreter","latex");
    legend({'start','end'});
 
    subplot(1,3,3); hold on
    plot(delta_phi(1:h), -p.zs(1:h), 'LineWidth',2);
    title("Anomaly $\Delta \phi (z)$", "Interpreter","latex");
 
    sgtitle("Stratification: "+labels(i));
    % savefig("Stratification_"+titles(i));
end