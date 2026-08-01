% Code to see how Qin and deltaS/Sout scale with FW input (0 to 1000)
%   choose:
%       marine/ land
%       shelf type
%   note: 
%       I've commented out some code and figure plotting 
%       that calculates a predicted Qin value for marine-terminating case (Q_calc). 

path2sourcecode = '/Users/antara/Documents/MATLAB/SAGE-Lab-fjord-rpm';
addpath(genpath(path2sourcecode));
 
type = "marine";
shelf = "ls";
H = 250;
sill = false;
N = 40;
dt = 0.1;
t_end = 3*365;
t_save_dt = 1;
sst = 300;
 
fws = linspace(0,1000,50); % subglacial discharge magnitude, 0 to 1000
 
[Q_ins, Q_calc, L_outs, S_ins, S_outs] = deal(zeros(1, length(fws)));
 
for i = 1:length(fws)
    [p,t,f,a] = setup_fjordrpm(type, fws(i), shelf, H, sill, N, dt, t_end, t_save_dt);
 
    s = run_model(p,t,f,a);
 
    Q_ins(i) = mean(s.Qin(sst:end));
    S_ins(i) = mean(s.Sin(sst:end));
    S_outs(i) = mean(s.Sout(sst:end));
 
    L_outs(i) = find_outflow_layer(s, type, sst);
 
    % calculate Q_calc
    % Q_calc(i) = ((p.alphap*p.Wp)^2*p.g*p.betaS*s.S(p.N-1,sst)*fws(i))^(1/3)*((1 - L_outs(i)/p.N)*(p.H));
end
 
% commenting this out for now
% figure(); hold on
% plot(fws, Q_ins);
% plot(fws, Q_calc, '--');
% legend({'Q_{in}','Q_{in} (predicted)'});
% ylabel('Q_{in}');
% xlabel('Q_{FW}');
% % savefig('Qin_vs_QFW_'+type+'.fig');


figure();
yyaxis left
plot(fws, Q_ins);
ylabel('Q_{in}');
yyaxis right
plot(fws,(S_ins-S_outs)./S_outs);
ylabel('S_{in} - S_{out} / S_{out}');
xlabel('Q_{FW}');
% savefig('Sdiff_vs_QFW_'+type+'.fig');