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
ConnectedComponents=bwconncomp(BW2,26); %returns structure with 4 fields. PixelIdxList contains a 1-by-NumObjects cell array where the k-th element in the cell array is a vector containing the linear indices of the pixels in the k-th object. 26 defines connectivity. This looks at cube of connectivity around pixel.
stats = regionprops3(ConnectedComponents); % Some stats about the cells
numObj = numel(ConnectedComponents.PixelIdxList); %PixelIdxList is field with list of pixels in each connected component. Find how many connected components there are.
   for i = 1:numObj
    ObjectList(i,1) = length(ConnectedComponents.PixelIdxList{1,i}); 
   end
    ObjectList = sortrows(ObjectList,-1);%Sort columns by pixel size.
    
%% Code from 3DMorph to display 3D individual objects
individual=bwconncomp(BW2,26);
<<<<<<< HEAD
s = size(im);
ex=zeros(s(1),s(2),s(3));
numObj=ConnectedComponents.NumObjects;

progbar = waitbar(0,'Processing your data...');
figure('Color','k','Position',[1 1 1024 1024]);
cmap=lines(numObj);
set(gca,'Color',[0 0 0],'DataAspectRatio',[1 1 1]);

for m = 1:numObj
    %Microglia{1,m}=ConnectedComponents.PixelIdxList{1,i}; %Write the object to new cell array, Microglia in location 'col'.
    waitbar (m/numObj, progbar);
    ex=zeros(s(1),s(2),s(3));
    ex(ConnectedComponents.PixelIdxList{1,m})=1;%write in only one object to image. Cells are white on black background
    ds = size(ex);
    camlight %To add lighting/shading
    lighting gouraud; %Set style of lighting. This allows contours, instead of flat lighting
    view(0,270); % Lookf at image from top viewpoint instead of side  
    daspect([1 1 1]); 
    fv=isosurface(ex,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
    patch(fv,'FaceColor',cmap(m,:),'FaceAlpha',1,'EdgeColor','none');%without edgecolour, will auto fill black, and all objects appear black
    axis([0 ds(1) 0 ds(2) 0 ds(3)]);%specify the size of the image
    flatex = sum(ex,3);
    allObjs(:,:,m) = flatex(:,:); 
end

if isgraphics(progbar)
close(progbar);
end

%%

ex(ConnectedComponents.PixelIdxList{1,i})=1;

=======
col=1;
s = size
    for i = 1:numObj
        ex=zeros(s(1),s(2),zs);
        ex(Microglia{1,i})=1;%write in only one object to image. Cells are white on black background.
        flatex = sum(ex,3);
        AllSeparatedObjs(:,:,i) = flatex(:,:); 
    end
>>>>>>> c2b4ab8d123990b2e1babdb5ae14fb663ebc87c3
    title = ['_Selected Cells'];
    figure('Name',title);
    
    for i = 1:numObj
        ex=zeros(40, 40,95);%Create blank image of correct size
        j=ObjectList(i,2);
        ex(Microglia{1,j})=1;%write in only one object to image. Cells are white on black background.
        ds = size(ex);
        fv=isosurface(ex,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
        patch(fv,'FaceColor',cmap(i*3,:),'FaceAlpha',1,'EdgeColor','none');%without edgecolour, will auto fill black, and all objects appear black
        axis([0 ds(1) 0 ds(2) 0 ds(3)]);%specify the size of the image
        camlight %To add lighting/shading
        lighting gouraud; %Set style of lighting. This allows contours, instead of flat lighting
        view(0,270); % Lookf at image from top viewpoint instead of side  
        daspect([1 1 1]);f
        colorbar('Ticks',[0,1], 'TickLabels',{'Small','Large'});
    end 



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
% imshow(big1);

%% Original code

numObj = numel(ConnectedComponents.PixelIdxList); %PixelIdxList is field with list of pixels in each connected component. Find how many connected components there are.
disp(numObj);

% ex contains each cell extracted in 3D. This will need to be used for
% volumetric reconstruction and skeletonization.
for j = 1:95 
    
for i = 1:numObj  
    BW2 = bwareaopen(BW, 10000); % Removes all small objects from image <10000
    ConnectedComponents1 =bwconncomp(BW(:,:,j),26);
    ex=zeros(size(im,1),size(im,2),size(im,3));
    ex(ConnectedComponents1.PixelIdxList{1,i})=1; %write in only one object to image. Cells are white on black background.
    % skeleton = Skeleton3D(ex);
    flatex = sum(ex,3);
    allObjs(:,:,i) = flatex(:,:); 
end
end
DetectedObjs = sum(allObjs,3);
cmapCompress = parula(max(DetectedObjs(:)));  
cmapCompress(1,:) = zeros(1,3);

figure
imshow(DetectedObjs,cmapCompress)

% WHY DOES THIS SHOW SUCH A BEAUTIFUL IMAGE ON THE LEFT???
figure
BW3 = bwmorph(allObjs(:,:,22),'skel',Inf);
imshowpair(allObjs(:,:,33), BW3, 'montage');