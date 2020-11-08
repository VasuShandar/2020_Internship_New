% Import files and make data sheet
Date1012 = ImportDataFiles("BehaviorData/1012.txt");
Date1013 = ImportDataFiles("BehaviorData/1013.txt");
Date1014 = ImportDataFiles("BehaviorData/1014.txt");
Date1015 = ImportDataFiles("BehaviorData/1015.txt");
Date1016 = ImportDataFiles("BehaviorData/1016.txt");
Date1017 = ImportDataFiles("BehaviorData/1017.txt");
Date1019 = ImportDataFiles("BehaviorData/1019.txt");
Date1020 = ImportDataFiles("BehaviorData/1020.txt");
DataSheet = {'Box', 'Sex', 'Date', 'Infusions', 'HeadEntries', 'Latency', 'ActivePresses', 'InactivePresses'};
DataSheetFinal = [DataSheet;BehavioralDataScript(Date1012);BehavioralDataScript(Date1013);BehavioralDataScript(Date1014);BehavioralDataScript(Date1015);BehavioralDataScript(Date1016);BehavioralDataScript(Date1017);BehavioralDataScript(Date1019);BehavioralDataScript(Date1020)];


%% Loop Version
Files=dir("BehaviorData/");
Files=Files(3:end);

for i=1:length(Files)
    tmp=ImportDataFiles(['BehaviorData/' Files(i).name]);
    t=BehavioralDataScript(tmp);
    if i==1
        MT=t;
    else
        MT=[MT;t];
    end
end



cd('Figures');

[~,~,rnk] = unique(day(MT.Date));

g=gramm('x',rnk,'y',MT.Infusions);
%g.stat_smooth('geom','area');
g.stat_summary('geom',{'errorbar','point'},'type','sem','dodge',.5,'setylim',1);
g.axe_property('LineWidth',1.5,'FontSize',12);
g.axe_property('tickdir','out');
g.set_names('x','Training Day','y','Rewards','color','Sex');
g.set_text_options('base_size',14,'interpreter','none');
g.set_color_options('map','lch','hue_range',[25 385]+25);
figure('Position',[1 1 400 300]);
g.draw();

g=gramm('x',rnk,'y',MT.Infusions,'color',MT.Sex);
%g.stat_smooth('geom','area');
g.stat_summary('geom',{'errorbar','point'},'type','sem','dodge',.5,'setylim',1);
g.axe_property('LineWidth',1.5,'FontSize',12);
g.axe_property('tickdir','out');
g.set_names('x','Training Day','y','Rewards','color','Sex');
g.set_text_options('base_size',14,'interpreter','none');
g.set_color_options('map','lch','hue_range',[25 385]+25);
figure('Position',[1 1 400 300]);
g.draw();
g.export('file_name','Infusions','file_type','png');

g=gramm('x',rnk,'y',MT.HeadEntries,'color',MT.Sex);
%g.stat_smooth('geom','area');
g.stat_summary('geom',{'errorbar','point'},'type','sem','dodge',.5,'setylim',1);
g.axe_property('LineWidth',1.5,'FontSize',12);
g.axe_property('tickdir','out');
g.set_names('x','Training Day','y','Head Entries','color','Sex');
g.set_text_options('base_size',14,'interpreter','none');
g.set_color_options('map','lch','hue_range',[25 385]+25);
figure('Position',[1 1 400 300]);
g.draw();
g.export('file_name','Head Entries','file_type','png');

g=gramm('x',rnk,'y',MT.Latency,'color',MT.Sex);
%g.stat_smooth('geom','area');
g.stat_summary('geom',{'errorbar','point'},'type','sem','dodge',.5,'setylim',1);
g.axe_property('LineWidth',1.5,'FontSize',12,'YScale','log');
g.axe_property('tickdir','out');
g.set_names('x','Training Day','y','Head Entry Latency (s)','color','Sex');
g.set_text_options('base_size',14,'interpreter','none');
g.set_color_options('map','lch','hue_range',[25 385]+25);
figure('Position',[1 1 400 300]);
g.draw();
g.export('file_name','Head Entry Latency','file_type','png');

g=gramm('x',rnk,'y',MT.ActiveLever,'color',MT.Sex);
%g.stat_smooth('geom','area');
g.stat_summary('geom',{'errorbar','point'},'type','sem','dodge',.5,'setylim',1);
g.axe_property('LineWidth',1.5,'FontSize',12);
g.axe_property('tickdir','out');
g.set_names('x','Training Day','y','Lever Presses','color','Sex');
g.set_text_options('base_size',14,'interpreter','none');
g.set_color_options('map','lch','hue_range',[25 385]+25);
figure('Position',[1 1 400 300]);
g.draw();
g.export('file_name','Active Levers','file_type','png');

g=gramm('x',rnk,'y',MT.InactiveLever,'color',MT.Sex);
%g.stat_smooth('geom','area');
g.stat_summary('geom',{'errorbar','point'},'type','sem','dodge',.5,'setylim',1);
g.axe_property('LineWidth',1.5,'FontSize',12,'Ylim',[0 150]);
g.axe_property('tickdir','out');
g.set_names('x','Training Day','y','Lever Presses','color','Sex');
g.set_text_options('base_size',14,'interpreter','none');
g.set_color_options('map','lch','hue_range',[25 385]+25);
figure('Position',[1 1 400 300]);
g.draw();
g.export('file_name','Inactive Levers','file_type','png');