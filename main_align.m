close all;
clear all;
clc;


imgName1 = 'orig.png';
imgName2 = 'deblurred_rl_s05.png';


img1 = imread(imgName1);
img2 = imread(imgName2);


% calculate matching sift points using dot prod/angle
fprintf('Determining SIFT correspondences...\n');
tic
% Uses Lowe's SIFT package v4
[mp11, mp12] = sift_corresp(imgName2, imgName1);
toc


fprintf('Determining homography...\n');
tic
[h1, best_idx1, best_cons_set1, best_tot_err1] = calc_homography_using_ransac(mp11, mp12);
toc
%%
H = reshape(h1, [3 3]);
H = H';

[tmp1,tmp2]= meshgrid(1:size(img2,1),1:size(img2,2));
allPoints = [tmp1(:) tmp2(:) ones(numel(tmp1),1)]; % rows contains point's index
clear tmp1 tmp2;
newPoints = H \ allPoints'; % perform invH * x
tmp3 = 1./newPoints(3,:); 
newPoints = newPoints .* [tmp3; tmp3; tmp3]; % Make z as 1 (homo coord)
clear tmp3;
newPoints = newPoints';

% Form warped image g from the original image f with the 
% by mapping the transformed set of points. Use bilinear 
% interpolation since the points can be non-integers

for kk = 1:3
tmp = interp2(double(img2(:,:,kk)),newPoints(:,2),newPoints(:,1),'linear');
tmp(isnan(tmp)) = 0;
tmp = reshape(tmp, fliplr(size(img2(:,:,1))));
img21(:,:,kk) = tmp';
end

%%
figure, imshow(uint8(img21));