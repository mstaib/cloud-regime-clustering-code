clear;
[~,hostname] = system('hostname');
if strcmp(strtrim(hostname), 'mstaib.mit.edu')
    load '/mnt/data/climate-data/ISCCP-D1-full/all_histograms_tropics.mat'
    X = X_tropics_full; clear X_tropics_full;
else
    load 'all_histograms_tropics.mat'
    X = X_tropics_full; clear X_tropics_full;
end

%% truncate dataset for now
inx = randperm(size(X,1));
X = X(inx,:);

% won't scale well to the full dataset because uint8 more efficient; 
% long term we shouldn't load the whole dataset into memory...
X = double(X); 
X = X / 255;

%% do k-means++ clustering
ii = 1;
for lambda=[0.5]% 1]%[0.1 0.5 1 2]
    for k=[4 5 6 7 8]
        for smart_seeding=[1]
            for use_decaying_stepsize=[1]
                for batch_gradients_in_parallel=[0]
                    for stepsize=[1e-5]% 1e-3]
                        for cloud_distance_type=CloudDistanceType.EuclideanBasedOnGrid %[CloudDistanceType.EuclideanBasedOnValues CloudDistanceType.EuclideanBasedOnGrid]
                            for p=[1] % 2]
                                for ot_solver=[OTSolver.Gurobi]
                                    for dummy=1:8
                                        % experiments showed best results from decaying stepsize and NOT batching gradients
                                        if use_decaying_stepsize && batch_gradients_in_parallel
                                            continue
                                        end
                                        opts.lambda = lambda;
                                        opts.k = k;
                                        opts.smart_seeding = 1;
                                        opts.iters = 20;
                                        opts.batch_size = 1000;
                                        opts.stepsize = stepsize; %1e-4;
                                        opts.use_decaying_stepsize = use_decaying_stepsize;
                                        opts.batch_gradients_in_parallel = batch_gradients_in_parallel;
                                        opts.OTSolver = ot_solver;
                                        opts.CloudDistanceType = cloud_distance_type;
                                        opts.use_mcmc = 1;
                                        opts.p = p;


                                        opts_vec(ii) = opts;
                                        ii = ii + 1;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

num_params = length(opts_vec);
centroids_cell = cell(num_params,1);
out_struct_cell = cell(num_params,1);

euclidean_centroids_cell = cell(num_params,1);
euclidean_out_struct_cell = cell(num_params,1);

fprintf('Starting all Euclidean k-means runs\n');
for ii=1:num_params
    opts = opts_vec(ii);
    lambda = opts.lambda;

    [e_centroids, e_out_struct] = euclidean_streaming_kmeans_plusplus(X, opts);
    euclidean_centroids_cell{ii} = e_centroids;
    euclidean_out_struct_cell{ii} = e_out_struct;
end

fprintf('Starting all Wasserstein k-means runs\n');
X_expanded = [X, 1 - sum(X, 2)];
for ii=1:num_params
    opts = opts_vec(ii);
    lambda = opts.lambda;

    C = build_pairwise_distance_matrix(opts.CloudDistanceType, lambda);
    [centroids, out_struct] = wasserstein_streaming_kmeans_plusplus(C, X_expanded, opts);
    centroids_cell{ii} = centroids;
    out_struct_cell{ii} = out_struct;
end

%% build up pairwise distances
centroid_dists_cell = cell(num_params,1);
for ii=1:num_params
    opts = opts_vec(ii);
    lambda = opts.lambda;
    k = opts.k;
    C = build_pairwise_distance_matrix(opts.CloudDistanceType, lambda);

    centroid_dists_cell{ii} = centroid_distance_matrix(C, centroids_cell{ii}, opts_vec(ii));
end

% %% plot the centroids
% for ii=1:k
%     figure;
%     centroid_mat = reshape(centroids(ii,:), 6, 7);
%     imagesc(centroid_mat);
% end
