tiff_info = imfinfo('Microglia IHC FISH.lif - sl1_im1-1.tif'); % return tiff structure, one element per image
im = imread('Microglia IHC FISH.lif - sl1_im1-1.tif', 1) ; % read in first image
%concatenate each successive tiff to tiff_stack
for ii = 2 : size(tiff_info, 1)
    temp_tiff = imread('Microglia IHC FISH.lif - sl1_im1-1.tif', ii);
    im = cat(3 , im, temp_tiff);
end

for i =1 : (size(im,3))/3;
    G(:,:,i) = im(:,:,((i*3)-1));
    %imshow(G(:,:,i));
end 

for i =1 : (size(im,3))/3;
    R(:,:,i) = im(:,:,((i*3)-2));
    %imshow(R(:,:,i));
end 

for i =1 : (size(im,3))/3;
    B(:,:,i) = im(:,:,((i*3)));
    %imshow(R(:,:,i));
end 


% Improves Fiber Detection
for i = 1 : size(G,3);
bwG(:,:,i) = fibermetric(G(:,:,i),8,'ObjectPolarity','bright','StructureSensitivity',8);
%imshowpair(G(:,:,i),bwG(:,:,i), 'montage');
end

for i = 1 : size(B,3);
bwB(:,:,i) = fibermetric(B(:,:,i),8,'ObjectPolarity','bright','StructureSensitivity',8);
%imshowpair(G(:,:,i),bwG(:,:,i), 'montage');
end



%montage(B);




%imshow(G(:,:,18));
% figure
% imshowpair(max(im, [],3), max(B,[],3), 'montage');
BW_R = imbinarize(R);
BW_B = imbinarize(bwB);
BW_G = imbinarize(bwG); % Not sure how to binarize...

numberOfTruePixels_R = sum(BW_R(:));
numberOfTruePixels_G = sum(BW_G(:));

for i=1 : size(BW_G,3);
    se = strel('disk',2);
    BW_G(:,:,i) = imdilate(BW_G(:,:,i),se);
    se = strel('disk',3);
    BW_G(:,:,i) = imclose(BW_G(:,:,i),se);
end

%for i=1 : size(BW_B,3);
%    se = strel('disk',2);
%    BW_B(:,:,i) = imdilate(BW_B(:,:,i),se);
%    se = strel('disk',3);
%    BW_B(:,:,i) = imclose(BW_B(:,:,i),se);
%end

% for i = 1 : size(BW_R,3);
% intersectedImage(:,:,i) = bitand(BW_R(:,:,i),BW_G(:,:,i));
% end
% 
% numberOfTruePixels_Intersected = sum(intersectedImage(:));
% percentIntersection_G = (numberOfTruePixels_Intersected / numberOfTruePixels_G) * 100; 
% percentIntersection_R = (numberOfTruePixels_Intersected / numberOfTruePixels_R) * 100; 

% Need to filter small objects
BW_G = bwareaopen(BW_G, 30000); % Removes all small objects from image <10000
BW_B = bwareaopen(BW_B, 1500); % Removes all small objects from image <10000
BW_R = bwareaopen(BW_R, 2000000); % Removes all small objects from image <10000
%figure;
%imshow(BW_R(:,:,14));


for i =1 : size(BW_G, 3)
    se = strel('disk',5);
    BW_G_filled(:,:,i) = imclose(BW_G(:,:,i), se);
end 

%for i =1 : size(BW_B, 3)
%    se = strel('disk',1);
%    BW_B(:,:,i) = imclose(BW_B(:,:,i), se);
%end 

%combined = or(BW_G_filled(:,:,15), BW_B(:,:,15));
%imshow(combined);
ConnectedComponentsR=bwconncomp(BW_R,26); %returns structure with 4 fields. PixelIdxList contains a 1-by-NumObjects cell array where the k-th element in the cell array is a vector containing the linear indices of the pixels in the k-th object. 26 defines connectivity. This looks at cube of connectivity around pixel.

ConnectedComponentsG=bwconncomp(BW_G_filled,26); %returns structure with 4 fields. PixelIdxList contains a 1-by-NumObjects cell array where the k-th element in the cell array is a vector containing the linear indices of the pixels in the k-th object. 26 defines connectivity. This looks at cube of connectivity around pixel.
stats = regionprops3(ConnectedComponentsG); % Some stats about the cells
numObj = numel(ConnectedComponentsG.PixelIdxList); %PixelIdxList is field with list of pixels in each connected component. Find how many connected components there are.

