function y = logistic_3param(params,x)
% function y = logistic_3param(params,x)
% 
% INPUTS:
% params(1) = K = lower asymptote (upper asymptote = 1-K)
% params(2) = a = "slope" term
% params(3) = b = "intercept" term
% x can be a vector of values

K = params(1);
a = params(2);
b = params(3);

y = K + (1-2*K)./(1+exp(-b.*(x-a)));