function [im_can, im1_can, im2_can] = mosaic_images(im1, im2, h1, h2, type)
% mosaic  images

% form larger canvas
% r0 = rows added to top
% r1 = rows added to bottom
% c0 = columns added to left
r0 = 100;
c0 = 100;
r1 = 100;
msz1 = max(size(im1,1), size(im2,1));
msz2 = max(size(im1,2), size(im2,2));
% create canvas using the dimensions of the larger input image
% create 50% more columns in the canvas
im_can = zeros(msz1+r0+r1, msz2*1.5+c0,3);

% homography for the first matrix
p = h1;
H1 = [p(1) p(2) p(3);
 p(4) p(5) p(6);
 p(7) p(8) p(9)];

% homography for the first matrix
p = h2;
H2 = [p(1) p(2) p(3);
 p(4) p(5) p(6);
 p(7) p(8) p(9)];

% create empty canvases separately for both images
im1_can = zeros(size(im_can));
im2_can = zeros(size(im_can));

% copy the original images to the canvases
im1_can(r0+1:r0+size(im1,1), c0+1:c0+size(im1,2), :) = im1;
im2_can(r0+1:r0+size(im2,1), c0+1:c0+size(im2,2), :) = im2;

% figure, imshow(uint8(im1_can));
% figure, imshow(uint8(im2_can));

% apply homography to the second image canvas
im2_can(:,:,1) = warp_image(im2_can(:,:,1), H2,r0,c0);
im2_can(:,:,2) = warp_image(im2_can(:,:,2), H2,r0,c0);
im2_can(:,:,3) = warp_image(im2_can(:,:,3), H2,r0,c0);

if type == 1
    % blend using averaging when both the image pixels are non-zero
    mult = 1 - (im1_can > 10 & im2_can > 10) * 0.5;
    im_can = (im1_can + im2_can) .* mult;
elseif type == 2
    % copy the first image, then copy the warped second image only to the
    % non-zero pixels
    im_can = im1_can + double( im1_can == 0 ) .* im2_can;
end

% figure, imshow(uint8(im2_can));
% figure, imshow(uint8(im2_can(:,:,1)));
% figure, imshow(uint8(im2_can(:,:,2)));
% figure, imshow(uint8(im2_can(:,:,3)));
