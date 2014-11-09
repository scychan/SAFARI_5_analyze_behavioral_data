function y = logistic_3param(a,b,K,x)

y = K + (1-2*K)/(1+exp(-(a+b*x)));
