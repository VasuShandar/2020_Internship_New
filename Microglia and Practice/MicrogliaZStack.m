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
s = size(im);
ex=zeros(s(1),s(2),s(3));
numObj=ConnectedComponents.NumObjects;
figure('Color','k','Position',[1 1 1024 1024]);
cmap=lines(numObj);
set(gca,'Color',[0 0 0],'DataAspectRatio',[1 1 1]);

for m = 1:numObj;
    ex=zeros(s(1),s(2),s(3));
    ex(ConnectedComponents.PixelIdxList{1,m})=1;%write in only one object to image. Cells are white on black background
    ds = size(ex);
    ex = Skeleton3D(ex);
    camlight %To add lighting/shading
    lighting gouraud; %Set style of lighting. This allows contours, instead of flat lighting
    view(0,270); % Lookf at image from top viewpoint instead of side  
    daspect([1 1 1]); 
    fv=isosurface(ex,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
    patch(fv,'FaceColor',cmap(m,:),'FaceAlpha',1,'EdgeColor','none');%without edgecolour, will auto fill black, and all objects appear black
    axis([0 ds(1) 0 ds(2) 0 ds(3)]);%specify the size of the image
    flatex = sum(ex,3);
    allObjs(:,:,m) = flatex(:,:); 
    disp(m);
end

%%
% Skeletonizing Code
% Find endpoints, and trace branches from endpoints to centroid   
DownSampled = 0;
    ex=zeros(s(1),s(2),s(3));
    ex(ConnectedComponents.PixelIdxList{1,m})=1;%write in only one object to image. Cells are white on black background
    skeleton = Skeleton3D(ex);
    FullMg = skeleton;
% cleaned up branch point and coloring code from 3DMorph 
numendpts = zeros(numel(FullMg),1);
numbranchpts = zeros(numel(FullMg),1);
MaxBranchLength = zeros(numel(FullMg),1);
MinBranchLength = zeros(numel(FullMg),1);
AvgBranchLength = zeros(numel(FullMg),1);
cent = (zeros(numObj,3));

BranchLengthList=cell(1,numel(FullMg));
    scale = 0.46125;   
    adjust_scale = scale;

    i2 = floor(cent(i,:)); %From the calculated centroid, find the nearest positive pixel on the skeleton, so we know we're starting from a pixel with value 1.
    closestPt = NearestPixel(ex,i2,scale);
    [BoundedSkel, right, left, top, bottom]  = BoundingBoxOfCell(WholeSkel); %Create a bounding box around the skeleton and only analyze this area to significantly increase processing speed. 
      si = size(BoundedSkel);
    i2 = closestPt; %Coordinates of centroid (endpoint of line).
    i2(:,1)=(i2(:,1))-left+1;
    i2(:,2) = (i2(:,2))-bottom+1;

    endpts = (convn(BoundedSkel,kernel,'same')==1)& BoundedSkel; %convolution, overlaying the kernel cube to see the sum of connected pixels.      
    EndptList = find(endpts==1);
    [r,c,p]=ind2sub(si,EndptList);%Output of ind2sub is row column plane
    EndptList = [r c p];
    numendpts(i,:) = length(EndptList);

    masklist =zeros(si(1),si(2),si(3),length(EndptList));
    ArclenOfEachBranch = zeros(length(EndptList),1);
    for j=1:length(EndptList)%Loop through coordinates of endpoint.
        i1 = EndptList(j,:); 
        mask = ConnectPointsAlongPath(BoundedSkel,i1,i2);
        masklist(:,:,:,j)=mask;
        % Find the mask length in microns
        pxlist = find(masklist(:,:,:,j)==1);%Find pixels that are 1s (branch)
        distpoint = reorderpixellist(pxlist,si,i1,i2); %Reorder pixel lists so they're ordered by connectivity
        %Convert the pixel coordinates by the scale to calculate arc length in microns.
        distpoint(:,1) = distpoint(:,1)*adjust_scale; %If 1024 and downsampled, these scales have been adjusted
        distpoint(:,2) = distpoint(:,2)*adjust_scale; %If 1024 and downsampled, these scales have been adjusted
        distpoint(:,3) = distpoint(:,3)*zscale;
        [arclen,seglen] = arclength(distpoint(:,1),distpoint(:,2),distpoint(:,3));%Use arc length function to calculate length of branch from coordinates
        ArclenOfEachBranch(j,1)=arclen; %Write the length in microns to a matrix where each row is the length of each branch, and each column is a different cell.
    end
  
    %Find average min, max, and avg branch lengths
    MaxBranchLength(i,1) = max(ArclenOfEachBranch);
    MinBranchLength(i,1) = min(ArclenOfEachBranch);
    AvgBranchLength(i,1) = mean(ArclenOfEachBranch);  
    
    %Save branch lengths list
    BranchLengthList{1,i} = ArclenOfEachBranch;
       
    
    fullmask = sum(masklist,4);%Add all masks to eachother, so have one image of all branches.
    fullmask(fullmask(:,:,:)>3)=4;%So next for loop can work, replace all values higher than 3 with 4. Would need to change if want more than quaternary connectivity.

    % Define branch level and display all on one colour-coded image.
    pri = (fullmask(:,:,:))==4;
    sec = (fullmask(:,:,:))==3;
    tert = (fullmask(:,:,:))==2;
    quat = (fullmask(:,:,:))==1;
    
    title = [file,'_Cell',num2str(i)];
    figure('Name',title); %Plot all branches as primary (red), secondary (yellow), tertiary (green), or quaternary (blue). 
    hold on
    fv1=isosurface(pri,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
    patch(fv1,'FaceColor',[1 0 0],'FaceAlpha',0.5,'EdgeColor','none');%without edgecolour, will auto fill black, and all objects appear black
    camlight %To add lighting/shading
    lighting gouraud; %Set style of lighting. This allows contours, instead of flat lighting
    fv1=isosurface(sec,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
    patch(fv1,'FaceColor',[1 1 0],'FaceAlpha',0.5,'EdgeColor','none');%without edgecolour, will auto fill black, and all objects appear black
    camlight %To add lighting/shading
    lighting gouraud; %Set style of lighting. This allows contours, instead of flat lighting
    fv1=isosurface(tert,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
    patch(fv1,'FaceColor',[0 1 0],'FaceAlpha',0.5,'EdgeColor','none');%without edgecolour, will auto fill black, and all objects appear black
    camlight %To add lighting/shading
    lighting gouraud; %Set style of lighting. This allows contours, instead of flat lighting
    fv1=isosurface(quat,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
    patch(fv1,'FaceColor',[0 0 1],'FaceAlpha',0.5,'EdgeColor','none');%without edgecolour, will auto fill black, and all objects appear black
    camlight %To add lighting/shading
    lighting gouraud; %Set style of lighting. This allows contours, instead of flat lighting
    view(0,270); % Look at image from top viewpoint instead of side
    daspect([1 1 1]);

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