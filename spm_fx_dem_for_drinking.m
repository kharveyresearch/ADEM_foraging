function [f, targetx_a] = spm_fx_dem_for_drinking(f,x,v,P)
% updates the flow for responses for drinking behavior
% FORMAT [f]= spm_fx_dem_for_foraging(f,x,v,P)
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

WATER_TARGET=P.nf+2;

%affordances
APPROACH=1;
EAT=2;
DRINK=3;

my_distance_from_water = norm(x.b(:,WATER_TARGET) - x.o(:,BODY));
in_drinking_range =  my_distance_from_water<P.min_dist;

%Update affordances
%=========================================
%respond to salience for approaching
targetx_a = zeros(size(x.a));
targetx_a(APPROACH,WATER_TARGET) = ~in_drinking_range;
targetx_a(DRINK,WATER_TARGET) = in_drinking_range;


%Update actions
%========================================
if x.a(DRINK,WATER_TARGET)>P.min_a && in_drinking_range
    %'drinking'
    f.o(1,MOUTH) =  1-x.o(1,MOUTH);
end



