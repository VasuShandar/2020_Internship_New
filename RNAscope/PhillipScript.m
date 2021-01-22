%% Code to Import Phillip RNAScope Images and Produce Analysis from RNAScope Filtering

Options.DiskSize = 20;
Options.ShowAnalysisFigures = 1;
Options.ShowFinalFigure = 1;
Options.Radius = 20;
Options.RedCellThreshold = 10000;
Options.GreenCellThreshold = 4500;
Options.AreaFilter = [100 800];

tiff_info = imfinfo('ms1_1b_s3_L.tif'); % return tiff structure, one element per image
[imB, cmap] = imread('ms1_1b_s3_L.tif', 1) ; % read in first image
[imG, cmap] = imread('ms1_1b_s3_L.tif', 2) ; % read in first image
[imR, cmap] = imread('ms1_1b_s3_L.tif', 3) ; % read in first image
[imFR, cmap] = imread('ms1_1b_s3_L.tif', 4) ; % read in first image

B = ind2rgb(imB,cmap);
G = ind2rgb(imG,cmap);
R = ind2rgb(imR,cmap);
FR = ind2rgb(imFR,cmap);

rgbImage = cat(3, B(:,:,3), G(:,:,3), R(:,:,3), FR(:,:,3));

% imshow(rgbImage(:,:,3));

X = RNAScopeFiltering(rgbImage, Options);
