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
imshowpair(im(:,:,i),B(:,:,i), 'montage');
end
figure
imshowpair(max(im, [],3), max(B,[],3), 'montage');


BW = imbinarize(B); % Not sure how to binarize...
% Need to filter small objects
% labeledImage = bwlabel(BW, 8);
% imshow(labeledImage, []);

ConnectedComponents=bwconncomp(BW); % Find the cells, not sure how to optimize
labeled = labelmatrix(ConnectedComponents);
% stats = regionprops3(ConnectedComponents);

%RGB_label = label2rgb(labeled,@copper,'BW','shuffle');
%imshow(RGB_label)
% biggest = bwareafilt(ConnectedComponents);
% imshow(biggest);
%% ALL THIS IS JUNK/ PLAYING AROUND TO HELP SEGMENTATION



se = strel('disk',15);
closeBW = imclose(BW,se);

figure
imshowpair(max(BW, [],3), max(closeBW,[],3), 'montage');

% figure
% imshowpair(max(BW, [],3), max(closeBW,[],3), 'montage');

ConnectedComponents=bwconncomp(closeBW,16); %returns structure with 4 fields. PixelIdxList contains a 1-by-NumObjects cell array where the k-th element in the cell array is a vector containing the linear indices of the pixels in the k-th object. 26 defines connectivity. This looks at cube of connectivity around pixel.
numObj = numel(ConnectedComponents.PixelIdxList); %PixelIdxList is field with list of pixels in each connected component. Find how many connected components there are.
disp(numObj);
for i = 1:numObj
    ex=zeros(size(im,1),size(im,2),size(im,3));
    ex(ConnectedComponents.PixelIdxList{1,i})=1;%write in only one object to image. Cells are white on black background.
    flatex = sum(ex,3);
    allObjs(:,:,i) = flatex(:,:); 
    show(i);
end

DetectedObjs = sum(allObjs,3);
cmapCompress = parula(max(DetectedObjs(:)));  
cmapCompress(1,:) = zeros(1,3);

figure
imshow(allobjs)


if ShowImg == 1    
    title = [file,'_Threshold (compressed to 2D)'];
    figure('Name',title);imagesc(DetectedObjs);
    colormap(jet);
    daspect([1 1 1]);
end







imshowpair(max(im, [], 3), max(B, [], 3), 'montage')


T = adaptthresh(im, 0.1);
BW = imbinarize(im,T);

figure
imshowpair(max(im, [], 3), max(BW, [], 3), 'montage')


params.bz_thresh = -0;
params.as_scale = 1/4;
params.debug = 1; % show all figures
test=bwsmooth(BW(:,:,30),params);

figure(1),
imshowpair(BW(:,:,30), test, 'montage');
title( 'Original binarized image (Left) and Smoothed image (Right)' );