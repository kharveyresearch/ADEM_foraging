function [f] = L2_fx_dem_for(x,v,P)
% returns the flow for cued response
% FORMAT [f]= L2_fx_dem_for(x,v,P)
%
% x    - hidden states
% v    - hidden causes (not used)
% P    - Properties
% f    - flow
%__________________________________________________________________________
% Author: Kole Harvey, 2018
 
f.n = zeros(size(x.n));
x.n = max(0.1,x.n);

f.behavior = zeros(size(x.behavior));
target_x_behavior =  0.1*max(0,min(1,x.behavior)) + 0.9*(1-x.n);
target_x_behavior = min(1,max(0,target_x_behavior));
target_x_behavior = spm_softmax(target_x_behavior,8);

f.behavior = (target_x_behavior - x.behavior);


