% Compares marine and land (or any runs, just need to change the label/colors) on the same graph.

figure();
 
filenames = ["5_ls","6_ls"]; % choose any 2 or more to compare
labels = ["marine deep sill","marine deep no sill"]; % label files
legend_str = {}; 
colors = ["b","cyan"]; % useful to choose b, g if comparing marine and land
 
for i = 1:length(filenames)
    load("experiments/experiment_data/"+filenames(i)+".mat", 's','p','f');
 
    c = colors(i);
 
    z = p.H;
    h = z / p.H * p.N;
 
    S_end = s.S(:,end); % take slices from last timestep
    S_start = s.S(:,1); % and first timestep
 
    [rho_start, rho_end, phi_start, phi_end] = get_stratification(S_start, S_end, p);
 
    delta_phi = phi_end - phi_start;
 
    % plot both strat indexes
    subplot(1,2,1); hold on
    plot(phi_start(1:h), -p.zs(1:h), '--', 'LineWidth',1.5, 'Color', 'k');
    plot(phi_end(1:h), -p.zs(1:h), 'LineWidth',1.5, 'Color', c);
    legend_str = [legend_str, 'start' + string(i), labels(i)];

 
    % plot potential energy anomaly
    subplot(1,2,2); hold on
    plot(delta_phi(1:h), -p.zs(1:h), 'LineWidth',2, 'Color', c);
end
 
subplot(1,2,1);
title("Stratification Index $\phi (z)$", "Interpreter","latex");
legend(legend_str);
ylabel('Depth (m)')
 
subplot(1,2,2);
title("Anomaly $\Delta \phi (z) (J/m^3)$", "Interpreter","latex");
 
sgtitle("Stratification Comparison");
% savefig('experiments/experiment_figures/compare_strat.fig')