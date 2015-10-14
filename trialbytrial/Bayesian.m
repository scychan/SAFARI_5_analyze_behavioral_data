function fit = Bayesian(subjnum, use_likelihood_estimates)
% selection by elimination

%% initialize path

addpath('trialbytrial')

%% load the subject data
% t, tours, trials, stimlist, stim_to_use

% load rescored data
data = load(sprintf('../results/rescore/subj%i',subjnum));
stimlist = data.stimlist.trials;

% basics
episess = find(data.stimlist.phase == 4);
nsess = length(episess);
sesslen = length(stimlist.animals{end});

% compute posteriors_final for each trial
posteriors_final = nan(nsess,sesslen,4);
if use_likelihood_estimates
    likelihood_estimates = load('../results/likelihood_estimates/allsubj.mat');
    temp_isubj = (likelihood_estimates.subjnums == subjnum);
    likelihood_estimates = likelihood_estimates.estimates{temp_isubj};
    likelihood_estimates = normalize1(likelihood_estimates,'c');
    likelihoods = likelihood_estimates;
    
    for s = 1:nsess
        for itr = 1:sesslen
            animals = stimlist.animals{episess(s)}{itr};
            posteriors_final(s,itr,:) = normalize1(prod(likelihoods(animals,:),1));
        end
    end
else
    for s = 1:nsess
        for itr = 1:sesslen
            posteriors_final(s,itr,:) = stimlist.posteriors_new{episess(s)}{itr}(end,:);
        end
    end
end

% compute posteriors for the two sectors for each question 
% (flip them if question is 'which smaller')
posteriors_qsectors = nan(nsess,sesslen,2);
for s = 1:nsess
    for itr = 1:sesslen
        qsectors = stimlist.questions_sectors{episess(s)}(itr,:);
        qdir = stimlist.questions_biggersmaller{episess(s)}(itr);
        if qdir == 2
            qsectors = fliplr(qsectors);
        end
        
        posteriors_qsectors(s,itr,:) = posteriors_final(s,itr,qsectors);
    end
end

% combine into data_final
data_final.posteriors = posteriors_qsectors;
data_final.responses = vertcat(data.trials.b.response{episess});
data = data_final;

%% initialize the fitted parameters
% - softmax beta

% keep softmax_beta
softmax_beta = 1;

% combine params
initializations = softmax_beta;

%% fit with constraints

% parameter-fitting
pchoices_fordata = @(params) pchoices_Bayesian(params, data);

options = optimoptions('fmincon','Algorithm','active-set');
[fit.params, fit.negloglik] = fmincon(pchoices_fordata, initializations, ...
    -1, 0, ...              % all params >= 0
    [],[],[],[],[],options); 
