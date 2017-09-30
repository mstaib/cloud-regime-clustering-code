function [ val, ws_counts ] = estimate_metric_kmeans_objective( oracle, X, centroids_cell, N)
%ESTIMATE_METRIC_KMEANS_OBJECTIVE Performs histogram clustering with smart
%initialization wrt general metric
%   oracle takes the form [dist, grad] = oracle(x,y) where the gradient is wrt x
%   C is the pairwise cost matrix (in this case, of _squared_ distances)
%   X is a matrix where each row is a histogram
%   k is the number of clusters

if ~iscell(centroids_cell)
    centroids = centroids_cell;
    clear centroids_cell;
    centroids_cell{1} = centroids;
end

%N = 100;%2000;
batch = X(randsample(size(X,1), N), :);

divide_by_255 = any(sum(centroids_cell{1}, 2) > 1 + 1e-8);

% use the same batch for all candidate centroids
val = zeros(length(centroids_cell), 1);
for ii=1:length(centroids_cell)
    if divide_by_255
        centroids = centroids_cell{ii} / 255; %Euclidean ones are stored out of 255
    end
    if size(centroids,2) ~= size(X,2)
        centroids = [centroids 1-sum(centroids,2)];
    end
    [vals, ws_counts] = find_closest_centroid(centroids, oracle, batch);
    val(ii) = sum(vals) * size(X,1) / N;
end

end

function [vals, ws_counts] = find_closest_centroid(centroids, oracle, X)
n = size(X, 1);

vals = zeros(n,1);
ws_counts = zeros(size(centroids, 1), 1);
for ii=1:n
    Xii = X(ii,:);
    [vals(ii), inx] = cost_single_point(centroids, oracle, Xii);
    ws_counts(inx) = ws_counts(inx) + 1;
end

ws_counts = ws_counts / sum(ws_counts);
end

function [estimate, inx] = cost_single_point(centroids, oracle, x)
k = size(centroids, 1);
dists = zeros(k,1);
for jj=1:k
    [D, ~] = oracle(centroids(jj,:), x);
    dists(jj) = D; 
end

[estimate, inx] = min(dists);
end