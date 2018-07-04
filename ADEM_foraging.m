function ADEM_foraging
% ADEM_foraging
% Foraging simulation utilizing spm_ADEM
% 
% Free to use and modify, but please cite the following paper:
% "Free energy foraging in an affordance landscape. Kole Harvey 2018"
%
% Usage: Set P.EXPERIMENT to 1, 2, or 3 and run.
%__________________________________________________________________________
% Author: Kole Harvey, 2018

seed = 90;
rng(seed);
N      =  450;                               % length of data sequence

homeloc = [0.1;-0.5];
waterloc = [2;-1];
obstloc = [-1 ;0];
obstloc2 = [1 ;1];
obstloc3 = [1 ;-0.5];

P.EXPERIMENT = 3;                           % Changes parameters based on experiment
P.na      = 3;                              % number of affordances: approach, eat, drink
P.nf      = 6;
P.no      = 6;
P.nt      = P.nf+2+P.no;
P.np      = 4;                              % body,grip,mouth,lie
P.min_a   = 0.3;                            % minimum salience to respond to
P.nn      = 3;                              % hunger, drink, rest
P.tau_n  = 300;                             % time constants for needs dynamics
P.min_dist = 0.8;


% hidden states (M)
%--------------------------------------------------------------------------
x.o    = sparse(2,P.np);                    % (theta1,theta2) x (body,grip,mouth,lie)
x.o(:,1) = homeloc;
x.a    = sparse(P.na,P.nt);                 % affordances
x.b    = rand(2,P.nt)*8-5;                  % targets
x.b (:,P.nf+1) = homeloc;
x.b (:,P.nf+2) = waterloc;
x.b(:,P.nf+3) = obstloc;
x.b(:,P.nf+4) = obstloc2;
x.b(:,P.nf+5) = obstloc3;

x.n    = [1;1;1];                           % needs (nutrition, thirst, rest)
x.eaten = sparse(P.nt,1);                   % whether target eaten
      
% Recognition model
%==========================================================================
M(1).E.s = 1;                                % smoothness
M(1).E.n = 3;                                % order of generalised motion
M(1).E.d = 2;                                

 
% precisions: sensory input
%--------------------------------------------------------------------------
V.o = exp(4) + sparse(2,P.np);               % motor (proprioceptive)
V.a = exp(4) + sparse(P.na,P.nt);            % affordance salience (visual)
V.b = exp(4) + sparse(2,P.nt);               % target locations (visual)
V.n = exp(4);                                % needs (interoceptive)

W.o = exp(4) + sparse(2,P.np);               % motor (proprioceptive)
W.a = exp(4) + sparse(P.na,P.nt);            % affordance salience (visual)
W.b = exp(4) + sparse(2,P.nt);               % target location (visual)
W.n = exp(4);                                % needs (interoceptive)


% level 1: Displacement dynamics and mapping to sensory/proprioception
%--------------------------------------------------------------------------
M(1).f  = 'L1_fx_dem_for';                  % plant dynamics
M(1).g  = 'L1_gx_dem_for';                  % prediction
M(1).pE = P;                                % properties
M(1).x  = x;                                % hidden states
M(1).V  = exp(5);                           % error precision
M(1).W  = exp(5);                           % error precision



% level 2
%--------------------------------------------------------------------------
M(2).f  = 'L2_fx_dem_for';
M(2).g  = 'L2_gx_dem_for';

M(2).x.n = [1;1;1];                    % needs - nutrition,thirst,rest
M(2).x.behavior = [1;0;0];             %behavior - foraging,drink,sleep

M(2).V  = exp(5);             % error precision
M(2).W  = exp(5);             % error precision




% generative process
%==========================================================================
 
% hidden states (G)
%--------------------------------------------------------------------------
x.grasp = sparse(P.nt,1);     % whether physically grasping target
x.eaten = sparse(P.nt,1);     % whether target has been eaten

% first level
%--------------------------------------------------------------------------
G(1).f  = 'L1_fx_adem_for';
G(1).g  = 'L1_gx_adem_for';
G(1).pE = P;
G(1).x  = x;                % hidden states

V.o = exp(16);              % motor (proprioceptive)
V.a = exp(5);               % affordance salience
V.b = exp(5);               % target location
V.n = exp(5);               % needs (interoceptive)
G(1).V  = diag(spm_vec(V));  

W.o = exp(16);              % motor (proprioceptive)
W.a = exp(5);               % affordance salience
W.b = exp(5);               % target location 
W.n = exp(5);               % needs (interoceptive)

G(1).W  = diag(spm_vec(W));                  % error precision
G(1).U  = exp(8);                            % gain for action


% second level
%--------------------------------------------------------------------------
G(2).a  = sparse(P.np*2,1);                  % action forces

W.n = exp(5);
W.behavior = exp(5);
G(2).W  = diag(spm_vec(W));
G(2).V  = exp(5);
G(2).v = [0];

C     = sparse(1,N);

 
% generate and invert of over different DA levels
%==========================================================================
DEM.G = G;
DEM.M = M;
DEM.C = C;
DEM.db = 0;
ADEM = spm_ADEM(DEM);

% plot results
%==========================================================================
playmovie=1;
spm_dem_foraging_plot_results(ADEM,playmovie);




