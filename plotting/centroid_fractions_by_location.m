function [ relative_occurence_by_centroid ] = centroid_fractions_by_location(X_grouped, centroids, oracle)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[m, n] = size(X_grouped);
N = 100; % number of samples to take

k = size(centroids,1);
relative_occurence_by_centroid = cell(k, 1);
for kk=1:k
    relative_occurence_by_centroid{kk} = zeros(m, n);
end

ws_counts_cell = cell(m, n);

for ii=1:m
    parfor jj=1:n
        X = X_grouped{ii,jj};
        if isempty(X)
            continue;
        end
        
        X = double(X); % won't scale well to the full dataset because uint8 more efficient
        X = X / 255;
        X = [X, 1 - sum(X, 2)];
        [~, ws_counts] = estimate_metric_kmeans_objective(oracle, X, centroids, N);
        
        ws_counts_cell{ii,jj} = ws_counts;
    end
    fprintf('Finished ii=%d of %d\n', ii, m);
end

for ii=1:m
    for jj=1:n
        for kk=1:k
            if isempty(ws_counts_cell{ii,jj})
                continue
            end
            relative_occurence_by_centroid{kk}(ii, jj) = ws_counts_cell{ii,jj}(kk);
        end
    end
end

end

