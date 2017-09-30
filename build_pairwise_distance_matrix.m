function [C] = build_pairwise_distance_matrix(cloud_distance_type, lambda)
% lambda is the ratio between the cost to remove/add mass and the maximum cost otherwise

%% build the pairwise distance matrix

if cloud_distance_type == CloudDistanceType.EuclideanBasedOnValues
    % NUMBER OF CLOUDY PIXELS  10 <= PC <=  180 MB
    % NUMBER OF CLOUDY PIXELS 180  < PC <=  310 MB
    % NUMBER OF CLOUDY PIXELS 310  < PC <=  440 MB
    % NUMBER OF CLOUDY PIXELS 440  < PC <=  560 MB
    % NUMBER OF CLOUDY PIXELS 560  < PC <=  680 MB
    % NUMBER OF CLOUDY PIXELS 680  < PC <=  800 MB
    % NUMBER OF CLOUDY PIXELS 800  < PC <= 1000 MB

    x_cutoffs = [10 180 310 440 560 680 800 1000];
    x = 0.5 * (x_cutoffs(1:7) + x_cutoffs(2:8));
    % rescale so each feature is equally important
    x = x / (max(x) - min(x));

    % 0.02 <= TAU <=   1.27    
    % 1.27  < TAU <=   3.55    
    % 3.55  < TAU <=   9.38    
    % 9.38  < TAU <=  22.63    
    % 22.63  < TAU <=  60.36    
    % 60.36  < TAU <= 378.65

    y_cutoffs = [0.02 1.27 3.55 9.38 22.63 60.36 378.65];
    y = 0.5 * (y_cutoffs(1:6) + y_cutoffs(2:7));
    % rescale so each feature is equally important
    y = y / (max(y) - min(y));
else
    x = 1:7;
    y = 1:6;
end

ordered_pairs = zeros(6*7, 2);
ordered_pairs(:,2) = repmat(y, 1, 7);
for ii=1:7
    ordered_pairs(6*(ii-1) + (1:6),1) = x(ii);
end

d2 = @(a,b) sqrt((a(1) - b(1))^2 + (a(2) - b(2))^2);

C = zeros(6*7, 6*7);
for ii=1:6*7
    for jj=1:6*7
        C(ii,jj) = d2(ordered_pairs(ii,:), ordered_pairs(jj,:));
    end
end

% add an extra state for creation/deletion of mass
creation_cost = lambda*max(max(C));
C = [C creation_cost*ones(6*7,1); creation_cost*ones(1,6*7) 0];

end
