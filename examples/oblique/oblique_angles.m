%% Oblique magnets for low stiffness: vary angles
%
% This script examines the effect of varying the magnet angle
% in the force, stiffness, and resonance characteristics of
% an inclined permanent magnet spring.
%
% Vertical force and vertical displacement only are considered here.
%
% A constant magnet gap of zero is used in the first simulation.
% For this simulation, four plots are generated:
%
% * force v displacement
% * stiffness v displacement
% * natural frequency v displacement
% * natural frequency v force
%
% Another simulation is performed below with a larger gap value. The final
% graph (natural frequency v force) is shown only, and a clear difference
% can be seen comparing the two cases.
%

%% setup

close all
clc
arrowsetup = {'HeadLength',6.5,'HeadWidth',4.5,'HeadStyle','cback3'};

if ~exist('willfig','file')
  close all
  willfig = @(str) figure;
  colourplot = @(varargin) disp('');
  draworigin = @(varargin) disp('');
  matlabfrag = @(varargin) disp('');
end

%% constants and calculations

m = 0.01;
angles = 0:5:90;
N_ngl = length(angles);

if isempty(mfilename)
  error('This code chunk must be executed as an m-file')
end

datafile = ['data/',mfilename,'.mat'];
if exist(datafile,'file')
  load(datafile)
else
  [ngl_yrange ngl_forces] = oblique_forces(...
    'magn',1,...
    'unitlength',m,...
    'magratio',0.4,...
    'dispratio',1,...
    'points',200,...
    'magangle',angles,...
    'gapratio',0 ...
    );
  save(datafile,'ngl_yrange','ngl_forces')
end

%% forces

willfig('forces by angle'); clf; hold on

for tt = N_ngl:-1:1
  ff = squeeze(ngl_forces(2,tt,:));
  yy = 1000*squeeze(ngl_yrange(tt,:));
  [Fmax,iFmax]=max(ff);
  
  if iFmax ~= 1
    plot(yy(1:iFmax),ff(1:iFmax),'-','color',0.8*[1 1 1],'UserData','colourplot:ignore')
    plot(yy(iFmax:end),ff(iFmax:end))
    plot(yy(iFmax),Fmax,'.','color',[0 0 0],'UserData','colourplot:ignore')
  else
    plot(yy,ff,'tag',num2str(angles(tt)))
  end
end

set(gca,'xtick',0:2.5:10)
xlim([0 10])
ylim([0 50])
xlabel('Displacement, mm')
ylabel('Force, N')
colourplot(1,N_ngl:-1:1)

H = annotation('arrow',[0.8 0.7],[0.6 0.2]);
set(H,arrowsetup{:})
text(8.5,35,{'Increasing','angle'},'HorizontalAlignment','Center')

matlabfrag('fig/mbq-fvx-angle')


%% stiffnesses

willfig('stiffnesses by angle'); clf; hold on

for tt = 1:N_ngl
  
  ff = squeeze(ngl_forces(2,tt,:));
  yy = squeeze(ngl_yrange(tt,:));
  kk = -gradient(ff,yy(2)-yy(1));
  [Fmax,iFmax]=max(ff);
  
  if iFmax ~= 1
    plot(1000*yy(1:iFmax),kk(1:iFmax)/1000,'--','color',0.7*[1 1 1],'UserData','colourplot:ignore')
    plot(1000*yy(iFmax:end),kk(iFmax:end)/1000)
  else
    plot(1000*yy,kk/1000)
  end
  
  draworigin([0 0],'h','--')
  
end

xlim([0 10])
ylim([-5 20])
set(gca,'xtick',0:2.5:10)
xlabel('Displacement, mm')
ylabel('Stiffness, kN/m')
colourplot;

H = annotation('arrow',[0.24 0.35],[0.45 0.65]);
set(H,arrowsetup{:})
text(2.8,12.8,{'Increasing','angle'})

matlabfrag('fig/mbq-kvx-angle')

%% natural frequencies

willfig('frequencies by angle'); clf; hold on

for tt = 1:N_ngl
  
  ff = squeeze(ngl_forces(2,tt,:));
  yy = squeeze(ngl_yrange(tt,:));
  kk = -gradient(ff,yy(2)-yy(1));
  [Fmax,iFmax]=max(ff);
  
  kk(kk<0)=NaN;
  ww = sqrt(kk./(ff/9.81)); % resonance frequency
  
  plot(1000*yy,ww/(2*pi))
  
