function [ centroids, out_struct ] = euclidean_streaming_kmeans_plusplus( X, opts )
%EUCLIDEAN_KMEANS_PLUSPLUS Performs W2 histogram clustering with smart
%initialization
%   X is a matrix where each row is a histogram
%   opts contains other parameters for metric_streaming_kmeans++

oracle = @(x,y) oracle_helper(x, y);

opts.project = 0;
[centroids, out_struct] = metric_streaming_kmeans_plusplus(oracle, X, opts);
end

function [D, grad] = oracle_helper(x, y)
    x = x(:); y = y(:);
    D = norm(x - y, 2)^2;
    grad = 2*(x-y);
end
