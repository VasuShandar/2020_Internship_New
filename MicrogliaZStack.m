tiff_info = imfinfo('C2-772_str.tif'); % return tiff structure, one element per image
im = imread('C2-772_str.tif', 1) ; % read in first image
%concatenate each successive tiff to tiff_stack
for ii = 2 : size(tiff_info, 1)
    temp_tiff = imread('C2-772_str.tif', ii);
    im = cat(3 , im, temp_tiff);
end

% Improves Fiber Detection
for i = 1 : size(im,3);
B(:,:,i) = fibermetric(im(:,:,i),4,'ObjectPolarity','bright','StructureSensitivity',6);
%imshowpair(im(:,:,i),B(:,:,i), 'montage');
end
% figure
% imshowpair(max(im, [],3), max(B,[],3), 'montage');

BW = imbinarize(B); % Not sure how to binarize...


% Need to filter small objects
BW2 = bwareaopen(BW, 10000); % Removes all small objects from image <10000
ConnectedComponents=bwconncomp(BW2); % Find the cells, not sure how to optimize
stats = regionprops3(ConnectedComponents); % Some stats about the cells
numObj = numel(ConnectedComponents.PixelIdxList); %PixelIdxList is field with list of pixels in each connected component. Find how many connected components there are.


%% Calculating Centroids
for i=1:length(numObj)
[Stack(:,:,i),map]=imread('C2-772_str.tif',i);
BWW =bwlabeln(B); 
s=regionprops(BWW,'Centroid');
end

% bw1 = bwareafilt(BWW, 1, 'largest');



%% Using ismember
% Measure all the volumes.
measurements = regionprops(BWW, 'Area');
% Get all areas
allAreas = [measurements.Area];
% Sort them in descending order
[sortedVolumes, sortIndices] = sort(allAreas, 'Descend');
% Now relabel the labeled image with intlut
labeledImage = bwlabeln(BWW);
% Now get largest blobs
big1 = ismember(labeledImage, 1);
big2 = ismember(labeledImage, 2);
big3 = ismember(labeledImage, 3);
big4 = ismember(labeledImage, 4);
figure
imshow(big1);

%% Original code

numObj = numel(ConnectedComponents.PixelIdxList); %PixelIdxList is field with list of pixels in each connected component. Find how many connected components there are.
disp(numObj);

% ex contains each cell extracted in 3D. This will need to be used for
% volumetric reconstruction and skeletonization.
for i = 1:numObj
    ex=zeros(size(im,1),size(im,2),size(im,3));
    ex(ConnectedComponents.PixelIdxList{1,i})=1; %write in only one object to image. Cells are white on black background.
    skeleton = Skeleton3D(ex);
    flatex = sum(ex,3);
    allObjs(:,:,i) = flatex(:,:); 
end
imshow(allObjs);
DetectedObjs = sum(allObjs,3);
cmapCompress = parula(max(DetectedObjs(:)));  
cmapCompress(1,:) = zeros(1,3);

figure
imshow(DetectedObjs,cmapCompress)

% WHY DOES THIS SHOW SUCH A BEAUTIFUL IMAGE ON THE LEFT???
figure
BW3 = bwmorph(allObjs(:,:,8),'skel',Inf);
imshowpair(allObjs(:,:,8), BW3, 'montage');