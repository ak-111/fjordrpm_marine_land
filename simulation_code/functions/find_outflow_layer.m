function l_out = find_outflow_layer(s, type, t0)

% L_OUT finds the layer depth of outflow
%
% **Note to self**: sometimes we want Hout to be the
% number of outflowing layers (when comparing scalings etc) and in some
% cases we want H_out to be the max outflow layer (to see plume intrusion)
% this is worth clarifying soon
%
% if marine-terminating, l_out = location of max outflow
% if land-terminating, l_out = # of outflowing layers


if nargin < 3, t0 = 300; end

Q = mean(s.QVs(:,t0:end),2);

switch type
    case "marine"
        [~, l_out] = min(Q); % this is something to clarify, but 

    case "land"
        l_out = NaN;
        for b = 1:length(Q)-1
            if (Q(b) > 0 && Q(b+1) < 0) || (Q(b) < 0 && Q(b+1) > 0)
                l_out = b;
                break;
            end
        end

    otherwise
        error("invalid type (must be 'marine' or 'land')");
end

end
