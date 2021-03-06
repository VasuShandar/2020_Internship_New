%% Morphine Microglia RNA Scope Analysis 
% Colocalization analysis for multiple gene sets 
% Creates gramm graphs for comparison of variable groups 
% Written by Vasu Shandar & Kevin Coffey 2020
clear all
close all
% read in table matching file name and experiment information
% Key=readtable('Key.xlsx');
% Key.Group=categorical(Key.Group);
% Key.ID=categorical(Key.ID);
% Key.Sex=categorical(Key.Sex);
%% PDE10A Colocalization analysis
% Options
try

% Analysis Folder 
d=dir('.\1.19');
d=d(3:end);
f=('.\Phillip Analysed Images');

for i=1:height(d);
    disp(['Analysing ' d(i).name]);
    T = RNAScopeFiltering(fullfile(d(i).folder,d(i).name), Options);
    if Options.ShowFinalFigure == 1;
        export_fig(fullfile(f,d(i).name),'-m3');
        close all
    end
    if i==1
        PDE10A=T;
        PDE10A.Properties.VariableNames = {'ID', 'colocPercent', 'probeInTarget', 'probeInOther', 'targetCells', 'probeCells'};
    else
        T.Properties.VariableNames = {'ID', 'colocPercent', 'probeInTarget', 'probeInOther', 'targetCells', 'probeCells'};
        PDE10A=[PDE10A; T];
    end
end

% PDE10A = join(Key,PDE10A);

g=gramm('x',PDE10A.Group,'y',PDE10A.colocPercent*100,'color',PDE10A.Group);
g.stat_violin('normalization','width','half',0,'dodge',0,'fill','transparent')
g.geom_jitter('width',.1,'dodge',1,'alpha',.5);
g.stat_summary('geom',{'black_errorbar'},'type','sem','dodge',1);
g.axe_property('LineWidth',1.5,'FontSize',12);
g.set_names('x','Group','y','% Microglia Expressing PDE10A','color','Groups');
g.set_order_options('x',{'SS','MS','MN'},'color',{'SS','MS','MN'});
figure('Position',[100 100 400 350]);
g.draw();

g=gramm('x',PDE10A.Group,'y',PDE10A.probeInTarget,'color',PDE10A.Group);
g.stat_violin('normalization','width','half',0,'dodge',0,'fill','transparent')
g.geom_jitter('width',.1,'dodge',1,'alpha',.5);
g.stat_summary('geom',{'black_errorbar'},'type','sem','dodge',1);
g.axe_property('LineWidth',1.5,'FontSize',12);
g.set_names('x','Group','y','PDE10A Expression in Microglia','color','Groups');
g.set_order_options('x',{'SS','MS','MN'},'color',{'SS','MS','MN'});
figure('Position',[100 100 400 350]);
g.draw();
end

%% Arpp21 Colocalization analysis
% Optionz!
try
Options.DiskSize = 20;
Options.ShowAnalysisFigures = 0;
Options.ShowFinalFigure = 1;
Options.Radius = 20;
Options.RedCellThreshold = 10000;
Options.GreenCellThreshold = 4500;
Options.AreaFilter = [100 800];

% Analysis Folder 
d=dir('.\To Analyse Images\Arpp21');
d=d(3:end);
f=('.\Analysed Images\Arpp21');

for i=1:height(d);
    disp(['Analysing ' d(i).name]);
    T = RNAScopeFiltering(fullfile(d(i).folder,d(i).name), Options);
    if Options.ShowFinalFigure == 1;
        export_fig(fullfile(f,d(i).name),'-m3');
        close all
    end
    if i==1
        Arpp21=T;
        Arpp21.Properties.VariableNames = {'ID', 'colocPercent', 'probeInTarget', 'probeInOther', 'targetCells', 'probeCells'};
    else
        T.Properties.VariableNames = {'ID', 'colocPercent', 'probeInTarget', 'probeInOther', 'targetCells', 'probeCells'};
        Arpp21=[Arpp21; T];
    end
