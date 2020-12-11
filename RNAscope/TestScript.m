% Import Files
Options.DiskSize = 20;
Options.ShowInitialFigure = true;
Options.ShowFinalFigure = false;
Options.Radius = 20;
Options.RedCellThreshold = 30000;
Options.GreenCellThreshold = 20000;

    

A1 = RNAScopeFiltering("12.1/PDE10a_A1/XY01/A1_XY01_Overlay.tif", Options);
A2 = RNAScopeFiltering("12.1/PDE10a_A1/XY01/A1_XY02_Overlay.tif", Options);
A3 = RNAScopeFiltering("12.1/PDE10a_A1/XY03/A1_XY03_Overlay.tif", Options);
A4 = RNAScopeFiltering("12.1/PDE10a_A1/XY04/A1_XY04_Overlay.tif");
A5 = RNAScopeFiltering("12.1/PDE10a_A1/XY05/A1_XY05_Overlay.tif");
A6 = RNAScopeFiltering("12.1/PDE10a_A1/XY06/A1_XY06_Overlay.tif");

B1 = RNAScopeFiltering("12.1/PDE10a_B1/XY01/B1_XY01_Overlay.tif");
B2 = RNAScopeFiltering("12.1/PDE10a_B1/XY02/B1_XY02_Overlay.tif");
B3 = RNAScopeFiltering("12.1/PDE10a_B1/XY03/B1_XY03_Overlay.tif");
B4 = RNAScopeFiltering("12.1/PDE10a_B1/XY04/B1_XY04_Overlay.tif");
B5 = RNAScopeFiltering("12.1/PDE10a_B1/XY05/B1_XY05_Overlay.tif");
B6 = RNAScopeFiltering("12.1/PDE10a_B1/XY06/B1_XY06_Overlay.tif");

C1 = RNAScopeFiltering("12.1/PDE10a_C1/XY01/C1_XY01_Overlay.tif");
C2 = RNAScopeFiltering("12.1/PDE10a_C1/XY02/C1_XY02_Overlay.tif");
C3 = RNAScopeFiltering("12.1/PDE10a_C1/XY03/C1_XY03_Overlay.tif");
C4 = RNAScopeFiltering("12.1/PDE10a_C1/XY04/C1_XY04_Overlay.tif");
C5 = RNAScopeFiltering("12.1/PDE10a_C1/XY05/C1_XY05_Overlay.tif");
C6 = RNAScopeFiltering("12.1/PDE10a_C1/XY06/C1_XY06_Overlay.tif");

Datasheet = ['Name', 'Percent Merged Cells', "Red Cell Counts", "Green Cell Counts";A1;A2;A3;A4;A5;A6;B1;B2;B3;B4;B5;B6;C1;C2;C3;C4;C5;C6];

Datasheet = ['Percent Merged Cells', "Red Cell Counts", "Green Cell Counts"; RNAScopeFiltering("12.1/PDE10a_A1/XY01/A1_XY01_Overlay.tif"); RNAScopeFiltering("12.1/PDE10a_A1/XY02/A1_XY02_Overlay.tif")];