ConnectedComponentsB=bwconncomp(BW_B,26); %returns structure with 4 fields. PixelIdxList contains a 1-by-NumObjects cell array where the k-th element in the cell array is a vector containing the linear indices of the pixels in the k-th object. 26 defines connectivity. This looks at cube of connectivity around pixel.
stats = regionprops3(ConnectedComponentsB); % Some stats about the cells
numObj = numel(ConnectedComponentsB.PixelIdxList); %PixelIdxList is field with list of pixels in each connected component. Find how many connected components there are.
imshow(BW_B(:,:,12));
% combine all the filtered channels here to allow them to be graphed all
% together 
%% Code from 3DMorph to display 3D individual objects
s = size(im);
ex=zeros(s(1),s(2),s(3));
numObj=ConnectedComponentsB.NumObjects;
figure('Color','k','Position',[1 1 1024 1024]);
cmap=lines(numObj);
set(gca,'Color',[0 0 0],'DataAspectRatio',[1 1 1]);
for m = 1:numObj

    ex=zeros(s(1),s(2),s(3));
    if(m < ConnectedComponentsG.NumObjects) 
            ex(ConnectedComponentsG.PixelIdxList{1,m})=1;%write in only one object to image. Cells are white on black background
            ds = size(ex);
            se = strel('disk',3);
            ex = imclose(ex,se);
            %ex = Skeleton3D(ex);
            camlight %To add lighting/shading
            lighting gouraud; %Set style of lighting. This allows contours, instead of flat lighting
            view(0,270); % Lookf at image from top viewpoint instead of side  
            daspect([1 1 1]); 
            fv=isosurface(ex,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
            patch(fv,'FaceColor',cmap(m,:),'FaceAlpha',1,'EdgeColor','none');%without edgecolour, will auto fill black, and all objects appear black

    end 
    ex(ConnectedComponentsB.PixelIdxList{1,m})=1;%write in only one object to image. Cells are white on black background
    ds = size(ex);
    se = strel('disk',3);
    ex = imclose(ex,se);
    %ex = Skeleton3D(ex);
    camlight %To add lighting/shading
    lighting gouraud; %Set style of lighting. This allows contours, instead of flat lighting
    view(0,270); % Lookf at image from top viewpoint instead of side  
    daspect([1 1 1]); 
    fv=isosurface(ex,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
    patch(fv,'FaceColor',cmap(m,:),'FaceAlpha',1,'EdgeColor','none');%without edgecolour, will auto fill black, and all objects appear black
    %branchpts = branchpoints3(ex);
    %BWBRANCH = imbinarize(branchpts);
    %BranchConnectedComponents=bwconncomp(BWBRANCH,26);
    %BranchnumObj = numel(BranchConnectedComponents.PixelIdxList);
    %AllBranches(m, 1) = BranchnumObj; 
    %endpts = endpoints3(ex);
    %BWEND = imbinarize(endpts);
    %EndConnectedComponents=bwconncomp(BWEND,26);
    %BranchnumObj = numel(EndConnectedComponents.PixelIdxList);
    %AllEndpoints(m, 1) = BranchnumObj; 
    %fv=isosurface(branchpts,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
    %patch(fv,'FaceColor',[0 1 1],'FaceAlpha',1,'EdgeColor','none');
    %fv=isosurface(endpts,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
    %patch(fv,'FaceColor',[1 1 0],'FaceAlpha',1,'EdgeColor','none');
    axis([0 ds(1) 0 ds(2) 0 ds(3)]);%specify the size of the image
    flatex = sum(ex,3);
    allObjs(:,:,m) = flatex(:,:); 
    disp(m);
end
s = size(im);
ex=zeros(s(1),s(2),s(3));
numObj=ConnectedComponentsG.NumObjects;
figure('Color','k','Position',[1 1 1024 1024]);
cmap=lines(numObj);
set(gca,'Color',[0 0 0],'DataAspectRatio',[1 1 1]);
for m = 1:numObj
    ex=zeros(s(1),s(2),s(3));
    ex(ConnectedComponentsG.PixelIdxList{1,m})=1;%write in only one object to image. Cells are white on black background
    ds = size(ex);
    se = strel('disk',3);
    ex = imclose(ex,se);
    %ex = Skeleton3D(ex);
    camlight %To add lighting/shading
    lighting gouraud; %Set style of lighting. This allows contours, instead of flat lighting
    view(0,270); % Lookf at image from top viewpoint instead of side  
    daspect([1 1 1]); 
    fv=isosurface(ex,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
    patch(fv,'FaceColor',cmap(m,:),'FaceAlpha',1,'EdgeColor','none');%without edgecolour, will auto fill black, and all objects appear black
    %branchpts = branchpoints3(ex);
    %BWBRANCH = imbinarize(branchpts);
    %BranchConnectedComponents=bwconncomp(BWBRANCH,26);
    %BranchnumObj = numel(BranchConnectedComponents.PixelIdxList);
    %AllBranches(m, 1) = BranchnumObj; 
    %endpts = endpoints3(ex);
    %BWEND = imbinarize(endpts);
    %EndConnectedComponents=bwconncomp(BWEND,26);
    %BranchnumObj = numel(EndConnectedComponents.PixelIdxList);
    %AllEndpoints(m, 1) = BranchnumObj; 
    %fv=isosurface(branchpts,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
    %patch(fv,'FaceColor',[0 1 1],'FaceAlpha',1,'EdgeColor','none');
    %fv=isosurface(endpts,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
    %patch(fv,'FaceColor',[1 1 0],'FaceAlpha',1,'EdgeColor','none');
    axis([0 ds(1) 0 ds(2) 0 ds(3)]);%specify the size of the image
    flatex = sum(ex,3);
    allObjs(:,:,m) = flatex(:,:); 
    disp(m);
end
for i=1:numObj;
    Object(i,1) = i;
end
FinalMicrogliaData = table (Object, AllEndpoints, AllBranches);

%%