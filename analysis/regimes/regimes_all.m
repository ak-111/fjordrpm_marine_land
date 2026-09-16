% Plots Q_in/Q_FW vs (S_out-S_in)/S_out varying either H or Q_FW
% compared against Knudsen relationship (should be y=1/x)
%   choose shelf type

% marine icebergs/ no icebergs and land (no icebergs, of course) 

clear; close all;

path2sourcecode = '/Users/antara/Documents/MATLAB/fjordrpm_marine_land';
addpath(genpath(path2sourcecode));

types = ["land","marine"];
shelf = "ls";
melt = 1; % turn on melting

%% run over Q_sg magnitude 
fws = linspace(100,1000,10);
n = 3*length(fws);
[circ, strat, q_fws] = deal(zeros(1,n));

j = 1;

%marine icebergs or no icebergs
for icebergs = [true, false]
    for i = 1:length(fws)
        [p,t,f,a] = setup_fjordrpm("marine", fws(i), shelf, 800, false, 50, 0.1, 3*365, 1, melt);

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

%land
for i = 1:length(fws)

    [p,t,f,a] = setup_fjordrpm("land", fws(i), shelf, 800, false, 50, 0.1, 3*365, 1, melt);

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


plot_reg(strat, circ, q_fws, 'marine (+iceberg) and land regimes');


%% a function to plot since I do it twice
function plot_reg(strat, circ, labels_vals, plot_title)
n = length(circ);

x = linspace(0.01,0.4,100); 
y = 1 ./ x;

figure(); hold on
plot(x, y, '--','Color','black')
scatter(strat(1:n/3), circ(1:n/3), 'b', 'filled','diamond') %icebergs
scatter(strat(n/3+1:2*n/3), circ(n/3+1:2*n/3), 'cyan', 'filled') %no icebergs
scatter(strat(2*n/3+1:end), circ(2*n/3+1:end), 'g', 'filled') %land
legend({'','icebergs','no icebergs','land'})

labels = "  " + string(round(labels_vals));
text(strat, circ, cellstr(labels), "FontSize", 7);

ylabel('Q_{in}/Q_{FW}')
xlabel('\Delta S / S_{out}')
title(plot_title)
end