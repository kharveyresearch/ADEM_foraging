function [g] = L2_gx_dem_for(x,v,p)
% returns the flow for cued response
% FORMAT [f]= L2_gx_dem_for(x,v,P)
%
% x    - hidden states
% v    - hidden causes (not used)
% P    - Properties
% g    - sensations
%__________________________________________________________________________
% Author: Kole Harvey, 2018
 
g.n = x.n;
g.behavior = spm_softmax(x.behavior,10);