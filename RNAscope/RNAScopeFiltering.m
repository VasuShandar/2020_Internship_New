%% RNA Scope Image analysis for Low Abundance Genes
function RNAScopeFiltering = RNAScopeFiltering(fname)

%% Read Image
im = (imread(fname));
[~,imName] = fileparts(fname);

%% Original Unedited Figure
figure('Color','k')
f = imshow(im);

%% Extract Blue Channel for Dapi Segmentation
imgblue = im(:,:,3); % blue, nuclei only signal
f = imshow(imgblue);

% Subtract the uneven background from the image
se = strel('disk',60);
imgblue = imtophat(imgblue,se);
f = imshow(imgblue);
centers = imfindcircles(imgblue,[10 40]);

% Binarize Image
bw_blue = imbinarize(imgblue);
f = imshow(bw_blue);

% Find Connected Aread of White
bw_blue = bwareaopen(bw_blue, 50);
f = imshow(bw_blue);

% % Remove Clumping
bw_blue = bwareafilt(bw_blue,[50 1500]);
f = imshow(bw_blue);

% Look for connected components
cc_blue = bwconncomp(bw_blue, 8);

% Create Dapi Centroids
radius = 20;
s = regionprops(cc_blue,'centroid');
centroids = cat(1, s.Centroid);

% Remove centroids touching the border (hard to look inside the partial circles)
NotAtBorder = centroids(:,1) < size(imgblue,2) - (radius + 1) &...
centroids(:,1) > radius + 1 &...
centroids(:,2) < size(imgblue,1) - (radius + 1) &...
centroids(:,2) > radius + 1;
centroids = centroids(NotAtBorder,:);  
cell_radious(1:length(centroids),1)=20;
cell_radious(1:length(centers),1)=20;
% repmat

%Show Cell Identification
f = imshow(imgblue)
hold on
viscircles(centroids,cell_radious,'LineStyle','-','LineWidth',.1,'Color','cyan');
viscircles(centers,cell_radious,'LineStyle','-','LineWidth',.1,'Color','cyan');

%% Extract Red Channel for Signal Segmentation
imgred = im(:,:,1);

%% Extract Green Channel for Signal Segmentation
imggreen = im(:,:,2);

%% Extract Far Red Channel for Signal Segmentation
% imgFarRed = imread("Z:\Neumaier Lab\Jordan\MAX_Stack RD.tif");



%% Green & Red per Cell (clever trick to use the strel function to
% approximate a circle)
SE = strel('disk',radius,0);
figure;
f=imshow(SE.Neighborhood);

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
figure;
histfit(red_size);

figure;
histfit(green_Size);

RedCellThresh = 60000;
GreenCellThresh = 50000;

% Insert Circles
 I=insertShape(im,'circle',[centroids(red_size>RedCellThresh,:) cell_radious(red_size>RedCellThresh)],'Color','red','LineWidth',2);
 I=insertShape(I,'circle',[centroids(green_Size>GreenCellThresh,:) cell_radious(green_Size>GreenCellThresh)],'Color','green','LineWidth',2);
 I=insertShape(I,'circle',[centroids(red_size>RedCellThresh & green_Size>GreenCellThresh,:) cell_radious(red_size>RedCellThresh & green_Size>GreenCellThresh)],'Color','yellow','LineWidth',2);
figure;
f=imshow(I);

% Final Numbers
MergeCells=sum(red_size>RedCellThresh & green_Size>GreenCellThresh);
greenCells=sum(green_Size>GreenCellThresh & red_size<RedCellThresh);
redCells=sum(red_size>RedCellThresh & green_Size<GreenCellThresh);
PercentMergeCells(i,1)=MergeCells/(MergeCells+redCells);
greenperredCell(i,1)=mean(green_Size(red_size>RedCellThresh));
greenperOtherCell(i,1)=mean(green_Size(red_size<RedCellThresh));
redCellCounts(i,1)=(MergeCells+redCells);
greenCellCounts(i,1)=greenCells;



end 