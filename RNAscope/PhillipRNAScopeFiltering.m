%% RNA Scope Image Analysis - Written by Vasu Shandar & Kevin Coffey 2020
% Filters image by adjustable standards to output overlap between cell
% types and gene compounds 
% FilteredRNA = RNAScopeFiltering(image) Returns table of calculations
% about the imput image using default values for adjustable variables
% FilteredRNA = RNAScopeFiltering(image, Options) Returns table of
% calcualtions but allows user to adjust specific variables 
% Options = ['DiskSize', 'ShowAnalysisFigures', 'ShowFinalFigure',
% 'Radius', 'RedCellThreshold', 'GreenCellThreshold', 'AreaFilter']


function RNAScopeFiltering = RNAScopeFiltering(fname, Options)

if ~isfield(Options, 'DiskSize')
    Options.DiskSize = 40;
end 

if ~isfield(Options, 'ShowAnalysisFigures') 
    Options.ShowAnalysisFigures = true;
end

if ~isfield(Options, 'ShowFinalFigure')
   Options.ShowFinalFigure = true;
end

if ~isfield(Options, 'Radius')
   Options.Radius = 20;
end

if ~isfield(Options, 'RedCellThreshold') 
   Options.RedCellThreshold = 40000;
end

if ~isfield(Options, 'GreenCellThreshold')
   Options.GreenCellThreshold = 40000;
end

if ~isfield(Options, 'AreaFilter')
   Options.AreaFilter =[150 1500];
end 
    
im = (fname);
% [~,imName] = fileparts(fname);
%% Original Unedited Figure
if Options.ShowAnalysisFigures == 1
    figure('Color','k')
    f = imshow(im);
end 

%% Extract Blue Channel for Dapi Segmentation
imgblue = im(:,:,3); % blue, nuclei only signal

% Subtract the uneven background from the image
se = strel('disk',Options.DiskSize);
imgblue = imtophat(imgblue,se);

% Binarize Image
bw_blue = imbinarize(imgblue);
% f = imshow(bw_blue);

% % Remove Clumping
bw_blue = bwareafilt(bw_blue,Options.AreaFilter);
%f = imshow(bw_blue);

% Look for connected components
cc_blue = bwconncomp(bw_blue, 8);

% Create Dapi Centroids
radius = Options.Radius;
s = regionprops(cc_blue,'centroid');
centroids = cat(1, s.Centroid);

% Remove centroids touching the border (hard to look inside the partial circles)
NotAtBorder = centroids(:,1) < size(imgblue,2) - (radius + 1) &...
centroids(:,1) > radius + 1 &...
centroids(:,2) < size(imgblue,1) - (radius + 1) &...
centroids(:,2) > radius + 1;
centroids = centroids(NotAtBorder,:);  
cell_radious(1:length(centroids),1)=20;

%Show Cell Identification
if Options.ShowAnalysisFigures == 1
    figure;
    f = imshow(imgblue)
    hold on
    viscircles(centroids,cell_radious,'LineStyle','-','LineWidth',.1,'Color','cyan');
end 

%% Extract Red Channel for Signal Segmentation
imgred = im(:,:,3);

%% Extract Green Channel for Signal Segmentation
imggreen = im(:,:,2);

%% Extract Far Red Channel for Signal Segmentation
 imgFarRed = im(:,:,4);

%% Green & Red per Cell (clever trick to use the strel function to
% approximate a circle)
SE = strel('disk',radius,0);

%% create indicies of the circle in reference to the centroid
circle = find(SE.Neighborhood);
[I,J] = ind2sub(size(SE.Neighborhood),circle);
I = I - radius - 1;
J = J - radius - 1;
dist = sqrt(J.^2 + I.^2);
[dist,distIdx] = sort(dist,'ascend');
I = I(distIdx);
J = J(distIdx);

%% Prealocate Arrays for Signal Quantification 
red_Size = zeros(length(centroids),1);
green_Size = zeros(length(centroids),1);
red = zeros(length(centroids),length(I),'uint8');
green = zeros(length(centroids),length(I),'uint8');
blue = zeros(length(centroids),length(I),'uint8');
farred = zeros(length(centroids),length(I),'uint8');

%% Create index of each cell within the full image
for j=1:length(centroids)
% Index of cell    
cellIndex = sub2ind(size(imgblue),round(centroids(j,2)) + I,round(centroids(j,1)) + J);

