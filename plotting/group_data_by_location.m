function [ X_grouped, lats_unique, lons_unique ] = group_data_by_location( X, lats, lons )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

lats_unique = unique(lats);
lons_unique = unique(lons);

X_grouped = cell(length(lats_unique), length(lons_unique));
for ii=1:length(lats_unique)
    for jj=1:length(lons_unique)
        X_grouped{ii,jj} = [];
    end
end

for ii=1:size(X,1)
    lats_inx = find(lats_unique == lats(ii));
    lons_inx = find(lons_unique == lons(ii));
    X_grouped{lats_inx, lons_inx} = [X_grouped{lats_inx, lons_inx}; X(ii,:)];
end

end

