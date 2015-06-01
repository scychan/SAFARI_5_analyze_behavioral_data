function infer_likelihoods(subjnum)
% trial by trial model-fitting to infer subjects' likelihoods
% - no learning

%% initialize path

addpath('trialbytrial')

%% load the subject data
% t, tours, trials, stimlist, stim_to_use

% load rescored data
data = load(sprintf('../results/rescore/subj%i',subjnum));

% load likelihood estimates
likelihood_estimates = load('../results/likelihood_estimates/allsubj.mat');
temp_isubj = (likelihood_estimates.subjnums == subjnum);
likelihood_estimates = likelihood_estimates.estimates{temp_isubj};
likelihood_estimates = normalize1(likelihood_estimates,'c');

%% initialize the fitted parameters
% - likelihoods P(animal | sector) -- only the free params (each row sums to 1)
% - softmax beta

% initialize likelihoods with their post-experiment estimates
likelihoods = likelihood_estimates;
likelihoods = likelihoods(1:end-1, :); % only need the free params

% initialize softmax beta as ... XX ?
softmax_beta = 10;

% combine params
initializations = [likelihoods(:); softmax_beta];

%% fit with constraints

% set up constraints ( A*x <= b )
cons.A = [1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 
          0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0
          0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0
          0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1
          -eye(16)
          eye(16)];
cons.A = [cons.A zeros(36,1)];
cons.A = [cons.A
    zeros(1,16) -1];
cons.b = [ones(4,1)   % cols of likelihoods sum to <= 1
          zeros(16,1) % each likelihood must >= 0
          ones(16,1)  % each likelihood must <= 1
          -0.1];      % softmax beta must be >= 0.1

% parameter-fitting
pchoices_fordata = @(params) pchoices(params, data);
[fit.params fit.data_negloglik] = fmincon(pchoices_fordata, initializations, cons.A, cons.b);
fit.likelihoods = reshape(fit.params(1:16),4,4);
fit.likelihoods = [fit.likelihoods; 1 - sum(fit.likelihoods)];
fit.softmax_beta = fit.params(17);