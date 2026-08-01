% Sensitivity tests to validate scalings

clear("all");
close("all");
 
num = 20; % number of data pts 
% parameters to iterate over
Ns = round(10:100/num:100);
Hs = 100:1000/num:1000;
C0s = logspace(4,6,num);
fws = [300,900];
 
path2sourcecode = '/Users/antara/Documents/MATLAB/SAGE-Lab-fjord-rpm';
addpath(genpath(path2sourcecode));
 
% basic params
type = "marine";
shelf = "ls";
sill = false;
dt = 0.05;
t_end = 2*365;
t_save_dt = 1;
 
controls = ["H","C0","N"];
n = 1;
figure();
for i = 1:2
    fw = fws(i);
    for j = 1:length(controls)
        control = controls(j);
 
        % default vals
        N = 80;
        H = 800;
        C0 = 1e5;
 
        switch control
            case "N"
                values = Ns;
            case "H"
                values = Hs;
            case "C0"
                values = C0s;
        end
 
        [Q_ins, L_outs] = deal(zeros(1, length(values)));
        subplot(2,length(controls),n);
        for k = 1:length(values)
 
            % change each one respectively
            switch control
                case "N"
                    N = values(k);
                case "H"
                    H = values(k);
                case "C0"
                    C0 = values(k);
            end
 
            [p,t,f,a] = setup_fjordrpm(type, fw, shelf, H, sill, N, dt, t_end, t_save_dt);
            p.C0 = C0;
 
            s = run_model(p,t,f,a);
    
            L_outs(k) = find_outflow_layer(s, type); % find H_out
            Q_ins(k) = abs(mean(s.Qin(300:end))); % positive inflow from shelf > fjord
        end

        % plot H_out and Q_in (diff y axes)
        yyaxis right
        plot(values, L_outs);
        ylabel('H_{out}');
 
        yyaxis left
        plot(values, Q_ins);
        ylabel('Q_{in}');
 
        title(sprintf('Q_{FW} = %g, %s varied', fw, control));
        xlabel(control);
        % if control == "C0"
        %     xscale('log')
        % end
 
        n = n + 1;
    end
end

savefig('N_H_C0_sensitivity_'+type+shelf+'.fig');