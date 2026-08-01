function [p,t,f,a] = setup_fjordrpm(type, fw, shelf, H, sill, N, dt, t_end, t_save_dt)

% SETUP_FJORDRPM
%
% This function takes in adjustable parameters and keeps the following model 
% parameters constant from our specifications
%   fjord width/length
%   time stepping
%   temperature
%   no submarine melting
%   no icebergs)
% And returns all model structures [p t f a] to be fed into a run
%
% Inputs:
%   type  - "marine" or "land"
%             marine: 
%                   sets f.Qsg (subglacial discharge)
%                   p.Hgl = p.H (grounding line = depth)
%                   p.Wp = 400  (width of plume 400)
%             land:   
%                   sets f.Qr  (riverine input)
%                   p.Hgl = 0
%   fw    - magnitude of the discharge/riverine input (any value, m^3/s)
%   shelf - "ls" or "c"
%             ls:   linear shelf salinity profile.
%                   35 at bottom, 33 at surface
%             c:    constant shelf salinity profile.
%                   34 everywhere
%   H     - fjord depth (m), any value
%   sill  - true/false or (1/0) for whether a sill is present.
%           when true, sill depth is set to half the fjord depth
%           (p.Hsill = 0.5*p.H)
%   N     - number of model layers
%
%   dt        - time step in days. default 0.1
%   t_end     - end time in days. default 3 years
%   t_save_dt - save interval in days. default = 0.1
%
% Outputs:
%   p     - parameters
%   t     - time vector
%   f     - forcings
%   a     - initial conditions

% put FjordRPM code on path - update to the location of your code
path2sourcecode = '/Users/antara/Documents/MATLAB/SAGE-Lab-fjord-rpm';
addpath(genpath(path2sourcecode));

% --default params--
p = default_parameters;
p.sm = 0; % melting turned off for now
p.C0 = 1e5;


% check inputs
if strcmpi(type, "marine")
    typenum = 1;
elseif strcmpi(type, "land")
    typenum = 0;
else
    error("invalid type (must be 'marine' or 'land')");
end

if ~(strcmpi(shelf, "ls") || strcmpi(shelf, "c"))
    error("invalid entry for shelf input (must be 'ls' or 'c')");
end

if ~(islogical(sill) || isnumeric(sill)) || ~isscalar(sill)
    error("invalid entry for sill input (must be true/false or 1/0)");
end
sill = logical(sill);

if ~isnumeric(N) || ~isscalar(N) || N < 1 || N ~= round(N)
    error("invalid entry for N (must be + int)");
end

% if the time inputs are empty, default
if nargin < 7 || isempty(dt),        dt = 0.1;        end
if nargin < 8 || isempty(t_end),     t_end = 3*365;      end
if nargin < 9 || isempty(t_save_dt), t_save_dt = 0.1;   end

% --fjord geometry--
p.W = 5e3;          % fjord width (m)
p.L = 60e3;         % fjord length (m)
p.H = H;             % fjord depth (m)
p.sill = double(sill); % 1 if sill present, 0 otherwise
p.Hsill = 0.5*p.H;   % sill depth below surface (m), only used if p.sill=1

% --model layers--
% N = number of layers
a.H0 = (p.H/N)*ones(N,1); % layer thicknesses, taken to be equal

p.Hs = (1:N-1)'.* a.H0(1:end-1); % N-1 x 1 depths of layer boundaries
p.zs = (1:N)'.* a.H0;            % N x 1 depths of layer boundaries
p.zs_mid = (0.5:1:N-0.5)'.* a.H0; % N x 1 mid-layer depths
p.H0 = a.H0;
p.N = N;

% --time stepping--
t = 0:dt:t_end;
p.t_save = 0:t_save_dt:t_end;

f.tsg = t;
f.tsurf = t;

% --shelf forcing--
f.ts = [0, t_end];
f.zs = [-p.H; 0];

if strcmpi(shelf, "ls")
    f.Ss = [35,35;33,33]; % linear profile, 35 bottom > 33 top
else
    f.Ss = 34*ones(length(f.zs), length(f.ts)); % constant salinity
end
f.Ts = 3*ones(length(f.zs), length(f.ts)); % shelf temperature

% --type-dependent fw input--
switch typenum
    case 1 % marine-terminating
        f.Qsg = fw*(f.tsg >= 200);
        f.Qr = 0*f.tsurf;
        p.Hgl = p.H; % grounding depth = fjord depth
        p.Wp = 400;  % plume width

    case 0 % land-terminating
        f.Qsg = 0*f.tsg;
        f.Qr = fw*(f.tsurf >= 200);
        p.Hgl = 0;
        f.Tr = 0*f.tsurf;
        f.Sr = 0*f.tsurf;
end

% --fjord initial conditions--
[a.T0, a.S0] = bin_shelf_profiles(f.Ts(:,1), f.Ss(:,1), f.zs, a.H0);
% no icebergs
a.I0 = 0*a.H0;

end
