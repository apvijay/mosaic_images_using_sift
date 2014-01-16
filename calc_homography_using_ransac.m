% Function to choose four correspondences from a set of SIFT (or any other
% method) matched points using RANSAC and determine the homographey between
% them.
% Input : 'n' feature-matched points mp1, mp2, each of size nx2
% Output :
% h - homography (3x3 matrix)
% best_idx - indices of chosen points
% best_cons_set - indices of consensus set
% best_tot_err - total l2-error corresponding to the chosen consensus set

function [best_h, best_idx, best_cons_set, best_tot_err] = calc_homography_using_ransac(mp1, mp2)

q = 4; % number of correspondences needed
siz = size(mp1,1);

% RANSAC parameters

% threshold whether to add a particular point to consensus set
thresh = 10; %10 % 25 for balcony

% max iterations for RANSAC
max_iter = 1000;

% minimum cardinality of the consensus set needed
d = 0.8 * siz; %0.8

% init parameters
best_tot_err = Inf;
iter = 1;
best_h = [1 0 0 0 1 0 0 0 1]';
% best_flag = 0;

while iter < max_iter
    if rem(iter,100) == 0
        fprintf('%d\n', iter);
    end
    
% choose q rand points and store in idx
tmp = randperm(siz);
idx = tmp(1:q);
clear tmp;

mp1_sel = mp1(idx,:);
mp2_sel = mp2(idx,:);

% form matrix for linear equation [xd;yd] = A[x;y] and solve
% i.e, find null space of A[x;y] - [xd;yd] = 0
count = 1;
for i = 1:q
    x = mp1_sel(i,1);
    y = mp1_sel(i,2);
    xd = mp2_sel(i,1);
    yd = mp2_sel(i,2);
    % create two rows of A for each pair (xd = Hx and yd = Hy)
    A(count,:) = [x y 1 0 0 0 -xd*x -xd*y -xd];
    count = count + 1;
    A(count,:) = [0 0 0 x y 1 -yd*x -yd*y -yd];
    count = count + 1;
end
h = null(A);
h = h / h(9); % h(9) is arbitrary scale. make it 1 and normalize 

p = h;
H = [p(1) p(2) p(3);
 p(4) p(5) p(6);
 p(7) p(8) p(9)];

% init empty consensus set and zero total error
cons_set = [];
tot_err = 0;
for i = 1:siz
    % check all points other than the chosen ones
    if ~ismember(i,idx)
        x = mp1(i,1);
        y = mp1(i,2);
        xd = mp2(i,1);
        yd = mp2(i,2);
        tmp = H * [x;y;1];
        xt = tmp(1) / tmp(3);
        yt = tmp(2) / tmp(3);
        err = sqrt(sum(([xt yt] - [xd yd]).^2));
        % check l2-norm euclidean distance
        if err < thresh
            % this point satisifes xd = Hx+eps and yd = Hx+eps
            % add to consensus set
            % and accumulate total error
            cons_set = [cons_set i];
            tot_err = tot_err + err;
        end
    end
end

% if consensus set is large enough and total error in this iteration is
% better than the previous best total error, assign this set as the best
% consensus set
if numel(cons_set) > d
    if tot_err < best_tot_err
        best_h = h;
        best_cons_set = cons_set;
        best_idx = idx;
        best_tot_err = tot_err;
%         best_flag = 1;
    end
end
iter = iter + 1;

% if number of iterations is not sufficient to find a best consensus set,
% iterate more

% if iter == max_iter
%     if best_tot_err > 150
%         iter = iter - round(max_iter / 2);
%     end
% end
end
if best_tot_err == Inf
    best_cons_set = [];
    best_idx = [];
end