% Total RNA Scope Signal/ Cell
red(j,:) = imgred(cellIndex);
green(j,:)= imggreen(cellIndex);
blue(j,:)= imgblue(cellIndex);
farred(j,:)= imgfarred(cellIndex);

[sorted_r, ~] = sort(red(j,:),'descend');
red_Size(j) = sum(sorted_r(1:floor(length(sorted_r)/20)));

[sorted_g, ~] = sort(green(j,:),'descend');
green_Size(j) = sum(sorted_g(1:floor(length(sorted_g)/20)));

[sorted_b, ~] = sort(blue(j,:),'descend');
blue_Size(j) = sum(sorted_b(1:floor(length(sorted_b)/20)));

[sorted_fr, ~] = sort(farred(j,:),'descend');
farred_Size(j) = sum(sorted_fr(1:floor(length(sorted_fr)/20)));

%red_Size(j) = sum(imgred(cellIndex));
%green_Size(j)=sum(imggreen(cellIndex));
end

% Threshold Cells
if Options.ShowAnalysisFigures == 1
figure;
histfit(red_Size);
    title('Max Red');
end

if Options.ShowAnalysisFigures == 1
figure;
histfit(green_Size);
    title('Max Green');
end

RedCellThresh = Options.RedCellThreshold;
GreenCellThresh = Options.GreenCellThreshold;
BlueCellThresh = Options.BlueCellThreshold;
FarredCellThresh = Options.FarredCellThreshold;


% Insert Circles
 I=insertShape(im,'circle',[centroids(red_Size>RedCellThresh,:) cell_radious(red_Size>RedCellThresh)],'Color','red','LineWidth',2);
 I=insertShape(I,'circle',[centroids(green_Size>GreenCellThresh,:) cell_radious(green_Size>GreenCellThresh)],'Color','green','LineWidth',2);
 I=insertShape(im,'circle',[centroids(blue_Size>RedCellThresh,:) cell_radious(blue_Size>BlueCellThresh)],'Color','blue','LineWidth',2);
 I=insertShape(im,'circle',[centroids(farred_Size>FarredCellThresh,:) cell_radious(Farred_Size>FarredCellThresh)],'Color','yellow','LineWidth',2);

 I=insertShape(I,'circle',[centroids(blue_Size>BlueCellThresh & red_Size>GreenCellThresh,:) cell_radious(red_Size>RedCellThresh & blue_Size>BlueCellThresh)],'Color','yellow','LineWidth',2);
 I=insertShape(I,'circle',[centroids(blue_Size>BlueCellThresh & green_Size>GreenCellThresh,:) cell_radious(blue_Size>BlueCellThresh & green_Size>GreenCellThresh)],'Color','purple','LineWidth',2);
 
if Options.ShowFinalFigure == 1
    figure;
    f=imshow(I);
end 

% Final Numbers
AllMergeCells=sum(red_Size>RedCellThresh & blue_Size>BlueCellThresh & green_Size>GreenCellThresh & farred_Size>FarredCellThresh);
RedGreenBlueMergeCells=sum(red_Size>RedCellThresh & blue_Size>BlueCellThresh & green_Size>GreenCellThresh);
RedFarredBlueMergeCells=sum(red_Size>RedCellThresh & blue_Size>BlueCellThresh & farred_Size>FarredCellThresh);
GreenFarredBlueMergeCells=sum(blue_Size>BlueCellThresh & green_Size>GreenCellThresh & farred_Size>FarredCellThresh);

greenCells=sum(green_Size>GreenCellThresh & blue_Size<BlueCellThresh);
redCells=sum(red_Size>RedCellThresh & blue_Size<BlueCellThresh);
farredCells=sum(farred_Size>FarredCellThresh & blue_Size<BlueCellThresh);

% PercentMergeCells=MergeCells/(MergeCells+redCells);
greenperblueCell=mean(green_Size(blue_Size>BlueCellThresh));
redperblueCell=mean(red_Size(blue_Size>BlueCellThresh));
farredperblueCell=mean(farred_Size(blue_Size>BlueCellThresh));

%redCellCounts=(MergeCells+redCells);
%greenCellCounts=greenCells;

% Extract ID from the filename somehow. This will be unique to experiments.
%[str tok]=strtok(fname,'_');
%ID=categorical({tok(2:5)});
% need MergeCells between: (green, red, blue), (green, farred, blue), (red,
% farred, blue)

RNAScopeFiltering = table(AllMergeCells, RedGreenBlueMergeCells, RedFarredBlueMergeCells, GreenFarredBlueMergeCells, greenperblueCell, redperblueCell, farredperblueCell);
end 