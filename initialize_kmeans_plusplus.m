function [ centroids ] = initialize_kmeans_plusplus( oracle, X, k, use_mcmc )
%INITIALIZE_KMEANS_PLUSPLUS Assigns centroids via D2 weighting
%   

n = size(X, 1);
d = size(X, 2);
centroids = zeros(k, d);

centroids(1,:) = X(randi(n),:);

squared_distances = Inf(n, 1);

% MCMC version from the Bachem/Krause paper
if use_mcmc
    for ii=2:k
        x = X(randi(n),:);
        dx = oracle(centroids(ii-1,:), x);
        
        % number of burn-in steps, hardcoded, arbitrary...
        m = 2000;
        for jj=2:m
            y = X(randi(n),:);
            dy = oracle(centroids(ii-1,:), y);
            if dy/dx > rand
                x = y;
                dx = dy;
            end
        end
        
        centroids(ii,:) = x;
    end
else
for ii=2:k
    for jj=1:n
        D = oracle(centroids(ii-1,:), X(jj,:));
        squared_distances(jj) = min(squared_distances(jj), D);
    end
    new_centroid_inx = randsample(n,1,true,squared_distances);
    
    centroids(ii,:) = X(new_centroid_inx,:);
end
end

end
