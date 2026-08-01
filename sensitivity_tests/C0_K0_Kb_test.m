% Sensitivity tests for Sout, Qin, deltaS to C0, K0, Kb
% 800m depth, no sill, land-terminating, fw=900, 45 layers
%       Makes three contour plots; takeaway is that K0 and Kb do not have any effect
%       validated by timescale checks (see timescales_marine.fig and
%       timescales_land.fig)

clear; close all;
 
path2sourcecode = '/Users/antara/Documents/MATLAB/SAGE-Lab-fjord-rpm';
addpath(genpath(path2sourcecode));
 
% basic params
type = "land";
fw = 900;
shelf = "c";
H = 800;
sill = false;
N = 45;
dt = 0.05;
t_end = 3*365;
t_save_dt = 1;
 
[p,t,f,a] = setup_fjordrpm(type, fw, shelf, H, sill, N, dt, t_end, t_save_dt);
 
num = 50; % number of data pts

% ranges to test sensitivity over
C0s = logspace(3,7,num);
K0s = 5.*logspace(-5,-1,num);
Kbs = logspace(-8,-4,num);
 
Terms_K0 = zeros(num, 3, num);
Terms_Kb = zeros(num, 3, num);
  
parfor i = 1:num
    local_p = p;
    local_p.C0 = C0s(i);
 
    for j = 1:num
        local_p.K0 = K0s(j);
        local_p.Kb = 1e-6;
        s1 = run_model(local_p, t, f, a);
        Terms_K0(i,:,j) = [mean(s1.Sout(300:end)); mean(s1.Qin(300:end)); ...
            mean(s1.Sin(300:end) - s1.Sout(300:end))]';
 
        local_p.K0 = 5e-3;
        local_p.Kb = Kbs(j);
        s2 = run_model(local_p, t, f, a);
        Terms_Kb(i,:,j) = [mean(s2.Sout(300:end)); mean(s2.Qin(300:end)); ...
            mean(s2.Sin(300:end) - s2.Sout(300:end))]';
    end
    disp(i);
end
 
Terms_K0 = permute(Terms_K0, [2, 3, 1]);
Terms_Kb = permute(Terms_Kb, [2, 3, 1]);
 
labels = ["S_{out}","Q_{in}","S_{in} - S_{out}"];
 
% create two figures: K0 C0 and Kb C0
figure();
for k = 1:3
    subplot(1,3,k);
    contourf(C0s, K0s, squeeze(Terms_K0(k,:,:)), "ShowText", true, ...
        "LabelFormat", "%0.1f", "FaceAlpha", 0.25)
    title(labels(k));
    xlabel("C_0"); ylabel("K_0");
    set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
    axis square;
end
sgtitle(type+"-Terminating K0 vs C0")
% savefig(type+"_K0_C0.fig");
 
figure();
for k = 1:3
    subplot(1,3,k);
    contourf(C0s, Kbs, squeeze(Terms_Kb(k,:,:)), "ShowText", true, ...
        "LabelFormat", "%0.1f", "FaceAlpha", 0.25)
    title(labels(k));
    xlabel("C_0"); ylabel("K_b");
    set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
    axis square;
end
sgtitle(type+"-Terminating Kb vs C0")
% savefig(type+"_Kb_C0.fig");