end

xlim([0 10])
%ylim([-5 20])
set(gca,'xtick',0:2.5:10)
xlabel('Displacement, mm')
ylabel('Natural frequency, Hz')
colourplot;

H = annotation('arrow',[0.24 0.35],[0.45 0.65]);
set(H,arrowsetup{:})
text(2.8,12.8,{'Increasing','angle'})

matlabfrag('fig/mbq-wvx-angle')

%% resonance v force

willfig('frequency v force, by angle'); clf; hold on

best_angle = angles==35;

for tt = 1:N_ngl
  
  ff = squeeze(ngl_forces(2,tt,:));
  yy = squeeze(ngl_yrange(tt,:));
  kk = -gradient(ff,yy(2)-yy(1));
  kk(kk<0)=NaN;
  
  ww = sqrt(kk./(ff/9.81)); % resonance frequency
  
  ww_nan = isnan(ww);
  if any(ww_nan)
    ff_plot = ff;
    ww_plot = ww;
    ff_plot(ww_nan) = [];
    ww_plot(ww_nan) = [];
    plot(ff_plot([1,1:end]),[0;ww_plot]/2/pi)
  else
    plot(ff,ww/(2*pi))
  end
  
  if tt == find(best_angle)
    text(ff(1)+1,ww(1)/(2*pi),['\SI{',num2str(angles(tt)),'}{\degree}'])
    plot(ff(1),ww(1)/(2*pi),'.','linewidth',2,'color',[0 0 0],'UserData','colourplot:ignore')
  end
  
end

%xlim([0 45])
ylim([0 15])
colourplot;

xlabel('Load force, N')
ylabel('Natural frequency, Hz')

H = annotation('textarrow',[0.26 0.35],[0.35 0.65]);
set(H,'String',{'Increasing','angle'},'HorizontalAlignment','Center',arrowsetup{:})

matlabfrag('fig/mbq-wvf-angle')




%% resonance 2
%
% Recalculate the above simulations with a different value of magnet gap.
% 

m = 0.01;
angles = 0:5:90;
N_ngl = length(angles);

datafile = ['data/',mfilename,'2.mat'];
if exist(datafile,'file')
  load(datafile)
else
  [ngl_yrange2 ngl_forces2] = oblique_forces(...
    'magn',1,...
    'unitlength',m,...
    'magratio',0.4,...
    'dispratio',1,...
    'points',500,...
    'magangle',angles,...
    'gapratio',0.25 ...
    );
  save(datafile,'ngl_yrange2','ngl_forces2')
end

%% frequency v force plot
%
% In this case skip the force and stiffness v displacement graphs,
% since we know what they look like from above and it's the resonance
% that we're most interested in.
% 

willfig('frequency v force, by angle 2'); clf; hold on

best_angle = angles==70;

for tt = 1:N_ngl
  
  ff = squeeze(ngl_forces2(2,tt,:));
  yy = squeeze(ngl_yrange2(tt,:));
  kk = -gradient(ff,yy(2)-yy(1));
  kk(kk<0)=NaN;
  
  ww = sqrt(kk./(ff/9.81)); % resonance frequency
  
  ww_nan = isnan(ww);
  if any(ww_nan)
    ff_plot = ff;
    ww_plot = ww;
    ff_plot(ww_nan) = [];
    ww_plot(ww_nan) = [];
    plot(ff_plot([1,1:end]),[0;ww_plot]/2/pi)
  else
    plot(ff,ww/(2*pi))
  end
  
  if tt == find(best_angle)
    text(ff(1)+1,ww(1)/(2*pi),['\SI{',num2str(angles(tt)),'}{\degree}'])
    plot(ff(1),ww(1)/(2*pi),'.','linewidth',2,'color',[0 0 0],'UserData','colourplot:ignore')
  end
  
end

xlim([0 80])
ylim([0 15])
colourplot;

xlabel('Load force, N')
ylabel('Natural frequency, Hz')

H = annotation('textarrow',[0.56 0.65],[0.35 0.65]);
set(H,'String',{'Increasing','angle'},'HorizontalAlignment','Center',arrowsetup{:})

matlabfrag('fig/mbq-wvf-angle2')