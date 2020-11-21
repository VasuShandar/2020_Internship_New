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
    
%% Code from 3DMorph to display 3D individual objects
s = size(im);
ex=zeros(s(1),s(2),s(3));
numObj=ConnectedComponents.NumObjects;
figure('Color','k','Position',[1 1 1024 1024]);
cmap=lines(numObj);
set(gca,'Color',[0 0 0],'DataAspectRatio',[1 1 1]);
for m = 1:numObj
    ex=zeros(s(1),s(2),s(3));
    ex(ConnectedComponents.PixelIdxList{1,m})=1;%write in only one object to image. Cells are white on black background
    ds = size(ex);
    se = strel('disk',3);
    ex = imclose(ex,se);
    ex = Skeleton3D(ex);
    % camlight %To add lighting/shading
    % lighting gouraud; %Set style of lighting. This allows contours, instead of flat lighting
    % view(0,270); % Lookf at image from top viewpoint instead of side  
    % daspect([1 1 1]); 
    % fv=isosurface(ex,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
    % patch(fv,'FaceColor',cmap(m,:),'FaceAlpha',1,'EdgeColor','none');%without edgecolour, will auto fill black, and all objects appear black
    branchpts = branchpoints3(ex);
    BWBRANCH = imbinarize(branchpts);
    BranchConnectedComponents=bwconncomp(BWBRANCH,26);
    BranchnumObj = numel(BranchConnectedComponents.PixelIdxList);
    AllBranches(m, 1) = BranchnumObj; 
    endpts = endpoints3(ex);
    BWEND = imbinarize(endpts);
    EndConnectedComponents=bwconncomp(BWEND,26);
    BranchnumObj = numel(EndConnectedComponents.PixelIdxList);
    AllEndpoints(m, 1) = BranchnumObj; 
    % fv=isosurface(branchpts,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
    % patch(fv,'FaceColor',[0 1 1],'FaceAlpha',1,'EdgeColor','none');
    % fv=isosurface(endpts,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
    % patch(fv,'FaceColor',[1 1 0],'FaceAlpha',1,'EdgeColor','none');
    % axis([0 ds(1) 0 ds(2) 0 ds(3)]);%specify the size of the image
    flatex = sum(ex,3);
    allObjs(:,:,m) = flatex(:,:); 
    disp(m);
end
for i=1:numObj;
    Object(i,1) = i;
end
a = table (Object, AllEndpoints, AllBranches);

%%