end

% Arpp21 = join(Key,Arpp21);

g=gramm('x',Arpp21.Group,'y',Arpp21.colocPercent*100,'color',Arpp21.Group);
g.stat_violin('normalization','width','half',0,'dodge',0,'fill','transparent')
g.geom_jitter('width',.1,'dodge',1,'alpha',.5);
g.stat_summary('geom',{'black_errorbar'},'type','sem','dodge',1);
g.axe_property('LineWidth',1.5,'FontSize',12);
g.set_names('x','Group','y','% Microglia Expressing Arpp21','color','Groups');
g.set_order_options('x',{'SS','MS','MN'},'color',{'SS','MS','MN'});
figure('Position',[100 100 400 350]);
g.draw();

g=gramm('x',Arpp21.Group,'y',Arpp21.probeInTarget,'color',Arpp21.Group);
g.stat_violin('normalization','width','half',0,'dodge',0,'fill','transparent')
g.geom_jitter('width',.1,'dodge',1,'alpha',.5);
g.stat_summary('geom',{'black_errorbar'},'type','sem','dodge',1);
g.axe_property('LineWidth',1.5,'FontSize',12);
g.set_names('x','Group','y','Arpp21 Expression in Microglia','color','Groups');
g.set_order_options('x',{'SS','MS','MN'},'color',{'SS','MS','MN'});
figure('Position',[100 100 400 350]);
g.draw();
end

%% DRD1 Colocalization analysis
% Optionz!
try
Options.DiskSize = 20;
Options.ShowAnalysisFigures = 0;
Options.ShowFinalFigure = 1;
Options.Radius = 20;
Options.RedCellThreshold = 10000;
Options.GreenCellThreshold = 4500;
Options.AreaFilter = [100 800];

% Analysis Folder 
d=dir('.\To Analyse Images\DRD1');
d=d(3:end);
f=('.\Analysed Images\DRD1');

for i=1:height(d);
    disp(['Analysing ' d(i).name]);
    T = RNAScopeFiltering(fullfile(d(i).folder,d(i).name), Options);
    if Options.ShowFinalFigure == 1;
        export_fig(fullfile(f,d(i).name),'-m3');
        close all
    end
    if i==1
        DRD1=T;
        DRD1.Properties.VariableNames = {'ID', 'colocPercent', 'probeInTarget', 'probeInOther', 'targetCells', 'probeCells'};
    else
        T.Properties.VariableNames = {'ID', 'colocPercent', 'probeInTarget', 'probeInOther', 'targetCells', 'probeCells'};
        DRD1=[DRD1; T];
    end
end

% DRD1 = join(Key,DRD1);

g=gramm('x',DRD1.Group,'y',DRD1.colocPercent*100,'color',DRD1.Group);
g.stat_violin('normalization','width','half',0,'dodge',0,'fill','transparent')
g.geom_jitter('width',.1,'dodge',1,'alpha',.5);
g.stat_summary('geom',{'black_errorbar'},'type','sem','dodge',1);
g.axe_property('LineWidth',1.5,'FontSize',12);
g.set_names('x','Group','y','% Microglia Expressing DRD1','color','Groups');
g.set_order_options('x',{'SS','MS','MN'},'color',{'SS','MS','MN'});
figure('Position',[100 100 400 350]);
g.draw();

g=gramm('x',DRD1.Group,'y',DRD1.probeInTarget,'color',DRD1.Group);
g.stat_violin('normalization','width','half',0,'dodge',0,'fill','transparent')
g.geom_jitter('width',.1,'dodge',1,'alpha',.5);
g.stat_summary('geom',{'black_errorbar'},'type','sem','dodge',1);
g.axe_property('LineWidth',1.5,'FontSize',12);
g.set_names('x','Group','y','DRD1 Expression in Microglia','color','Groups');
g.set_order_options('x',{'SS','MS','MN'},'color',{'SS','MS','MN'});
figure('Position',[100 100 400 350]);
g.draw();
end

