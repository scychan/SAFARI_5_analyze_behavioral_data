function fit = logfeedbackRL(subjnum, use_likelihood_estimates)
% selection by elimination

%% load the subject data
% t, tours, trials, stimlist, stim_to_use

% load rescored data
data = load(sprintf('../results/rescore/subj%i',subjnum));

% initialize likelihoods
if use_likelihood_estimates
    likelihood_estimates = load('../results/likelihood_estimates/allsubj.mat');
    temp_isubj = (likelihood_estimates.subjnums == subjnum);
    likelihood_estimates = likelihood_estimates.estimates{temp_isubj};
    likelihood_estimates = normalize1(likelihood_estimates,'c');
    data.likelihoods = likelihood_estimates;
else 
    data.likelihoods = data.stim_to_use.likelihoods;
end

%% initialize the fitted parameters

softmax_beta = 1;
alpha.bumpup = 0.1;
alpha.bumpdown = 0.1;

% combine params
initializations = [softmax_beta, alpha.bumpup, alpha.bumpdown];

%% fit with constraints

% parameter-fitting
pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 1);

options = optimoptions('fmincon','Algorithm','active-set');
[fit.params, fit.negloglik] = fmincon(pchoices_fordata, initializations, ...
    -eye(3), zeros(3,1), ...              % all params >= 0
    [],[],[],[],[],options); 
