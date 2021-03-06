%% 3D Skeleton
%Can use two different methods to keep all processes (more fine
%structures), or only major branches (and ignore small extensions). From
%skeleton, endpoints and branch points are identified. In skeleton image,
%red processes are primary, yellow secondary, green tertiary, and blue are
%connected to endpoints. Branch lengths are measured as the shortest
%distance from each endpoint to the centroid. If the program is unable to
%propoerly identify a centroid or endpoints, it will output a 0 and move to
%the next cell.
function skelstats = SkeletonStats(numObj, FullMg)
kernel(:,:,1) = [1 1 1; 1 1 1; 1 1 1];
kernel(:,:,2) = [1 1 1; 1 0 1; 1 1 1];
kernel(:,:,3) = [1 1 1; 1 1 1; 1 1 1]; 

numendpts = zeros(numel(FullMg),1);
numbranchpts = zeros(numel(FullMg),1);
MaxBranchLength = zeros(numel(FullMg),1);
MinBranchLength = zeros(numel(FullMg),1);
AvgBranchLength = zeros(numel(FullMg),1);
cent = (zeros(numObj,3));

BranchLengthList=cell(1,numel(FullMg));

parfor i=1:numel(FullMg)
    try
    ex=zeros(s(1),s(2),zs);%#ok<PFBNS> %Create blank image of correct size
    ex(FullMg{1,i})=1;%write in only one object at a time to image. 
    ds = size(ex); 
    cmap=lines(numObj);
    if OrigCellImg == 1
        title = [file,'_Cell',num2str(i)];
        figure('Name',title);
        fv=isosurface(ex,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
        patch(fv,'FaceColor',cmap(i,:),'FaceAlpha',1,'EdgeColor','none');%without edgecolour, will auto fill black, and all objects appear black
        axis([0 ds(1) 0 ds(2) 0 ds(3)]);%specify the size of the image
        camlight %To add lighting/shading
        lighting gouraud; %Set style of lighting. This allows contours, instead of flat lighting
        view(0,270); % Look at image from top viewpoint instead of side  
        daspect([1 1 1]);
        filename = ([file '_Original_cell' num2str(i)]);
        saveas(gcf, fullfile(fpath, filename), 'jpg');
    end
    


% Find endpoints, and trace branches from endpoints to centroid    
    i2 = floor(cent(i,:)); %From the calculated centroid, find the nearest positive pixel on the skeleton, so we know we're starting from a pixel with value 1.
    if DownSampled == 1
       i2(1) = round(i2(1)/2);
       i2(2) = round(i2(2)/2);
    end
    closestPt = NearestPixel(WholeSkel,i2,scale);
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
    hold off
    filename = ([file '_Skeleton_cell' num2str(i)]);
    saveas(gcf, fullfile(fpath, filename), 'jpg');
    
    
    % Find branchpoints
    brpts =zeros(si(1),si(2),si(3),4);
    for kk=1:3 %For branchpoints not connected to end branches (ie. not distal branches). In fullmask, 1 is branch connected to end point, so anything greater than that is included. 
    temp = (fullmask(:,:,:))>kk;
    tempendpts = (convn(temp,kernel,'same')==1)& temp; %Get all of the 'distal' endpoints of kk level branches
    brpts(:,:,:,kk+1)=tempendpts;
    end

    % Find any branchpoints of 1s onto 4s (ie. final branch coming off of main trunk). 
    quatendpts = (convn(quat,kernel,'same')==1)& quat; %convolution, overlaying the kernel cube onto final branches only.
    quatbrpts = quatendpts - endpts; %Have points at both ends of final branches. Want to exclude any distal points (true endpoints)
    %Only want to keep these quant branchpoints if they're connected to a 4(primary branch). Otherwise, the branch point will have been picked up in the previous for loop. 
    fullrep= fullmask;
    fullrep(fullrep(:,:,:)<4)=0;%Keep only the 4s, as 4s (don't convert to 1)
    qbpts = fullrep+quatbrpts;%Add the two vectors, so should have 4s and 1s.
    qbpts1 = convn(qbpts,ones([3 3 3]),'same'); %convolve with cube of ones to get 'connectivity'. All 1s 
    brpts(:,:,:,1) = (quatbrpts.*qbpts1)>= 5;

    allbranch = sum(brpts,4); %combine all levels of branches
    BranchptList = find(allbranch==1);%Find how many pixels are 1s (branchpoints)
    [r,c,p]=ind2sub(si,BranchptList);%Output of ind2sub is row column plane
    BranchptList = [r c p];
    numbranchpts(i,:) = length(BranchptList);
    
        title = [file,'_Cell',num2str(i)];
        figure('Name',title); %Plot all branches with endpoints
        fv1=isosurface(fullmask,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
        patch(fv1,'FaceColor',[0 0 1],'FaceAlpha',0.1,'EdgeColor','none');%without edgecolour, will auto fill black, and all objects appear black
        camlight %To add lighting/shading
        lighting gouraud; %Set style of lighting. This allows contours, instead of flat lighting
        view(0,270); % Look at image from top viewpoint instead of side 
        fv2=isosurface(endpts,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
        patch(fv2,'FaceColor',[1 0 0],'EdgeColor','none');%without edgecolour, will auto fill black, and all objects appear black
        camlight %To add lighting/shading
        lighting gouraud; %Set style of lighting. This allows contours, instead of flat lighting
        view(0,270);
        daspect([1 1 1]);
        filename = ([file '_Endpoints_cell' num2str(i)]);
        saveas(gcf, fullfile(fpath, filename), 'jpg');
    
        title = [file,'_Cell',num2str(i)];
        figure('Name',title); %Plot all branches with branchpoints
        fv1=isosurface(fullmask,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
        patch(fv1,'FaceColor',[0 0 1],'FaceAlpha',0.1,'EdgeColor','none');%without edgecolour, will auto fill black, and all objects appear black
        camlight %To add lighting/shading
        lighting gouraud; %Set style of lighting. This allows contours, instead of flat lighting
        view(0,270); % Look at image from top viewpoint instead of side 
        fv2=isosurface(allbranch,0);%display each object as a surface in 3D. Will automatically add the next object to existing image.
        patch(fv2,'FaceColor',[1 0 0],'EdgeColor','none');%without edgecolour, will auto fill black, and all objects appear black
        camlight %To add lighting/shading
        lighting gouraud; %Set style of lighting. This allows contours, instead of flat lighting
        view(0,270);
        daspect([1 1 1]);
        filename = ([file '_Branchpoints_cell' num2str(i)]);
        saveas(gcf, fullfile(fpath, filename), 'jpg');
    
        
   catch
       %do nothing if an error is detected, just write in zeros and
       %continue to next loop iteration. 
   end
   
   disp(['cell ' num2str(i) ' of ' num2str(numel(FullMg))]); %#ok<PFBNS> %To see which cell we are currently prcoessing.
end

%Save Branch Lengths File
     names = ["cell1"];
     %Write in headings
    for CellNum = 1:numel(FullMg)
        input = strcat('Cell ',num2str(CellNum));
        names(CellNum,1) = input;
    end   
    BranchFilename = 'BranchLengths';
    xlswrite(fullfile(fpath, BranchFilename),names(:,:),1,'A1');
    %Write in data
    for ColNum = 1:numel(FullMg)
        if numel(BranchLengthList{1,ColNum})>0
            xlswrite(fullfile(fpath, BranchFilename),BranchLengthList{1,ColNum}',1,['B' num2str(ColNum)]);
        end
    end
 
 
%% Output results
%Creates new excel sheet with file name and saves to current folder.

xlswrite((strcat('Results',file)),{file},1,'B1');
xlswrite((strcat('Results',file)),{'Avg Centroid Distance um'},1,'A2');
xlswrite((strcat('Results',file)),AvgDist,1,'B2');
xlswrite((strcat('Results',file)),{'TotMgTerritoryVol um3'},1,'A3');
xlswrite((strcat('Results',file)),TotMgVol,1,'B3');
xlswrite((strcat('Results',file)),{'TotUnoccupiedVol um3'},1,'A4');
xlswrite((strcat('Results',file)),EmptyVol,1,'B4');
xlswrite((strcat('Results',file)),{'PercentOccupiedVol um3'},1,'A5');
xlswrite((strcat('Results',file)),PercentMgVol,1,'B5');
xlswrite((strcat('Results',file)),{'CellTerritoryVol um3'},1,'D1');
xlswrite((strcat('Results',file)),FullCellTerritoryVol(:,1),1,'E');
xlswrite((strcat('Results',file)),{'CellVolumes'},1,'F1');
xlswrite((strcat('Results',file)),CellVolume(:,1),1,'G');
xlswrite((strcat('Results',file)),{'RamificationIndex'},1,'H1');
xlswrite((strcat('Results',file)),FullCellComplexity(:,1),1,'I');
xlswrite((strcat('Results',file)),{'NumOfEndpoints'},1,'J1');
xlswrite((strcat('Results',file)),numendpts(:,1),1,'K');
xlswrite((strcat('Results',file)),{'NumOfBranchpoints'},1,'L1');
xlswrite((strcat('Results',file)),numbranchpts(:,1),1,'M');
xlswrite((strcat('Results',file)),{'AvgBranchLength'},1,'N1');
xlswrite((strcat('Results',file)),AvgBranchLength(:,1),1,'O');
xlswrite((strcat('Results',file)),{'MaxBranchLength'},1,'P1');
xlswrite((strcat('Results',file)),MaxBranchLength(:,1),1,'Q');
xlswrite((strcat('Results',file)),{'MinBranchLength'},1,'R1');
xlswrite((strcat('Results',file)),MinBranchLength(:,1),1,'S');


handles=findall(0,'type','figure');

for fig = 1:numel(handles) 
filename = get(handles(fig),'Name');
saveas(handles(fig), fullfile(fpath, filename), 'jpg');
end
close all;

end
%% Parameters file
%Save .mat parameters file for batch processing. Name is "Parameters_file
%name_date(year month day hour)"
% time = clock;
% name = ['Parameters_',file,'_',num2str(time(1)),num2str(time(2)),num2str(time(3)),num2str(time(4))];
% save(name,'ch','ChannelOfInterest','scale','zscale','adjust','noise','s','ShowImg','ShowObjImg','ShowCells','ShowFullCells','CellSizeCutoff','SmCellCutoff','KeepAllCells','RemoveXY','ConvexCellsImage','SkelMethod','SkelImg','OrigCellImg','EndImg','BranchImg','BranchLengthFile');
% delete(gcp); %close parallel pool so error isn't generated when program is run again.

