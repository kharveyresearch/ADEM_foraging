function [f]= L1_fx_adem_for(x,v,a,P)
% returns the flow for cued response (with action)
% FORMAT [f]= L1_fx_adem_for(x,v,a,P)
%
% x    - hidden states
% v    - hidden causes (not used)
% a    - action
% P    - Properties
%__________________________________________________________________________
% Author: Kole Harvey, 2018
 
% intialize flow (to ensure fields are aligned)
%--------------------------------------------------------------------------
f    = x;
a = reshape(a,[2 P.np]); %multiple body parts handled separately
f.o  = a - x.o/8;  %pulse forward or backward with decay
f.o(1:2) = a(1:2) - x.o(1:2)/2; %prevent teleport

f.b = zeros(size(x.b));

%Needs dynamics
f.n = (x.n>0).*[-0.005; -0.003; -0.002];


f.grasp = zeros(size(x.grasp));
f.eaten = zeros(size(x.eaten));


% glue target to hand if it has grasped it
%==========================================================================
%bodyparts
BODY=1;
GRIP=2;
MOUTH=3;
LIE=4;


WATER_TARGET=P.nf+2;

%needs
HUNGER=1;
THIRST=2;
REST=3;


%External 'grasp' turned on when gripping object
waterloc = x.b(:,WATER_TARGET);
distance_from_water = norm(waterloc - x.o(:,BODY));    
if distance_from_water<P.min_dist %at water
    if x.o(1,MOUTH)>P.min_a %drinking
        f.n(THIRST) = (x.n(THIRST)<1)*0.1;       %increase hydration
    end
end
                

for target=1:P.nf
    loc = x.b(:,target);
    distance_from_target = norm(loc - x.o(:,BODY));
    
    if distance_from_target<P.min_dist %at food
        if x.o(1,MOUTH)>P.min_a && x.o(1,LIE)<P.min_a         %eating
            if x.eaten(target)<P.min_a
                f.eaten(target) = (x.eaten(target)<1)*0.5;    %target is eaten away
                f.n(HUNGER) = (x.n(HUNGER)<1)*0.6;            %increase nutrition
                return %only eat one thing at a time
            end
        elseif x.o(1,LIE)>P.min_a %resting
            f.n(HUNGER:THIRST) = f.n(HUNGER:THIRST)*0.1;       %nutrition/thirst goes down slower
            f.n(REST) = (f.n(REST)<1)*0.04;                    %increase rest
            return
        end
    end
    
    if distance_from_target<1 && x.o(1,GRIP)>P.min_a
        %Check not grasping something else already
        grasping = x.grasp>P.min_a;
        grasping(target)=0;
        if sum(grasping) == 0
            f.grasp(target) = (1-x.grasp(target))*0.9;    %turn on grasp
        end
    end
    
    %Pull target along if grabbing onto it
    if x.grasp(target)>P.min_a
        if x.o(1,GRIP)>P.min_a
            f.b(:,target) = (x.o(:,BODY) - loc)*1;
        else         %not gripping anymore, let go
            f.grasp(target) = -1-x.grasp(target);
        end
    end
    
end

