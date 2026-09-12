% Turning on submarine melting parameter
% + adding icebergs

%set up parameters
type = "marine";
fws = linspace(0,1000,50);
shelf = "c";
H = 800;
sill = false;
N = 50;
melt = 1; % turn melting on

[Qim_list, Qsm_list] = deal(zeros([1,length(fws)])); %list to store variables

for i = 1:length(fws)
    fw = fws(i);
    % set up model
    [p,t,f,a] = setup_fjordrpm(type, fw, shelf, H, sill, N,[],[],[], melt);

    % add icebergs following Slater et al. example code 'example3_icebergs.m'
    %   need to specify the iceberg-ocean surface area in each layer. assume an 
    %   exponential profile with total surface area 200 km^2 = 2e8 m^2
    zc = cumsum(a.H0)-a.H0/2; % depth of centre of layers
    iceprofile = exp(-zc/100); % profile before scaling
    a.I0 = (2e8/sum(iceprofile))*iceprofile; % surface area profile used by FjordRPM (m^2)

    % run model
    s = run_model(p, t, f, a);

    % store total fluxes Q_sm (submarine melt flux) and Q_im (iceberg melt
    % flux)

    Qsm = squeeze(sum(s.QMp,2));
    Qim = squeeze(sum(s.QMi));

    Qsm_ss = mean(Qsm(3000:end)); % steady state value
    Qim_ss = mean(Qim(3000:end));

    Qsm_list(i) = Qsm_ss;
    Qim_list(i) = Qim_ss;

end

figure();
plot(fws, Qsm_list)
xlabel('Q_{sg}')
ylabel('Q_{sm}')
title('submarine melt flux as function of Q_{sg}')

figure(); hold on
plot(fws, Qsm_list)
plot(fws, Qim_list)
xlabel('Q_{sg}')
legend('Q_{sm}','Q_{im}')
title('submarine and iceberg melt fluxes as function of Q_{sg}')
