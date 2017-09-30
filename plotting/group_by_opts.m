function [ grouped_out_structs, grouped_centroids, opts_prototypes ] = group_by_opts(out_struct_cell, centroid_cell, opts_vec)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

opts_prototypes{1} = opts_vec(1);
proto_inx(1) = 1;
for ii=2:length(opts_vec)
    matches = cellfun(@(opt) isequal(opt, opts_vec(ii)), opts_prototypes);
    if ~any(matches)
        this_proto_inx = 1 + length(opts_prototypes);
        opts_prototypes{this_proto_inx} = opts_vec(ii);
        proto_inx(ii) = this_proto_inx;
    else
        inx = find(matches);
        proto_inx(ii) = inx;
    end
end

for ii=1:length(opts_prototypes)
    grouped_out_structs{ii} = out_struct_cell(proto_inx == ii);
    grouped_centroids{ii} = centroid_cell(proto_inx == ii);
end

end

