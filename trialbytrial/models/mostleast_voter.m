function fit = mostleast_voter(subjnum, use_likelihood_estimates)

%% load the subject data
% t, tours, trials, stimlist, stim_to_use

% load rescored data
data = load(sprintf('../results/rescore/subj%i',subjnum));

% load likelihood estimates
likelihood_estimates = load('../results/likelihood_estimates/allsubj.mat');
temp_isubj = (likelihood_estimates.subjnums == subjnum);
likelihood_estimates = likelihood_estimates.estimates{temp_isubj};
likelihood_estimates = normalize1(likelihood_estimates,'c');

%% identify the highest and lowest probability animals in each sector

if use_likelihood_estimates
    likelihoods = likelihood_estimates;
else
    likelihoods = data.stim_to_use.likelihoods;
end

mins = min(likelihoods);
maxs = max(likelihoods);
for isector = 1:4
    data.minPanimals{isector} = find(likelihoods(:,isector) == mins(isector));
    data.maxPanimals{isector} = find(likelihoods(:,isector) == maxs(isector));
end

%% initialize the fitted parameters
% - how many high-P animals per sector
% - how many low-P animals per sector

% how much to weight minP vs maxP animals
minPvote = 10;
maxPvote = 10;

% keep softmax_beta constant at 1 (it just scales the other two params)

% combine params
initializations = [minPvote, maxPvote];

%% fit with constraints

% parameter-fitting
pchoices_fordata = @(params) pchoices_voter(params, data);

options = optimoptions('fmincon','Algorithm','active-set');
[fit.params, fit.negloglik] = fmincon(pchoices_fordata, initializations, ...
    -eye(2), zeros(1,2), ...
    [],[],[],[],[],options); % all params >= 0
