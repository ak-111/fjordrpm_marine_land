%   EXPERIMENTS
%   this file runs 16 experiments which vary:
%       type (land/marine)
%       depth (250m/800m)
%       fw input (300 m^3/s / 900 m^3/s)
%       sill (true or false)
%
%   calls function setup_fjordrpm (see function for elaboration)
%   saves all runs in folder experiments/experiment_data with format n_shelf.mat
%   see spreadsheet 'experiment_filenames.xlsx' for experiment details!

path2sourcecode = '/Users/antara/Documents/MATLAB/SAGE-Lab-fjord-rpm'; %local path
addpath(genpath(path2sourcecode));
 
% parameters to vary
types = ["marine","land"];
depths = [250, 800];
fws = [300, 900];
sills = [true, false];
shelfs = ["c","ls"]; % shelf salinity profile (ls = linear, c = constant)

N = 50; % 50 layers default
 
n = 1;
for type = types
    for H = depths
        for fw = fws
            for sill = sills
                for shelf = shelfs
                    [p,t,f,a] = setup_fjordrpm(type, fw, shelf, H, sill, N); % set up all inputs
                    s = run_model(p, t, f, a);
                    save("experiments/experiment_data/"+n+"_"+shelf, 's','p','t','f','a');
                    disp(n)
                end
                n = n + 1;
            end
        end
    end
end
 