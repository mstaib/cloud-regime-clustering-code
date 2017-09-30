function [ D ] = centroid_distance_matrix( C, centroids, opts )
%CENTROID_DISTANCE_MATRIX Summary of this function goes here
%   Detailed explanation goes here

k = size(centroids, 1);
D = zeros(k);
for aa=1:k
    for bb=(aa+1):k
        D(aa,bb) = compute_single_ot_distance(C, centroids(aa,:), centroids(bb,:), opts.OTSolver, opts.p);
        D(bb,aa) = D(aa,bb);
    end
end
    
end

%function [x_hist] = add_last_col(x_row)
%    curr_sum = sum(x_row);
%    x_hist = [x_row(:)' 1-curr_sum];
%end
