function spm_dem_foraging_plot_results(DEM, playmovie)
% creates a movie of the simulation
% FORMAT spm_dem_foraging_plot_results(DEM, playmovie)
%
% DEM - DEM structure from reaching simulations
% playmovie - Whether to play movie of simulation 
%
%__________________________________________________________________________
% Author: Kole Harvey, 2018

% Dimensions
%--------------------------------------------------------------------------
N    = size(DEM.pU.x{1},2);
P = DEM.pP.P{1};


% Idxs of each data array
%----------------------------------------------------------------------
%L1
bodyidx = 1:2;
gripidx = 3:4;
mouthidx = 5:6;
lieidx = 7:8;
salienceidx = P.np*2+(1:P.nt*P.na);
approachidx = P.np*2+((1:P.nt)*P.na -(P.na-1));
eatidx = approachidx+1;
targetidx = salienceidx(end)+(1:P.nt*2);
needidx = targetidx(end)+(1:P.nn);
eatenidx = needidx(end)+(1:P.nf);
%L2
behavioridx = P.nn+(1:3);



% data
%----------------------------------------------------------------------
%Calculate needs first and check if the agent died, if so delete record
%after death
needdata = full(DEM.pU.x{1}(needidx,:));
for t=1:N
    if sum(needdata(:,t)<0.0001) >0
        N=t;
        fprintf('Died at timestep %d\n',t);
        break
    end
end
        
body_x    = DEM.pU.x{1}(bodyidx,1:N);             % body 
grip_x    = DEM.pU.x{1}(gripidx,1:N);             % grip 
mouth_x   = DEM.pU.x{1}(mouthidx,1:N);            % mouth 
lie_x   = DEM.pU.x{1}(lieidx,1:N);                % lie 
c    = DEM.qU.x{1}(approachidx,1:N);                   % target contrast

targets = reshape(full(DEM.pU.x{1}(targetidx,1:N)), [2 P.nt N]);
eatendata = full(DEM.pU.x{1}(eatenidx,1:N));
eaten = eatendata>P.min_a;
approachdata = full(DEM.qU.x{1}(approachidx,1:N));
eatdata = full(DEM.qU.x{1}(eatidx,1:N));
saliencedata = full(DEM.qU.x{1}(salienceidx,1:N));
behaviordata = full(DEM.qU.x{2}(behavioridx,1:N));
needdata = full(DEM.pU.x{1}(needidx,1:N));

c    = c - min(c(:)) + 1/32;
c    = c/max(c(:));



% play movie
%-------------------------------------------

if playmovie
    hold off
    h_fig = figure;
    set(gca,'XColor','none');
    set(gca,'YColor','none');
    global i;
    for i = 1:N
        cla
        axis image ij
        hold on


        % trajectory
        %----------------------------------------------------------------------
        plot(body_x(1,1:i),body_x(2,1:i),'k:')

        % targets
        %----------------------------------------------------------------------
        for j = P.nt:-1:1
            if j <= P.nf && eaten(j,i) %eaten food
                color = [0.5 0.0 0.5];
                s = 20;
            elseif j <= P.nf && ~eaten(j,i) %uneaten food
                color = [c(j,i) (1 - c(j,i)) 0];
                s = 40;
            elseif j == P.nf+1 %home
                color = [1 1 0.9];
                s = 150;
            elseif j == P.nf+2 %water
                color = [0.5 0.5 1.0];
                s = 150;
            elseif j > P.nf+2 %obstacle
                 s = 40;
                if P.EXPERIMENT ~=3
                    color = [1 1 1]; %hide
                    s=1;
                else
                	color = [0.2 0.2 0.2];
                end
            end
       

            plot(targets(1,j,i),targets(2,j,i),'.','MarkerSize',s,'color',color);
            if j <= P.nf %Label food
                text(targets(1,j,i)-0.08,targets(2,j,i)-0.04,num2str(j));
            elseif j == P.nf+1 %Home
                text(targets(1,j,i)-0.38,targets(2,j,i)-0.04,'Home');
            elseif j == P.nf+2 %Water
                text(targets(1,j,i)-0.38,targets(2,j,i)-0.04,'Water','color',[1,1,1]);
            end
        end
        
        %  body
        %----------------------------------------------------------------------
        color = [0.7 0 0.7];
        plot(body_x(1,i), body_x(2,i),'--gs',...
            'LineWidth',1,...
            'MarkerSize',20,...
            'MarkerEdgeColor',[0,0,0],...
            'MarkerFaceColor',color);

        
        
        %Denote timestep on figure
        text(3,3.6,sprintf('t=%d',i));
        axis([-4 4 -4 4])
        hold off
        

        drawnow
        if P.EXPERIMENT==1
            if sum([69,195,340]==i)>0
                saveas(gcf,sprintf('%dA%d.png',P.EXPERIMENT,i));
            end
        elseif P.EXPERIMENT==2
            if sum([48,202,250]==i)>0
                saveas(gcf,sprintf('%dA%d.png',P.EXPERIMENT,i));
            end
        elseif P.EXPERIMENT==3
            if sum([53,222,330]==i)>0
                saveas(gcf,sprintf('%dA%d.png',P.EXPERIMENT,i));
            end
        end
    end
end


%Plot graphs
%--------------------------------------
%Approach data
figure;

title('Salience of Approaching Target');
for target = 1:P.nf+2
    ax = subplot(P.nf+2,1,target);
    plot(1:N,approachdata(target,:)');
    if target <= P.nf
        name = sprintf('Fd%d',target);
    elseif target == P.nf+1
        name = 'Home';
    else
        name = 'Water';
    end
    ylabel(name);
    axis(ax,[0 N -1 1.2]);
    
    %Turn off xticks on all but bottom plot
    if target < P.nf+2
        %set(gca,'xtick',[])
        set(gca,'xticklabel',[])
    end
end
saveas(gcf,sprintf('%dC.png',P.EXPERIMENT));

figure;

if P.EXPERIMENT==1
    nplots=3;
else
    nplots=4;
end

i=1;
axisset=[];
FORAGE=1;
DRINK=2;
SLEEP=3;

N=size(behaviordata,2);
if nplots==4
    axisset = [axisset, subplot(nplots,1,i)];
    plot(1:N,behaviordata(FORAGE,:),'r');
    hold on;
    plot(1:N,behaviordata(DRINK,:),'b');
    plot(1:N,behaviordata(SLEEP,:),'y');
    
    title(axisset(end), 'Behavior Salience (Forage, Drink, Sleep)');
    i=i+1;
end


axisset = [axisset, subplot(nplots,1,i)];
plot(eatdata');
title(axisset(end), 'Salience of Food Target');
i=i+1;

axisset = [axisset, subplot(nplots,1,i)];
plot(1:N,grip_x(1,:),'b');
hold on
plot(1:N,mouth_x(1,:),'r');
plot(1:N,lie_x(1,:),'y');
title(axisset(end), 'Proprioception (Grip, Mouth, Lie)');
i=i+1;

%needs
HUNGER=1;
THIRST=2;
REST=3;

axisset = [axisset, subplot(nplots,1,i)];
plot(1:N,needdata(HUNGER,:),'r');
hold on;
plot(1:N,needdata(THIRST,:),'b');
plot(1:N,needdata(REST,:),'y');

title(axisset(end), 'Needs (Nutrition, Hydration, Rest)');

for i=1:nplots
    axis(axisset(i),[0 N -1 1.2]);
end
linkaxes(axisset,'x')

saveas(gcf,sprintf('%dB.png',P.EXPERIMENT));

