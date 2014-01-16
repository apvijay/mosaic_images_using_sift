% Warp f using H. Use bilinear interpolation
% r0 and c0 are the origin(1,1) offsets

function g = warp_image(f,H,r0,c0)

[row,col] = size(f);

% create meshgrid with offsets (r0,c0)
[tmp1,tmp2]= meshgrid(1-r0:row-r0,1-c0:col-c0);

% each row contains point's index
allPoints = [tmp1(:) tmp2(:) ones(numel(tmp1),1)]; 

% perform H * x
newPoints = H * allPoints'; 

% Make z as 1 (homo coord)
tmp3 = 1./newPoints(3,:); 
newPoints = newPoints .* [tmp3; tmp3; tmp3]; 

clear tmp1 tmp2 tmp3;

% remove offsets and interpolate
g = interp2(f,newPoints(2,:)'+c0,newPoints(1,:)'+r0,'linear');
g(isnan(g)) = 0;

% row major reshape
g = reshape(g, [size(f,2) size(f,1)]); 
g = g';