%% Grin1 Colocalization analysis
% Optionz!
try
Options.DiskSize = 20;
Options.ShowAnalysisFigures = 0;
Options.ShowFinalFigure = 1;
Options.Radius = 20;
Options.RedCellThreshold = 10000;
Options.GreenCellThreshold = 4500;
Options.AreaFilter = [100 800];

% Analysis Folder 
d=dir('.\To Analyse Images\Grin1');
d=d(3:end);
f=('.\Analysed Images\Grin1');

for i=1:height(d);
    disp(['Analysing ' d(i).name]);
    T = RNAScopeFiltering(fullfile(d(i).folder,d(i).name), Options);
    if Options.ShowFinalFigure == 1;
        export_fig(fullfile(f,d(i).name),'-m3');
        close all
    end
    if i==1
        Grin1=T;
        Grin1.Properties.VariableNames = {'ID', 'colocPercent', 'probeInTarget', 'probeInOther', 'targetCells', 'probeCells'};
    else
        T.Properties.VariableNames = {'ID', 'colocPercent', 'probeInTarget', 'probeInOther', 'targetCells', 'probeCells'};
        Grin1=[Grin1; T];
    end
end

% Grin1 = join(Key,Grin1);

g=gramm('x',Grin1.Group,'y',Grin1.colocPercent*100,'color',Grin1.Group);
g.stat_violin('normalization','width','half',0,'dodge',0,'fill','transparent')
g.geom_jitter('width',.1,'dodge',1,'alpha',.5);
g.stat_summary('geom',{'black_errorbar'},'type','sem','dodge',1);
g.axe_property('LineWidth',1.5,'FontSize',12);
g.set_names('x','Group','y','% Microglia Expressing Grin1','color','Groups');
g.set_order_options('x',{'SS','MS','MN'},'color',{'SS','MS','MN'});
figure('Position',[100 100 400 350]);
g.draw();

g=gramm('x',Grin1.Group,'y',Grin1.probeInTarget,'color',Grin1.Group);
g.stat_violin('normalization','width','half',0,'dodge',0,'fill','transparent')
g.geom_jitter('width',.1,'dodge',1,'alpha',.5);
g.stat_summary('geom',{'black_errorbar'},'type','sem','dodge',1);
g.axe_property('LineWidth',1.5,'FontSize',12);
g.set_names('x','Group','y','Grin1 Expression in Microglia','color','Groups');
g.set_order_options('x',{'SS','MS','MN'},'color',{'SS','MS','MN'});
figure('Position',[100 100 400 350]);
g.draw();
end

%% ITPKA Colocalization analysis
% Optionz!
try
Options.DiskSize = 20;
Options.ShowAnalysisFigures = 0;
Options.ShowFinalFigure = 1;
Options.Radius = 20;
Options.RedCellThreshold = 10000;
Options.GreenCellThreshold = 4500;
Options.AreaFilter = [100 800];

% Analysis Folder 
d=dir('.\To Analyse Images\ITPKA');
d=d(3:end);
f=('.\Analysed Images\ITPKA');

for i=1:height(d);
    disp(['Analysing ' d(i).name]);
    T = RNAScopeFiltering(fullfile(d(i).folder,d(i).name), Options);
    if Options.ShowFinalFigure == 1;
        export_fig(fullfile(f,d(i).name),'-m3');
        close all
    end
    if i==1
        ITPKA=T;
        ITPKA.Properties.VariableNames = {'ID', 'colocPercent', 'probeInTarget', 'probeInOther', 'targetCells', 'probeCells'};
    else
        T.Properties.VariableNames = {'ID', 'colocPercent', 'probeInTarget', 'probeInOther', 'targetCells', 'probeCells'};
        ITPKA=[ITPKA; T];
    end
end

% ITPKA = join(Key,ITPKA);

