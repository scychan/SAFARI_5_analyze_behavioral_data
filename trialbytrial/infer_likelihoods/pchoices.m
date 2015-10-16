%% function to get the probability of choices
function negloglik = pchoices(params, data)

% get params
softmax_beta = params(17);
likelihoods = reshape(params(1:16),4,4);
likelihoods = [likelihoods; 1 - sum(likelihoods)];

% collapse all sessions of interest
episess = 10:13;
animals = [data.stimlist.trials.animals{episess}];
questions_sectors = vertcat(data.stimlist.trials.questions_sectors{episess});
choices = [data.trials.b.response{episess}];
ntrials = length(animals);

% get p(choices) for each trial
choice_probabilities = nan(1,ntrials);
for t = 1:ntrials
    % compute final posterior at the end of the trial, given likelihoods
    trial_len = length(animals{t});
    unnormalized = cumprod(likelihoods(animals{t},:),1);
    posteriors = normalize1(unnormalized,'r');
    final_posterior = posteriors(trial_len,:);
    
    % get the posterior for the two question options
    options_posteriors = final_posterior(questions_sectors(t,:));
    
    % get probability of each option, given softmax beta
    poptions = softmaxRL(options_posteriors, softmax_beta);
    
    % get probability of chosen option
    if ~isnan(choices(t))
        choice_probabilities(t) = poptions(choices(t));
    end
end

% get negative log likelihood (excluding NaN choices)
nanchoices = isnan(choices);
negloglik = -sum(log(choice_probabilities(~nanchoices)));