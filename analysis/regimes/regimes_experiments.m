% Plots Q_in/Q_FW vs (S_out-S_in)/S_out for the 16 saved experiments (linear shelf),
% compared against the Knudsen relationship (should be y=1/x)
%   choose shelf type

 
n = 16; % number of experiments
phi_depth = 200; % depth (m) at which to evaluate delta_phi
 
% set up arrays (first for values, second for type)
[circ, strat, delta_phi] = deal(zeros(1,n));
[isMarine, isDeep, hasSill, is3x] = deal(false(1,n));

shelf = "ls"; 
 
for i = 1:n
    filename = "experiments/experiment_data/"+i+"_"+shelf+".mat";
    load(filename, 's','p');
 
    Qin = s.Qin(end);
    S_out = s.Sout(end);
    S_in = s.Sin(end);
 
    isMarine(i) = (p.Hgl == p.H);
    if isMarine(i)
        Q_FW = s.Qsg(end);
    else
        Q_FW = s.Qr(end);
    end
    isDeep(i) = (p.H == 800);
    hasSill(i) = logical(p.sill);
    is3x(i) = (Q_FW/900 == 1);
 
    % add to arrays
    circ(i) = Qin/Q_FW;
    strat(i) = (S_in-S_out)/S_out;
end
 
%% PLOT TIME!!
 
x = linspace(0.01,0.3,100);
y = 1 ./ x;
 
figure(); hold on
plot(x, y, '--','Color','black')
 
% iterate thru and change label
% filled = deep, empty = shallow
% cicle = no sill, star = sill
% small = 1xFW, large = 3xFW

for i = 1:n
    if isMarine(i), c = 'b'; else, c = 'g'; end
    if hasSill(i), marker = 'p'; else, marker = 'o'; end
 
    if is3x(i)
        if marker == 'p', sz = 400; else, sz = 200; end % the star is a bit smaller in general; compensate
    else
        if marker == 'p', sz = 100; else, sz = 50; end
    end
 
    if isDeep(i)
        scatter(strat(i), circ(i), sz, c, marker, 'filled');
    else
        scatter(strat(i), circ(i), sz, c, marker, ...
            'LineWidth', 1.5, 'MarkerFaceColor', 'none');
    end
end
 
% make some empty data to have legend only show 2 items
emptyMarine = scatter(nan,nan,100,'b','filled');
emptyLand   = scatter(nan,nan,100,'g','filled');
legend([emptyMarine emptyLand],{'Marine-terminating','Land-terminating'});
 
ylabel('Q_{in}/Q_{FW}')
xlabel('\Delta S / S_{out}')