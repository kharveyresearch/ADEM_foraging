function [g]= L1_gx_adem_for(x,v,a,P)
% returns the prediction for cued responses (proprioception and vision)
% FORMAT [g]= L1_gx_adem_cue(x,v,a,P)
%
% x    - hidden states
% v    - hidden causes
% a    - action
% P    - properties
% g    - sensations
%__________________________________________________________________________
% Author: Kole Harvey, 2018

g.o = x.o;
g.p = x.o;
g.b = x.b;
g.a = x.a;%*4;
g.n = x.n;
g.eaten = x.eaten;