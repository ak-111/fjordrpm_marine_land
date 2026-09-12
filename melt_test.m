% Turning on submarine melting parameter

%set up parameters
type = "marine";
fws = linspace(0,1000,50);
shelf = "c";
H = 800;
sill = false;
N = 50;
melt = 1; % turn melting on

Qsm_list = zeros([1,length(fws)]);

for i = 1:length(fws)
    fw = fws(i);
    % set up model
    [p,t,f,a] = setup_fjordrpm(type, fw, shelf, H, sill, N,[],[],[], melt);
    % run model
    s = run_model(p, t, f, a);

    % store total submarine melt flux Q_sm
    Qsm = squeeze(sum(s.QMp,2));
    Qsm_ss = mean(Qsm(3000:end)); % steady state value
    Qsm_list(i) = Qsm_ss;

end

figure(); hold on
plot(fws, Qsm_list)
xlabel('Q_{sg}')
ylabel('Q_{sm}')
title('submarine melt flux as function of Q_{sg}')
