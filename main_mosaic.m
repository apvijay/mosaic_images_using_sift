% testing SIFT package v4 by Lowe
close all;
clear all;
clc;


imgName1 = 'orig1_small.JPG';
imgName2 = 'mb1_small.JPG';

% calculate matching sift points using dot prod/angle
fprintf('Determining SIFT correspondences...\n');
tic
[~, ~, mp1, mp2, ~] = match_using_sift(imgName1, imgName2, 1);
toc
%%
fprintf('Determining homography...\n');
tic
[h, best_idx, best_cons_set, best_tot_err] = calc_homography_using_ransac(mp1, mp2);
toc
%%
if isempty(best_cons_set)
    fprintf('Unable to find consensus set (Too few inliers or matching poitnt\n');
else
h
if 0
% shift h mat correp
h1 = [1 0 0 0 1 0 0 0 1]' + [0 0 0 0 0 0 0 0 0]';
h2 = h;
%% average
fprintf('Mosaicing.. blending by average...\n');
tic
im1 = imread(imgName1);
im2 = imread(imgName2);
[im_can1, im1_can, im2_can] = mosaic_images(im1, im2, h1, h2, 1);
toc
% figure, imshow(uint8(im1_can));
% figure, imshow(uint8(im2_can));
figure, imshow(uint8(im_can1));
% imwrite(uint8(im_can1), '012_mosaic_avg.png');
%% copy
fprintf('Mosaicing.. blending by copy...\n');
tic
im1 = imread(imgName1);
im2 = imread(imgName2);
[im_can2, im1_can, im2_can] = mosaic_images(im1, im2, h1, h2, 2);
toc
% figure, imshow(uint8(im1_can));
% figure, imshow(uint8(im2_can));
figure, imshow(uint8(im_can2));
% imwrite(uint8(im_can2), '012_mosaic_copy.png');
end
end