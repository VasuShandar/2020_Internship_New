%% Code to Import Phillip RNAScope Images and Produce Analysis from RNAScope Filtering

Options.DiskSize = 20;
Options.ShowAnalysisFigures = 1;
Options.ShowFinalFigure = 1;
Options.Radius = 20;
Options.RedCellThreshold = 2000;
Options.GreenCellThreshold = 200;
Options.FarRedCellThreshold = 1000;
Options.AreaFilter = [150 1200];

tiff_info = imfinfo('ms1_1b_s3_L.tif'); % return tiff structure, one element per image
fname="C:\Users\DrCoffey\Documents\GitHub\2020_Internship_New\RNAscope\1.19\ms1_1b_s3_L.tif";

X = PhillipRNAScopeFiltering(fname, Options);
