% Plots Q_in/Q_FW vs (S_out-S_in)/S_out varying either H or Q_FW
% compared against Knudsen relationship (should be y=1/x)
%   choose shelf type

clear; close all;
 
path2sourcecode = '/Users/antara/Documents/MATLAB/fjordrpm_marine_land';
addpath(genpath(path2sourcecode));
 
type = "marine";
shelf = "ls";
 
%% run over Q_sg magnitude 
fws = linspace(100,1000,10);
n = 2*length(fws);
[circ, strat, q_fws] = deal(zeros(1,n));
 
j = 1;
for icebergs = [true, false]
    for i = 1:length(fws)
        % turn on melting
        melt = 1;
        [p,t,f,a] = setup_fjordrpm(type, fws(i), shelf, 800, false, 50, 0.1, 3*365, 1, melt);
        
        % if icebergs = true, add icebergs 
        if icebergs
            zc = cumsum(a.H0)-a.H0/2; % depth of centre of layers
            iceprofile = exp(-zc/100); % profile before scaling
            a.I0 = (2e8/sum(iceprofile))*iceprofile; % surface area profile used by FjordRPM (m^2)
        end

        s = run_model(p,t,f,a);
 
        Qin = s.Qin(end);
        Q_FW = s.Q_fw(end);
        S_out = s.Sout(end);
        S_in = s.Sin(end);
 
        circ(j) = Qin/Q_FW;
        strat(j) = (S_in-S_out)/S_out;
        q_fws(j) = s.Q_fw(end);
 
        j = j+1;
    end
end
 
plot_reg(strat, circ, q_fws, 'marine: icebergs and no icebergs');
 

%% a function to plot since I do it twice
function plot_reg(strat, circ, labels_vals, plot_title)
    n = length(circ);
 
    x = linspace(0.01,0.15,100); 
    y = 1 ./ x;
 
    figure(); hold on
    plot(x, y, '--','Color','black')
    scatter(strat(1:n/2), circ(1:n/2), 'b', 'filled','diamond') %icebergs
    scatter(strat(n/2+1:end), circ(n/2+1:end), 'cyan', 'filled') %no icebergs
    legend({'','icebergs','no icebergs'})
 
    labels = "  " + string(round(labels_vals));
    text(strat, circ, cellstr(labels), "FontSize", 7);
 
    ylabel('Q_{in}/Q_{FW}')
    xlabel('\Delta S / S_{out}')
    title(plot_title)
end