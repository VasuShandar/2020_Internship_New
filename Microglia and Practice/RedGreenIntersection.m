% function to find intersection between red and green channels in image 
tiff_info = imfinfo('Microglia_IHC_Zoom2.tif'); % return tiff structure, one element per image
im = imread('Microglia_IHC_Zoom2.tif', 1) ; % read in first image
%concatenate each successive tiff to tiff_stack
for ii = 2 : size(tiff_info, 1)
    temp_tiff = imread('Microglia_IHC_Zoom2.tif', ii);
    im = cat(3 , im, temp_tiff);
end

% rgbImage(:,:,:,2) = imread(im,k);

% Improves Fiber Detection
for i = 1 : size(im,3);
B(:,:,i) = fibermetric(im(:,:,i),4,'ObjectPolarity','bright','StructureSensitivity',6);
% imshowpair(im(:,:,i),B(:,:,i), 'montage');
end



for i =1 : (size(B,3))/3;
    G(:,:,i) = B(:,:,((i*3)-1));
    %imshow(G(:,:,i));

end 


for i =1 : (size(B,3))/3;
    R(:,:,i) = B(:,:,((i*3)-2));
    %imshow(R(:,:,i));

end 

%imshow(G(:,:,18));
% figure
% imshowpair(max(im, [],3), max(B,[],3), 'montage');
BW_R = imbinarize(R)
BW_G = imbinarize(G); % Not sure how to binarize...

numberOfTruePixels_R = sum(BW_R(:));
numberOfTruePixels_G = sum(BW_G(:));

for i = 1 : size(BW_R,3);
intersectedImage(:,:,i) = bitand(BW_R(:,:,i),BW_G(:,:,i));
end

numberOfTruePixels_Intersected = sum(intersectedImage(:));
percentIntersection_G = (numberOfTruePixels_Intersected / numberOfTruePixels_G) * 100; 
percentIntersection_R = (numberOfTruePixels_Intersected / numberOfTruePixels_R) * 100; 

% Need to filter small objects
BW2 = bwareaopen(BW_R, 100000); % Removes all small objects from image <10000
ConnectedComponents=bwconncomp(BW,26); %returns structure with 4 fields. PixelIdxList contains a 1-by-NumObjects cell array where the k-th element in the cell array is a vector containing the linear indices of the pixels in the k-th object. 26 defines connectivity. This looks at cube of connectivity around pixel.
stats = regionprops3(ConnectedComponents); % Some stats about the cells
numObj = numel(ConnectedComponents.PixelIdxList); %PixelIdxList is field with list of pixels in each connected component. Find how many connected components there are.
    