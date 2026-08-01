% Compares marine and land (or any runs, just need to change the label/colors) on the same graph.

figure();
 
filenames = ["8_ls","16_ls"];
labels = ["marine","land"];
colors = ["b","g"];
 
for i = 1:2
    load("experiments/experiment_data/"+filenames(i)+".mat", 's','p','f');
 
    c = colors(i);
 
    z = 800;
    h = z / p.H * p.N;
 
    S_end = s.S(:,end); % take slices from last timestep
    S_start = s.S(:,1); % and first timestep
 
    [rho_start, rho_end, phi_start, phi_end] = get_stratification(S_start, S_end, p);
 
    delta_phi = phi_end - phi_start;
 
    % plot both strat indexes
    subplot(1,2,1); hold on
    plot(phi_start(1:h), -p.zs(1:h), '--', 'LineWidth',1.5, 'Color', 'k');
    plot(phi_end(1:h), -p.zs(1:h), 'LineWidth',1.5, 'Color', c);
 
    % plot potential energy anomaly
    subplot(1,2,2); hold on
    plot(delta_phi(1:h), -p.zs(1:h), 'LineWidth',2, 'Color', c);
end
 
subplot(1,2,1);
title("Stratification Index $\phi (z)$", "Interpreter","latex");
legend({'start','marine end', '', 'land end'});
ylabel('Depth (m)')
 
subplot(1,2,2);
title("Anomaly $\Delta \phi (z) (J/m^3)$", "Interpreter","latex");
 
sgtitle("Stratification Comparison");
savefig