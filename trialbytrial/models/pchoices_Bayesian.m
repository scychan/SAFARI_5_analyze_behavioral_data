%% function to get the probability of choices
function negloglik = pchoices_Bayesian(params, data)

% get params
softmax_beta = params(1);

% basics
[nsess, sesslen] = size(data.responses);

% compute p(choices)
pchoices = nan(nsess, sesslen);
for s = 1:nsess
    for itr = 1:sesslen
        posteriors = squeeze(data.posteriors(s,itr,:));
        response = data.responses(s,itr);
        
        if ~isnan(response)
            % softmax to get likelihood of choice
            pboth = softmaxRL(posteriors, softmax_beta);
            pchoices(s,itr) = pboth(response);
        end
    end
end

% get negative log likelihood (excluding NaN choices)
nanresponses = isnan(data.responses);
negloglik = -sum(log(pchoices(~nanresponses)));