function [rho_start, rho_end, phi_start, phi_end] = get_stratification(S_start, S_end, p)
 
% GET_STRATIFICATION takes in a salt slice at particular timestep, 
% and the parameter structure p (uses p.N and p.H0). 
 
% need to do things different with a sill
sill = p.sill;
sill_depth = length(p.H0)/2 + 1; % sill depth is always halfway in our experiments; this can be changed
 
N = p.N;
H0s = p.H0;
 
% create arrays of layer depth boundaries (zs) and midpoints (zs_mid)
zs = (1:N)' .* H0s; % N x 1 array of layer boundaries
zs_mid = (0.5:1:N-0.5)' .* H0s; % N x 1 array of mid-layer depths
 
% reference salinity and reference density
S_0 = 35;
rho_0 = 1025;
 
% arrays of layer densities from start + end
rho_end = rho_0*(1+p.betaS*(S_end-S_0));
rho_start = rho_0*(1+p.betaS*(S_start-S_0));
 
% if we have a sill, we need to assume start and end densities are
% equal below the sill 
if sill
    rho_start(sill_depth:end) = rho_end(sill_depth:end);
end
 
[rho_avg_start, rho_avg_end, phi_start, phi_end] = deal(zeros(length(rho_start), 1));
 
% calculate depth averages of density and then pot. energy anomaly
for i=1:length(H0s)
    rho_avg_start(i) = (1/zs(i)) .* sum(rho_start(1:i).*H0s(1:i));
    rho_avg_end(i) = (1/zs(i)) .* sum(rho_end(1:i).*H0s(1:i));
 
    % calculate potential energy anomaly
    phi_start(i) = (1/zs(i)) * sum(p.g * (rho_start(1:i) - rho_avg_start(1:i)) .* zs_mid(1:i) .* H0s(1:i));
    phi_end(i) = (1/zs(i)) * sum(p.g * (rho_end(1:i) - rho_avg_end(1:i)) .* zs_mid(1:i) .* H0s(1:i));
 
end
 
end