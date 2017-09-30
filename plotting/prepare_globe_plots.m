%load('emd_runs_7_20_gurobionly.mat');
load('emd_runs_7_21.mat');

%% select plots
[g, c, p] = group_by_opts(out_struct_cell, centroids_cell, opts_vec);


for ii=1:length(g)
    costs = cellfun(@(z) z.estimated_costs(end), g{ii});
    [~, I] = min(costs);
    centroids_to_plot{ii} = c{ii}{I};
end

oracle = @(x,y) compute_single_ot_distance(C, x, y, OTSolver.Gurobi, opts_vec(1).p);

load('grouped_histograms_tropics.mat');

for ii=1:length(centroids_to_plot)
    relative = centroid_fractions_by_location(X_grouped, centroids_to_plot{ii}, oracle);
    save(sprintf('relative_7_22_%d.mat', ii), 'relative');
end