g=gramm('x',ITPKA.Group,'y',ITPKA.colocPercent*100,'color',ITPKA.Group);
g.stat_violin('normalization','width','half',0,'dodge',0,'fill','transparent')
g.geom_jitter('width',.1,'dodge',1,'alpha',.5);
g.stat_summary('geom',{'black_errorbar'},'type','sem','dodge',1);
g.axe_property('LineWidth',1.5,'FontSize',12);
g.set_names('x','Group','y','% Microglia Expressing ITPKA','color','Groups');
g.set_order_options('x',{'SS','MS','MN'},'color',{'SS','MS','MN'});
figure('Position',[100 100 400 350]);
g.draw();

g=gramm('x',ITPKA.Group,'y',ITPKA.probeInTarget,'color',ITPKA.Group);
g.stat_violin('normalization','width','half',0,'dodge',0,'fill','transparent')
g.geom_jitter('width',.1,'dodge',1,'alpha',.5);
g.stat_summary('geom',{'black_errorbar'},'type','sem','dodge',1);
g.axe_property('LineWidth',1.5,'FontSize',12);
g.set_names('x','Group','y','ITPKA Expression in Microglia','color','Groups');
g.set_order_options('x',{'SS','MS','MN'},'color',{'SS','MS','MN'});
figure('Position',[100 100 400 350]);
g.draw();
end

%% PDYN Colocalization analysis
% Optionz!
try
Options.DiskSize = 20;
Options.ShowAnalysisFigures = 0;
Options.ShowFinalFigure = 1;
Options.Radius = 20;
Options.RedCellThreshold = 10000;
Options.GreenCellThreshold = 4500;
Options.AreaFilter = [100 800];

% Analysis Folder 
d=dir('.\To Analyse Images\PDYN');
d=d(3:end);
f=('.\Analysed Images\PDYN');

for i=1:height(d);
    disp(['Analysing ' d(i).name]);
    T = RNAScopeFiltering(fullfile(d(i).folder,d(i).name), Options);
    if Options.ShowFinalFigure == 1;
        export_fig(fullfile(f,d(i).name),'-m3');
        close all
    end
    if i==1
        PDYN=T;
        PDYN.Properties.VariableNames = {'ID', 'colocPercent', 'probeInTarget', 'probeInOther', 'targetCells', 'probeCells'};
    else
        T.Properties.VariableNames = {'ID', 'colocPercent', 'probeInTarget', 'probeInOther', 'targetCells', 'probeCells'};
        PDYN=[PDYN; T];
    end
end

% PDYN = join(Key,PDYN);

g=gramm('x',PDYN.Group,'y',PDYN.colocPercent*100,'color',PDYN.Group);
g.stat_violin('normalization','width','half',0,'dodge',0,'fill','transparent')
g.geom_jitter('width',.1,'dodge',1,'alpha',.5);
g.stat_summary('geom',{'black_errorbar'},'type','sem','dodge',1);
g.axe_property('LineWidth',1.5,'FontSize',12);
g.set_names('x','Group','y','% Microglia Expressing PDYN','color','Groups');
g.set_order_options('x',{'SS','MS','MN'},'color',{'SS','MS','MN'});
figure('Position',[100 100 400 350]);
g.draw();

g=gramm('x',PDYN.Group,'y',PDYN.probeInTarget,'color',PDYN.Group);
g.stat_violin('normalization','width','half',0,'dodge',0,'fill','transparent')
g.geom_jitter('width',.1,'dodge',1,'alpha',.5);
g.stat_summary('geom',{'black_errorbar'},'type','sem','dodge',1);
g.axe_property('LineWidth',1.5,'FontSize',12);
g.set_names('x','Group','y','PDYN Expression in Microglia','color','Groups');
g.set_order_options('x',{'SS','MS','MN'},'color',{'SS','MS','MN'});
figure('Position',[100 100 400 350]);
g.draw();
end