function [f, targetx_a] = spm_fx_dem_for_foraging(f,x,v,P)
% updates the flow for responses for foraging behavior
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
HOME_TARGET=P.nf+1;


%affordances
APPROACH=1;
EAT=2;

nutrition = max(0.1,x.n(1));
gripping = x.o(1,GRIP) > P.min_a;


%respond to salience for approaching
targetx_a = zeros(size(x.a));

for target=1:P.nf
    targetloc = x.b(:,target);
    my_distance_from_target = norm(targetloc - x.o(:,BODY));
    target_distance_from_home = norm(targetloc - x.b(:,HOME_TARGET));
    in_eating_range = my_distance_from_target < P.min_dist;
    eaten = x.eaten(target) > P.min_a;

    %Update affordances
    %========================================
    if ~gripping && ~eaten
        if target_distance_from_home < 1        %Uneaten target at home
            targetx_a(APPROACH,target) = (~in_eating_range)*(1-nutrition);
            targetx_a(EAT,target) = (in_eating_range)*(1-nutrition)*4;
        elseif my_distance_from_target >P.min_dist     %Target in the field - Approach it
            targetx_a(APPROACH,target) = 6/(min(6,(1+my_distance_from_target)));
        end
    end

    %Update actions
    %========================================
    %Update eating action
    if x.a(EAT,target)>P.min_a && ~eaten && ...
            my_distance_from_target<P.min_dist && ...
            target_distance_from_home < 1 && x.o(1,LIE)<P.min_a
        %'eating'
        f.o(1,MOUTH) = 1-x.o(1,MOUTH);
    end
    
    %Update grip action
    %=========================================
    %Grip the target if reached it
    if target_distance_from_home >1 && my_distance_from_target <P.min_dist           
        f.o(1,GRIP) =  2-x.o(1,GRIP);
    end      
end
            

%Approach home if gripped object
%=========================================
if gripping
    targetx_a(:,:) = 0;
    targetx_a(APPROACH,HOME_TARGET) = 1;
    
    %If reached home, let go of the target
    my_distance_from_home = norm(x.b(:,HOME_TARGET) - x.o(:,BODY));
    if my_distance_from_home < P.min_dist
        %'dropping'
        f.o(1,GRIP) =  -2-x.o(1,GRIP);
    else %Keep gripping
        f.o(1,GRIP) =  2-x.o(1,GRIP);
    end
else
    targetx_a(APPROACH,HOME_TARGET) = -1;
end


