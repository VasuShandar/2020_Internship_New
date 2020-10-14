%%Built graph using cereal data graphing fat vs protein and sorting by
%%brand 
load cereal.mat;
g=gramm('x', Fat, 'y', Protein, 'color', Name);
g.geom_point();
g.stat_glm();
g.set_names('x', 'Fat', 'y', 'Protein', 'color', 'Brand');
g.set_title('Cereal Healthiness');
figure('Position', [100, 100, 800, 400]);
g.draw();
%% Graph using flu data  
load flu.mat;
g(1,1)=gramm('x', flu.Date, 'y', flu.NE);
g(1,1).geom_point();
g(1,1).stat_glm();
g(1,1).set_names('x', 'flu.Date', 'y', 'Percentage')
g(1,1).set_title('NE flu')

g(1,2)=gramm('x', flu.Date, 'y', flu.MidAtl);
g(1,2).geom_point();
g(1,2).stat_glm();
g(1,2).set_names('x', 'flu.Date', 'y', 'Percentage')
g(1,2).set_title('MidAtlantic flu')

g(1,3)=gramm('x', flu.Date, 'y', flu.ENCentral);
g(1,3).geom_point();
g(1,3).stat_glm();
g(1,3).set_names('x', 'flu.Date', 'y', 'Percentage')
g(1,3).set_title('ENCentral flu')

g(2,1)=gramm('x', flu.Date, 'y', flu.WNCentral);
g(2,1).geom_point();
g(2,1).stat_glm();
g(2,1).set_names('x', 'flu.Date', 'y', 'Percentage')
g(2,1).set_title('WNCentral flu')

g(2,2)=gramm('x', flu.Date, 'y', flu.SAtl);
g(2,2).geom_point();
g(2,2).stat_glm();
g(2,2).set_names('x', 'flu.Date', 'y', 'Percentage')
g(2,2).set_title('SAtl flu')

g(2,3)=gramm('x', flu.Date, 'y', flu.ESCentral);
g(2,3).geom_point();
g(2,3).stat_glm();
g(2,3).set_names('x', 'flu.Date', 'y', 'Percentage')
g(2,3).set_title('ESCentral flu')

g(3,1)=gramm('x', flu.Date, 'y', flu.WSCentral);
g(3,1).geom_point();
g(3,1).stat_glm();
g(3,1).set_names('x', 'flu.Date', 'y', 'Percentage')
g(3,1).set_title('WSCentral flu')

g(3,2)=gramm('x', flu.Date, 'y', flu.Mtn);
g(3,2).geom_point();
g(3,2).stat_glm();
g(3,2).set_names('x', 'flu.Date', 'y', 'Percentage')
g(3,2).set_title('Mtn flu')

g(3,3)=gramm('x', flu.Date, 'y', flu.Pac);
g(3,3).geom_point();
g(3,3).stat_glm();
g(3,3).set_names('x', 'flu.Date', 'y', 'Percentage')
g(3,3).set_title('Pac flu')

figure('Position', [100, 100, 800, 800]);
g.draw();

%% Better way to organize Flu Sheet using the Stack function
clear all
load flu.mat;
flu.Date=datetime(flu.Date); % Convert text to Date-Time for easy use
[fluS] = stack(flu,{'NE','MidAtl','ENCentral','WNCentral','SAtl','ESCentral','WSCentral','Mtn','Pac','WtdILI'},...
                     'newdatavarnames','FluRate',...
                     'indvarname','Region');
                 

% Graph all regions together using a smoothing fit. The pattern is not
% linear, so g.stat_glm is not a good fit.
g=gramm('x', fluS.Date.Month, 'y', fluS.FluRate, 'color',fluS.Region);
g.stat_smooth();
g.set_names('x','Month','y','Flu Rate');
figure('Position', [100, 100, 800, 800]);
g.draw();

% Graph using the month name for the x tick axes
g=gramm('x', month(fluS.Date,'name'), 'y', fluS.FluRate, 'color',fluS.Region);
g.stat_smooth();
g.set_names('x','Month','y','Flu Rate');
g.set_order_options('x',{'January','February','March','April','May','June',...
    'July','August','September','October','November','December'});
figure('Position', [100, 100, 800, 800]);
g.draw();

%Oh No! The month labels are overlapping and can't be read... lets tilt
%them and re-draw
g.facet_axes_handles.XTickLabelRotation=45;
g.redraw();

% Lets graph each region in a seperate figure like you did
g=gramm('x', fluS.Date.Month, 'y', fluS.FluRate);
g.geom_point();
g.stat_smooth();
g.facet_wrap(fluS.Region,'ncols',4);
figure('Position', [100, 100, 800, 800]);
g.set_names('x','Month','y','Flu Rate');
g.draw();


                 