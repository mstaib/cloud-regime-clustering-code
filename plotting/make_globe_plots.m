%% actually make the plots (heatmap of cluster frequency)
valid_inx = ~cellfun(@isempty, X_grouped);
[lons, lats] = meshgrid(double(lons_unique), double(lats_unique));
valid_lons = lons(valid_inx);
valid_lats = lats(valid_inx);

scale = 2;
%'Position',scale*[0 0 3.4 3.4], ... %for k=8
figure('Units','inches', ...
    'Position',scale*[0 0 3.4 2.2], ... %for k=5, 2.6 for k=6
    'PaperPositionMode', 'auto');
set(gcf, 'Renderer', 'painters'); % so that it is vector graphics
set(0, 'defaultaxeslooseinset', [0 0 0 0])

for kk=1:length(relative)
    %subplot(length(relative), 1, kk);
    subaxis(length(relative), 1, kk, 'sv', 0, 'sh', 0, 'Padding', 0, 'mr', 0.0, 'ml', 0.0, 'PaddingBottom', 0.0, 'PaddingRight', 0.1, 'PaddingLeft', 0.02);
    
    freqs = relative{kk};
    valid_freqs = freqs(valid_inx);
    SI = scatteredInterpolant(valid_lons, valid_lats, valid_freqs, 'natural', 'linear');
    
    glon = double(linspace(min(lons_unique), max(lons_unique), 2*140));
    glat = double(linspace(min(lats_unique), max(lats_unique), 2*length(lats_unique)));

    ax = worldmap([-15 15], [0 360]);
    
    setm(ax,...
            'FontUnits','points',...
            'FontWeight','normal',...
            'FontSize',scale*6,...
            'FontName','Times');
    setm(ax, 'mlabelparallel', -15);
    setm(ax, 'MLabelLocation', 0:60:360);
    if kk ~= length(relative)
        mlabel('off');
    end
    setm(ax, 'ParallelLabel', 'off');

    load geoid;
    %geoshow(geoid, geoidrefvec, 'DisplayType', 'texturemap'); hold on;
    %surfm(1:10, 1:10, 3*ones(1,10));
    %surfm(valid_lats, valid_lons, valid_freqs);
    [gx, gy] = meshgrid(glon, glat);
    gridded = SI(gx,gy);
    surfm(glat - 90, glon, 255*max(0, gridded));
    
    set_my_colormap;

    load coastlines;
    [latcells, loncells] = polysplit(coastlat, coastlon);
    h = plotm(coastlat, coastlon, 'Color', 'black');

    %axis tight;
end

hp_bottom = [0.1300    0.1100    0.7750    0.0760];
hp_top = [0.1300    0.8490    0.7750    0.0760];

ticks = 0:20:100;%*max(max(gridded));
tick_labels = cellfun(@num2str, num2cell(ticks), 'uniformoutput',false);
    
rescaled_ticks = 256/max(ticks) * ticks;
caxis([0 256])
colorbar('Position', [hp_bottom(1)+hp_bottom(3)+0.01, hp_bottom(2)+0.004, 0.03, hp_top(2)+hp_top(4)-hp_bottom(2)-0.045], ...
    'XTick', rescaled_ticks, ...
    'XTickLabel', tick_labels);

print(gcf, '-depsc','weather-state-frequencies.eps');