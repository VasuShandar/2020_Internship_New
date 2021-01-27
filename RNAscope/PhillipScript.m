%% Code to Import Phillip RNAScope Images and Produce Analysis from RNAScope Filtering

Options.DiskSize = 20;
Options.ShowAnalysisFigures = 0;
Options.ShowFinalFigure = 0;
Options.Radius = 20;
Options.RedCellThreshold = 2000;
Options.GreenCellThreshold = 1200;
Options.FarRedCellThreshold = 500;
Options.AreaFilter = [150 1200];


d=dir('.\1.19');
d=d(3:end);
f=('.\Phillip Analysed Images');

for i=1:size(d)
    if i == 1
        M = PhillipRNAScopeFiltering(fullfile(d(i).folder,d(i).name), Options);
    end 
    disp(['Analysing ' d(i).name]);
    T = PhillipRNAScopeFiltering(fullfile(d(i).folder,d(i).name), Options);
    M = [M; T];

end
writetable(M, 'ImageStatistics.csv');

tiff_info = imfinfo('ms1_1b_s3_L.tif'); % return tiff structure, one element per image
fname="C:\Users\vasus\OneDrive\Documents\GitHub\2020_Internship_New\RNAscope\1.19\ms1_1b_s3_L.tif";

X = PhillipRNAScopeFiltering(fname, Options);
