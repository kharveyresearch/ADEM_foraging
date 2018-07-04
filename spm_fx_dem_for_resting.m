function [f, targetx_a] = spm_fx_dem_for_resting(f,x,v,P)
% updates the flow for responses for resting behavior
% FORMAT [f]= L1_fx_dem_for_resting(f,x,v,P)
%
% f    - flow
% x    - hidden states
% v    - hidden causes
% P    - Properties
%__________________________________________________________________________
% Author: Kole Harvey, 2018
 
%bodyparts
BODY=1;
GRIP=2;
MOUTH=3;
LIE=4;

%targets
HOME_TARGET=P.nf+1;

%affordances
APPROACH=1;
EAT=2;


%Update affordances
%=========================================
%respond to salience for approaching
targetx_a = zeros(size(x.a));
targetx_a(APPROACH,HOME_TARGET) = 1;

%Update actions
%========================================
%If reached home, lie down
my_distance_from_home = norm(x.b(:,HOME_TARGET) - x.o(:,BODY));
if my_distance_from_home < P.min_dist && f.o(1,MOUTH)<P.min_a && x.o(1,MOUTH)<P.min_a
    f.o(1,LIE) =  1-x.o(1,LIE);
end



