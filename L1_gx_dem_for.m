function [g]= L1_gx_dem_for(x,v,P)
% returns the prediction for cued responses (proprioception and vision)
% FORMAT [g]= L1_gx_dem_for(x,v,P)
%
% x    - hidden states
% v    - hidden causes
% P    - properties
% g    - sensations
%__________________________________________________________________________
% Author: Kole Harvey, 2018
 
g.o = x.o;
g.p = x.o;
g.b = x.b;
g.a = x.a;
g.n = x.n;
g.eaten = x.eaten;
