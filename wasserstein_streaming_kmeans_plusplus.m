function [ centroids, out_struct ] = wasserstein_streaming_kmeans_plusplus( C, X, opts )
%WASSERSTEIN_KMEANS_PLUSPLUS Performs W2 histogram clustering with smart
%initialization
%   C is the pairwise cost matrix (in this case, of _squared_ distances)
%   X is a matrix where each row is a histogram
%   opts contains other parameters for metric_streaming_kmeans++

oracle = @(x,y) compute_single_ot_distance(C, x, y, opts.OTSolver, opts.p);

opts.project = 1;
[centroids, out_struct] = metric_streaming_kmeans_plusplus(oracle, X, opts);
end