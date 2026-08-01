% Plots Q_in/Q_FW vs (S_out-S_in)/S_out varying either H or Q_FW
% compared against Knudsen relationship (should be y=1/x)
%   choose shelf type

clear; close all;
 
path2sourcecode = '/Users/antara/Documents/MATLAB/SAGE-Lab-fjord-rpm';
addpath(genpath(path2sourcecode));
 
types = ["marine","land"];
shelf = "ls";
 
%% run over Q_FW magnitude (H = 200)
fws = linspace(100,1000,10);
n = length(types)*length(fws);
[circ_fw, strat_fw] = deal(zeros(1,n));
 
j = 1;
for type = types
    for i = 1:length(fws)
        [p,t,f,a] = setup_fjordrpm(type, fws(i), shelf, 200, false, 50, 0.1, 3*365, 1);
        s = run_model(p,t,f,a);
 
        Qin = s.Qin(end);
        if type == "marine"
            Q_FW = s.Qsg(end);
        else
            Q_FW = s.Qr(end);
        end
        S_out = s.Sout(end);
        S_in = s.Sin(end);
 
        circ_fw(j) = Qin/Q_FW;
        strat_fw(j) = (S_in-S_out)/S_out;
 
        j = j+1;
    end
end
 
plot_reg(strat_fw, circ_fw, fws, 'land and marine: Q_{FW} varied');
 
%% run over fjord depth H (Q_FW = 300)
depths = linspace(100,1000,10);
n = length(types)*length(depths);
[circ_H, strat_H] = deal(zeros(1,n));
 
j = 1;
for type = types
    for i = 1:length(depths)
        [p,t,f,a] = setup_fjordrpm(type, 300, shelf, depths(i), false, 50, 0.1, 3*365, 1);
        s = run_model(p,t,f,a);
 
        Qin = s.Qin(end);
        if type == "marine"
            Q_FW = s.Qsg(end);
        else
            Q_FW = s.Qr(end);
        end
        S_out = s.Sout(end);
        S_in = s.Sin(end);
 
        circ_H(j) = Qin/Q_FW;
        strat_H(j) = (S_in-S_out)/S_out;
 
        j = j+1;
    end
end
 
plot_reg(strat_H, circ_H, depths, 'land and marine: H varied');
 

%% a function to plot since I do it twice
function plot_reg(strat, circ, labels_vals, plot_title)
    n = length(circ);
 
    x = linspace(0.008,0.4,100); 
    y = 1 ./ x;
 
    figure(); hold on
    plot(x, y, '--','Color','black')
    scatter(strat(1:n/2), circ(1:n/2), 'b', 'filled')
    scatter(strat(n/2+1:end), circ(n/2+1:end), 'g', 'filled')
    legend({'','marine-terminating','land-terminating'})
 
    labels = repmat("  "+string(labels_vals), 1, 2);
    text(strat, circ, cellstr(labels), "FontSize", 7);
 
    ylabel('Q_{in}/Q_{FW}')
    xlabel('\Delta S / S_{out}')
    title(plot_title)
end