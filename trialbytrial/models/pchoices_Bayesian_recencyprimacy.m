%% function to get the probability of choices
function negloglik = pchoices_Bayesian_recencyprimacy(params, data, worder_recency, worder_primacy)

% get params
softmax_beta = params(1);
if isnan(worder_recency)
    w.recency = 0;
else
    w.recency = params(worder_recency);
end
if isnan(worder_primacy)
    w.primacy = 0;
else
    w.primacy = params(worder_primacy);
end

% basics
stimlist = data.stimlist.trials;
likelihoods = data.likelihoods;
nsector = 4;
episess = find(data.stimlist.phase == 4);
nsess = length(episess);
sesslen = length(stimlist.animals{end});

% get pchoices and update likelihoods for each trial
pchoices = nan(nsess, sesslen);
for s = 1:nsess
    sess = episess(s);
    for itr = 1:sesslen
        response = data.trials.b.response{sess}(itr);
        
        % get pchoices for this trial
        if ~isnan(response)
            animals = stimlist.animals{sess}{itr};
            nanimals = length(animals);
            
            qsectors = stimlist.questions_sectors{sess}(itr,:);
            qdir = stimlist.questions_biggersmaller{sess}(itr);
            if qdir == 2 % as if all questions were "which bigger"
                qsectors = fliplr(qsectors);
            end
            
            % weight the likelihoods
            weighting_recency = exp(w.recency*(1:nanimals)) / exp(w.recency);
            weighting_primacy = fliplr(exp(w.primacy*(1:nanimals))) / exp(w.primacy);
            weighting = (weighting_recency + weighting_primacy)/2;
            likelihoods_weighted = likelihoods(animals,:) .^ repmat(vert(weighting),1,nsector);
            
            % compute pchoice
            posteriors = normalize1(prod(likelihoods_weighted,1));
            posteriors = posteriors(qsectors);
            pboth = softmaxRL(posteriors, softmax_beta);
            pchoices(s,itr) = pboth(response);
        end
    end
end

% get negative log likelihood (excluding NaN choices)
negloglik = -nansum(log(pchoices(:)));