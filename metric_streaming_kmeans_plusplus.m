function [ centroids, out_struct ] = metric_streaming_kmeans_plusplus( oracle, X, opts)
%METRIC_STREAMING_KMEANS_PLUSPLUS Performs histogram clustering with smart
%initialization wrt general metric
%   oracle takes the form [dist, grad] = oracle(x,y) where the gradient is wrt x
%   X is a matrix where each row is a histogram
%   opts is a struct with the following options:
%       k -- the number of cluster
%       smart_seeding -- whether to use the k-means++ seeding
%       iters -- number of iterations to run online method
%       batch_size -- number of points to consider in one batch
%       stepsize -- step size/learning rate for stochastic gradient
%       batch_gradients_in_parallel -- whether to use the gradients
%       computed when assigning points to clusters (as compared to updating
%       the gradients later on, during the pass)

proj_simplex_helper = proj_simplex(); %TFOCS
function [x_out] = proj(x)
    [~, x_out] = proj_simplex_helper(x, 1);
end

% extract options
k = opts.k;
smart_seeding = opts.smart_seeding;
iters = opts.iters;
batch_size = opts.batch_size;
stepsize = opts.stepsize;
use_decaying_stepsize = opts.use_decaying_stepsize;
batch_gradients_in_parallel = opts.batch_gradients_in_parallel;

% initialize centroids
if smart_seeding
    use_mcmc = opts.use_mcmc;

    fprintf('initializing centroids via k-means++\n');
    centroids = initialize_kmeans_plusplus( oracle, X, k, use_mcmc );
else
    centroids = X(randsample(size(X,1), k), :);
end

fprintf('fixing random order\n');
perm_inx = randperm(size(X,1));

% now iterate centroid assignment and updates
fprintf('starting main loop\n');
cluster_sizes = zeros(k, 1);
estimated_costs = zeros(iters,1);
for ii=1:iters
    fprintf('\titeration %d...', ii);
    starttime = tic;
    
    range = mod((0:batch_size-1) + (ii-1)*batch_size, size(X,1)) + 1;
    batch = X(perm_inx(range),:);
    
    [cluster_indices, vals, grads] = find_closest_centroid(centroids, oracle, batch);
    total_cost_this_iter = 0;
    for jj=1:length(range)
        Xjj = batch(jj,:);
        cluster_inx = cluster_indices(jj);

        % determining stepsizes as in Sculley
        cluster_sizes(cluster_inx) = cluster_sizes(cluster_inx) + 1;
        
        if use_decaying_stepsize
            stepsize = 1 / cluster_sizes(cluster_inx);
        end
        
        if batch_gradients_in_parallel
            D = vals(jj);
            grad = grads(jj,:);
        else
            [D, grad] = oracle(centroids(cluster_inx,:)', Xjj);
        end
        
        total_cost_this_iter = total_cost_this_iter + D;
        
        % is this valid?
        grad(isinf(grad)) = 0;

        if opts.project
            centroids(cluster_inx,:) = proj(centroids(cluster_inx,:) - stepsize * grad(:)');
        else
            centroids(cluster_inx,:) = centroids(cluster_inx,:) - stepsize * grad(:)';
        end
    end
    estimated_costs(ii) = total_cost_this_iter * size(X,1) / batch_size;
    fprintf('done, took %d seconds, cost: %f\n', ceil(toc(starttime)), estimated_costs(ii));
end

out_struct.estimated_costs = estimated_costs;
out_struct.cluster_inx_last_iter = cluster_inx;
out_struct.cluster_sizes = cluster_sizes;

end

function [cluster_inx, vals, grads] = find_closest_centroid(centroids, oracle, X)
k = size(centroids, 1);
dim = size(centroids, 2);
n = size(X, 1);

cluster_inx = zeros(n,1);
vals = zeros(n,1);
grads = zeros(n,dim);
parfor ii=1:n
    Xii = X(ii,:);
    
    dists = zeros(k,1);
    grads_ii = zeros(k,dim);
    for jj=1:k
        [D, grad] = oracle(centroids(jj,:), Xii);
        dists(jj) = D;
        grads_ii(jj,:) = grad;
    end
    [~, inx] = min(dists);
    cluster_inx(ii) = inx;
    vals(ii) = dists(inx);
    grads(ii,:) = grads_ii(inx,:);
end
end

