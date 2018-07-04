function [f]= L1_fx_dem_for(x,v,P)
% returns the flow for cued response
% FORMAT [f]= L1_fx_dem_for(x,v,P)
%
% x    - hidden states
% v    - hidden causes (not used)
% P    - Properties
% f    - flow
%__________________________________________________________________________
% Author: Kole Harvey, 2018
 
f    = x;
% salience of affordances
f.a = zeros(size(x.a)); 
f.b = zeros(size(x.b));
f.o = zeros(size(x.o));
f.n = (x.n - v.n);
f.b = zeros(size(x.b));


%bodyparts
BODY=1;
GRIP=2;
MOUTH=3;
LIE=4;



%Affordances
APPROACH=1;
EAT=2;

%Needs
nutrition = x.n(1);
hydration = x.n(2);
rest = x.n(3);

%Whether to avoid obstacles
avoid_obstacles=(P.EXPERIMENT==3);

%Default actions
%===========================================
%Not lieing down by default
f.o(1,LIE) = (x.o(1,LIE)>0)*-0.1;

%Close mouth by default
f.o(1,MOUTH) = (x.o(1,MOUTH)>0)*-0.5; 

%Not gripping by default
f.o(1,GRIP) = (x.o(1,GRIP)>0)*-0.1;

%High level behavior
%===========================================
[~,behav] = max(v.behavior);

if P.EXPERIMENT==1 %No high-level behavior
    targetx_a = zeros(size(x.a));
    if nutrition<0.9     %foraging
        [f targetx_a1] = spm_fx_dem_for_foraging(f,x,v,P);
        targetx_a = targetx_a + targetx_a1;
    end
    if hydration<0.9 %drinking
        [f targetx_a2] = spm_fx_dem_for_drinking(f,x,v,P);
        targetx_a = targetx_a + targetx_a2;
    end
    if rest<0.9      %resting
        [f targetx_a3] = spm_fx_dem_for_resting(f,x,v,P);
        targetx_a = targetx_a + targetx_a3;
    end
else
    if behav==1     %foraging
        [f targetx_a] = spm_fx_dem_for_foraging(f,x,v,P);
    elseif behav==2 %drinking
        [f targetx_a] = spm_fx_dem_for_drinking(f,x,v,P);
    else            %resting
        [f targetx_a] = spm_fx_dem_for_resting(f,x,v,P);
    end
end


%Affordance competition
%===========================================
%Bias approach towards winner
[a arg] = max(targetx_a(APPROACH,:));
targetx_a(APPROACH,arg) =targetx_a(APPROACH,arg)*1.1;
targetx_a = reshape(spm_softmax(reshape(targetx_a,[P.na*P.nt,1]),40),[P.na,P.nt]);


f.a = (targetx_a - x.a)*5;


%Approach action
%===========================================
if sum(x.a(APPROACH,:)>P.min_a)>0

    %Head towards weighted avg of salient targets
    loc = (x.a(APPROACH,:)*x.b')';
    vec = loc - x.o(:,BODY);
    
    
    R = @(theta) [cos(theta) -sin(theta); sin(theta) cos(theta)];
         
    if avoid_obstacles
        vec = vec/norm(vec);
        head = vec*0.3;
        xsensorL =  x.o(:,BODY) + R(-pi/8)*head;
        xsensorR = x.o(:,BODY) + R(pi/8)*head;
        
        turnLeft = @(theta) R(theta); 
        turnRight = @(theta) R(-theta); 

        %Avoid obstacles
        for o=1:P.no
            obst_loc = x.b(:,P.nf+2+o);

            actsensL = max(0,0.5-norm(xsensorL-obst_loc))*3;
            actsensR = max(0,0.5-norm(xsensorR-obst_loc))*3;

            %Noise filter on sensors
            actsensL(actsensL<0.2)=0;
            actsensR(actsensR<0.2)=0;

            vec = turnRight(actsensR*pi/2)*turnLeft(actsensL*pi/2)*vec;
        end
    end
    
    %normalize and scale vector
    vec = vec*0.05/norm(vec);

    f.o(:,BODY) = vec; 
    
end
end
