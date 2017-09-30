% replace this 
load('emd_runs_7_20_gurobionly.mat');

load('all_histograms_tropics.mat');
X = X_tropics_full; clear X_tropics_full;
inx = randperm(size(X,1));
X = X(inx,:);
X = double(X); % won't scale well to the full dataset because uint8 more efficient
X = X / 255;
X_expanded = [X, 1 - sum(X, 2)];

figure;
for kk=1:length(out_struct_cell)
    if opts_vec(kk).smart_seeding == 0
        subplot(2,1,1);
        plot(out_struct_cell{kk}.estimated_costs); hold on;
    else
        subplot(2,1,2);
        plot(out_struct_cell{kk}.estimated_costs); hold on;
    end
end
% 
% cellfun(@(x) x.estimated_costs(end), out_struct_cell([opts_vec.smart_seeding] == 0));
% 
% cellfun(@(x) x.estimated_costs(end), out_struct_cell([opts_vec.smart_seeding] == 1));

C = build_pairwise_distance_matrix(opts_vec(1).CloudDistanceType, 1);
oracle = @(x,y) compute_single_ot_distance(C, x, y, OTSolver.Gurobi, opts_vec(1).p);
% cost_of_euclidean_clusters = estimate_metric_kmeans_objective(oracle, X_expanded, euclidean_centroids_cell);
% 

%% select plots
[g, c, p] = group_by_opts(out_struct_cell, centroids_cell, opts_vec);


for ii=1:length(g)
    costs = cellfun(@(z) z.estimated_costs(end), g{ii});
    [~, I] = min(costs);
    centroids_to_plot{ii} = c{ii}{I};
end

%% Weather State plots
        
for ii=2%length(centroids_to_plot)
    centroids = centroids_to_plot{ii};%centroids_cell{1+16+48};
    centroids = centroids(:, 1:42) * 255;

    [val, rfo] = estimate_metric_kmeans_objective(oracle, X_expanded, centroids, 2000);
    tcc = sum(centroids * 100/255, 2);


    %x_cutoffs = {'0.02' '1.27' '3.55' '9.38' '22.63' '60.36' '378.65'};
    x_cutoffs = {'0' '1.3' '3.6' '9.4' '23' '60' '379'};
    y_cutoffs = {'10' '180' '310' '440' '560' '680' '800' '1000'};

    num_cols = ceil(size(centroids,1) / 2);
    
    figure('Units','inches', ...
        'Position',[0 0 3.4 2.0], ...
        'PaperPositionMode', 'auto');
    set(gcf, 'Renderer', 'painters'); % so that it is vector graphics

    for kk=1:size(centroids,1)
        ws = reshape(centroids(kk,:), 6, 7)';

        subplot(2,num_cols,kk);
        subaxis(2,num_cols,kk,'PaddingBottom', 0.07);%, 'sv', 0, 'sh', 0, 'Padding', 0, 'mr', 0.0, 'ml', 0.0, 'PaddingBottom', 0.1);

            
        ax(kk) = gca;%axes;
        set(ax(kk),...
            'Units','normalized',...
            'FontUnits','points',...
            'FontWeight','normal',...
            'FontSize',4,...
            'FontName','Times');
        
        %subplot(size(centroids,1),1,kk);
        %subplot(2,num_cols,kk);
        ws_scaled = ws * 255 / max(max(centroids));
        %pcolor(ws_scaled);
        image(ws_scaled);
        %shading flat;

        %ax(kk) = gca;
        
        if kk>num_cols  || (kk == num_cols && mod(size(centroids,1),2) ~= 0)
            xlabel(ax(kk), 'Cloud Optical Thickness', ...
                'FontUnits','points',...
                'FontSize',4,...
                'FontName','Times');
        end
        
        if kk==1 || kk==1+num_cols
            ylabel(ax(kk), 'Cloud Top Pressure (mb)', ...
                'FontUnits','points',...
                'FontSize',4,...
                'FontName','Times');
        end
        this_title = sprintf('WS%d, RFO=%d%%, TCC=%d%%', kk, round(100*rfo(kk)), round(tcc(kk)));
        title(this_title, ...
            'FontUnits','points',...
            'FontWeight','normal',...
            'FontSize',4,...
            'FontName','Times');

        axis on;
        grid on;
        set(ax(kk), 'xtick', (1:7) - 0.5);
        set(ax(kk), 'ytick', (1:8) - 0.5);
        
        if kk > num_cols || (kk == num_cols && mod(size(centroids,1),2) ~= 0)
            set(ax(kk), 'xticklabel', x_cutoffs,  ...
                'FontUnits','points',...
                'FontSize',4,...
                'FontName','Times');
        else
            set(ax(kk), 'xticklabel', cell(0));
        end
        
        if kk==1 || kk==1+num_cols
            set(ax(kk), 'yticklabel', y_cutoffs, ...
                'FontUnits','points',...
                'FontSize',4,...
                'FontName','Times');
        else
            set(ax(kk), 'yticklabel', cell(0));
        end
        
