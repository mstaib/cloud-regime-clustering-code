function [ val, grad ] = compute_single_ot_distance_sinkhorn( C, a, b )
%COMPUTE_SINGLE_OT_DISTANCE Summary of this function goes here
%   Detailed explanation goes here

lambda = 5e1;
K = exp(-lambda*C);
[D,L,u,v] = sinkhornTransport(a(:), b(:), K, K.*C, lambda);
val = D; 

alpha = log(u);
alpha(isinf(alpha)) = 0;
grad = -alpha / lambda;
grad = grad - sum(grad) / length(grad);    

end
