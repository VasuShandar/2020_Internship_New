%% RNA Scope Image analysis for Low Abundance Genes
function RNAScopeFiltering = RNAScopeFiltering(fname, Options)
if nargin<2;     
    Options=struct([]); 
end

if isfield(Options, 'DiskSize')
       Options.DiskSize = Options.DiskSize;
else 
    Options.DiskSize = 40;
end 
if isfield(Options, 'ShowInitialFigure')
        Options.ShowInitialFigure = Options.ShowInitialFigure;
else 
    Options.ShowInitialFigure = true;

end 
if isfield(Options, 'ShowFinalFigure')
    Options.ShowFinalFigure = Options.ShowFinalFigure;
else 
    Options.ShowFinalFigure = true;
end   
if isfield(Options, 'Radius')
    Options.Radius = Options.Radius;
else 
    Options.Radius = 20;
end
if isfield(Options, 'RedCellThreshold')
    Options.RedCellThreshold = Options.RedCellThreshold;
else 
    Options.RedCellThreshold = 40000;
end 
if isfield(Options, 'GreenCellThreshold')
    Options.GreenCellThreshold = Options.GreenCellThreshold;
else 
    Options.GreenCellThreshold = 40000;
end 
if isfield(Options, 'ObjectNumber')
       Options.ObjectNumber = Options.ObjectNumber;
else
    Options.ObjectNumber = 0;
end 
    
im = (imread(fname));
[~,imName] = fileparts(fname);
%% Original Unedited Figure
if Options.ShowInitialFigure == 1
    figure('Color','k')
    f = imshow(im);
end 



%% Thresholding by brightness
%maxblue = max(max(im(:,:,1)));
%deep_blue = im(:,:,1) .* (im(:,:,1) >= 0.95 * maxblue);
%max_blue(1,1,3) = 0;

%% Extract Blue Channel for Dapi Segmentation
imgblue = im(:,:,3); % blue, nuclei only signal

%show(max_blue);
% f = imshow(imgblue);

% Subtract the uneven background from the image

se = strel('disk',Options.DiskSize);
imgblue = imtophat(imgblue,se);
%figure;
%f = imshow(imgblue);
J = imadjust(imgblue,stretchlim(imgblue),[0 1]);
%Kaverage = filter2(fspecial('average',3),J)/255;
%Kmedian = medfilt2(J);
%figure;
%imshowpair(Kaverage,Kmedian,'montage')


% Binarize Image
bw_blue = imbinarize(imgblue);
% f = imshow(bw_blue);

% Find Connected Aread of White
bw_blue = bwareaopen(bw_blue, 50);
% f = imshow(bw_blue);

% % Remove Clumping and try reducing fuzzy objects by only selecting
% largest
if Options.ObjectNumber > 0
bw_blue = bwareafilt(bw_blue,Options.ObjectNumber); 
else 
bw_blue = bwareafilt(bw_blue,[150 1500]);
end 
figure;
f = imshow(bw_blue);

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
% cell_radious(1:length(centers),1)=20;
% repmat

%Show Cell Identification
% f = imshow(imgblue)
% hold on
% viscircles(centroids,cell_radious,'LineStyle','-','LineWidth',.1,'Color','cyan');
%viscircles(centers,cell_radious,'LineStyle','-','LineWidth',.1,'Color','cyan');

%% Extract Red Channel for Signal Segmentation
imgred = im(:,:,1);

%% Extract Green Channel for Signal Segmentation
imggreen = im(:,:,2);

%% Extract Far Red Channel for Signal Segmentation
% imgFarRed = imread("Z:\Neumaier Lab\Jordan\MAX_Stack RD.tif");



%% Green & Red per Cell (clever trick to use the strel function to
% approximate a circle)
SE = strel('disk',radius,0);
% figure;
% f=imshow(SE.Neighborhood);

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
red_size = zeros(length(centroids),1);
green_Size = zeros(length(centroids),1);
red = zeros(length(centroids),length(I),'uint8');
green = zeros(length(centroids),length(I),'uint8');

%% Create index of each cell within the full image
for j=1:length(centroids)
% Index of cell    
cellIndex = sub2ind(size(imgblue),round(centroids(j,2)) + I,round(centroids(j,1)) + J);

% Total RNA Scope Signal/ Cell
red(j,:) = imgred(cellIndex);
green(j,:)= imggreen(cellIndex);
red_size(j) = sum(imgred(cellIndex));
green_Size(j)=sum(imggreen(cellIndex));
end

% Threshold Cells
% figure;
% histfit(red_size);

% figure;
% histfit(green_Size);

RedCellThresh = Options.RedCellThreshold;
GreenCellThresh = Options.GreenCellThreshold;

% Insert Circles
 I=insertShape(im,'circle',[centroids(red_size>RedCellThresh,:) cell_radious(red_size>RedCellThresh)],'Color','red','LineWidth',2);
 I=insertShape(I,'circle',[centroids(green_Size>GreenCellThresh,:) cell_radious(green_Size>GreenCellThresh)],'Color','green','LineWidth',2);
 I=insertShape(I,'circle',[centroids(red_size>RedCellThresh & green_Size>GreenCellThresh,:) cell_radious(red_size>RedCellThresh & green_Size>GreenCellThresh)],'Color','yellow','LineWidth',2);
 
 if Options.ShowFinalFigure == 1
    figure;
    f=imshow(I);
end 

% Final Numbers
MergeCells=sum(red_size>RedCellThresh & green_Size>GreenCellThresh);
greenCells=sum(green_Size>GreenCellThresh & red_size<RedCellThresh);
redCells=sum(red_size>RedCellThresh & green_Size<GreenCellThresh);
PercentMergeCells=MergeCells/(MergeCells+redCells);
greenperredCell=mean(green_Size(red_size>RedCellThresh));
greenperOtherCell=mean(green_Size(red_size<RedCellThresh));
redCellCounts=(MergeCells+redCells);
greenCellCounts=greenCells;

RNAScopeFiltering = {fname, PercentMergeCells, redCellCounts,greenCellCounts};


end 