%        set(subplot(2,num_cols,kk,ax(kk)));

    end
    
    ticks = 0:5:max(max(centroids));
    tick_labels = cellfun(@num2str, num2cell(ticks), 'uniformoutput',false);
    
    rescaled_ticks = 255/max(ticks) * ticks + 1;
    h = colorbar('SouthOutside', 'XTick', rescaled_ticks, ...
        'XTickLabel', tick_labels);%0:5:max(max(centroids)));
    set(h, 'Position', [.1 .05 .8150 .05]);
%     for kk=1:size(centroids,1)
%         pos=get(ax(kk), 'Position');
%         set(ax(kk), 'Position', [pos(1) 0.1+pos(2) pos(3) 0.8*pos(4)]);
%     end
    
    myColorMap = parula(255); % Make a copy of jet.
    % Assign white (all 1's) to black (the first row in myColorMap).
    myColorMap(1, :) = [1 1 1];
    colormap(myColorMap); % Apply the colormap
    
    for kk=(num_cols+1):size(centroids,1)
        hp = get(ax(kk), 'Position');
        hp(2) = 0.22;
        set(ax(kk), 'Position', hp);
    end
    
    print(gcf, '-dpdf','weather-states.pdf');
end

%% distances between centroids
centroid_dists_cell = cell(length(centroids_to_plot), 1);
for ii=1:length(centroids_to_plot)
    opts = p{ii};
    lambda = opts.lambda;
    k = opts.k;
    C = build_pairwise_distance_matrix(opts.CloudDistanceType, lambda);

    centroid_dists_cell{ii} = centroid_distance_matrix(C, centroids_to_plot{ii}, opts);
end

min_between_cluster_distance = zeros(length(centroid_dists_cell),1);
for ii=1:length(centroid_dists_cell)
    dists = centroid_dists_cell{ii};
    min_between_cluster_distance(ii) = min(min(dists(dists ~= 0)));
end

%% heatmap of cluster frequency

figure('Units','inches', ...
    'Position',[0 0 3.4 1.0], ...
    'PaperPositionMode', 'auto');
set(gcf, 'Renderer', 'painters'); % so that it is vector graphics

ax = worldmap([-15 15], [0 360]);
setm(ax, 'mlabelparallel', -15);
setm(ax, 'MLabelLocation', 0:60:360)

load geoid;
geoshow(geoid, geoidrefvec, 'DisplayType', 'texturemap'); hold on;

load coastlines;
[latcells, loncells] = polysplit(coastlat, coastlon);
h = plotm(coastlat, coastlon, 'Color', 'black');

% load topo
% R = georasterref('RasterSize', size(topo), ...
% 'LatitudeLimits', [-15 15], 'LongitudeLimits', [0 360], 'RasterSize', [30 360]);
% grid2image(topo(75:104,:), R);
