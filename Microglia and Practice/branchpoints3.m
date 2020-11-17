function branchpts = branchpoints3(BW)
% =========================================================================
%   Author: Siddhartha Dhiman
%   Email: sdhiman@buffalo.edu
%   Created with MATLAB 2018a
%   Copyright 2018
% -------------------------------------------------------------------------
% This is a function that takes in a 3D skeletonized logical image of size
% MxNxP and prodcues a logical image containing location of branch points.
% I was motivated by the lack of a 3D lookup table (LUT) or bwlookup within
% MATLAB. This function is ideal for deducing branchpoints in vasculature
% or pipes.
% -------------------------------------------------------------------------
% USAGE:
%   BP = branchpoints3(skel)
%   This command will produce a logical image same size as skel that
%   obtains pranchpoint using a 3x3x3 local region.
% =========================================================================

[X Y Z] = size(BW);
centralIdx = median(1:3);

branchpts = zeros(X,Y,Z);
% Index of center of square matrix circulating around the perimeter of
% image
iterX = centralIdx:(X - (centralIdx-1));
iterY = centralIdx:(Y - (centralIdx-1));
iterZ = centralIdx:(Z - (centralIdx-1));

% Nesting 'for' loops here allow a "scanning" like mechanism where the
% region of size sz-by-sz scans from one edge of x-axis to the other, then
% shifts up by one voxel on the y-axis and scans along the x-axis again.
% AFter scanning the entire xy-plane, it moves one voxel up the z-plane and
% rescans the xy-plane. It does this until the entire image is scanned.
for z2 = iterZ
    z1 = z2 - 1;
    z3 = z2 + 1;
    
    for y2 = iterY
        y1 = y2 - 1;
        y3 = y2 + 1;
        
        for x2 = iterX
            x1 = x2 - 1;
            x3 = x2 + 1;
            
            % Suppose in a 3x3x3 region containing 27 voxels, a continous 
            % line without branches in any plane would contain only 3 white
            % voxels. The presence of any additional voxels would imply the
            % presence of a branch. If this condition is met there is a
            % branch point in the region, otherwise there isn't.
            if BW(x2,y2,z2) == 1 && sum(...
                    reshape(BW(x1:x3,y1:y3,z1:z3),[],1,1)) > 3
                branchpts(x2,y2,z2) = 1;
            elseif BW(x2,y2,z2) == 1 && sum(...
                    reshape(BW(x1:x3,y1:y3,z1:z3),[],1,1))< 3
                branchpts(x2,y2,z2) = 0;
            else
                branchpts(x2,y2,z2) = 0;
            end
        end
    end
end
    
end