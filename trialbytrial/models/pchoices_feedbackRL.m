%% function to get the probability of choices
function [negloglik, all_posteriors] = pchoices_feedbackRL(params, data, take_log, nalpha, wind_recency, wind_primacy)

% need to save posteriors?
if nargout == 2
    save_posteriors = 1;
else
    save_posteriors = 0;
end

%% get params

% softmax param
softmax_beta = params(1);

% alpha params
switch nalpha
    case 1
        alpha.bumpup = params(2);
        alpha.bumpdown = params(2);
    case 2
        alpha.bumpup = params(2);
        alpha.bumpdown = params(3);
end

% recency/primacy params
if isnan(wind_recency)
    w.recency = 0;
else
    w.recency = params(wind_recency);
end
if isnan(wind_primacy)
    w.primacy = 0;
else
    w.primacy = params(wind_primacy);
end

%% basics

stimlist = data.stimlist.trials;
likelihoods = data.likelihoods;
episess = find(data.stimlist.phase == 4);
nsess = length(episess);
sesslen = length(stimlist.animals{end});
nsector = 4;

%% get pchoices and update likelihoods for each trial

if save_posteriors
    all_posteriors = nan(nsess,sesslen,nsector);
end

pchoices = nan(nsess, sesslen);
for s = 1:nsess
    sess = episess(s);
    for itr = 1:sesslen
        animals = stimlist.animals{sess}{itr};
        qsectors = stimlist.questions_sectors{sess}(itr,:);
        qdir = stimlist.questions_biggersmaller{sess}(itr);
        if qdir == 2 % as if all questions were "which bigger"
            qsectors = fliplr(qsectors);
        end
        response = data.trials.b.response{sess}(itr);
        answer = stimlist.answers_old{sess}(itr);
        shouldbe_bigger = qsectors(answer);
        shouldbe_smaller = qsectors(setdiff([1 2],answer));
        
        % weight the likelihoods
        if w.recency ~=0 || w.primacy ~=0
            nanimals = length(animals);
            weighting_recency = (1:nanimals).^w.recency;
            weighting_primacy = fliplr(1:nanimals).^w.primacy;
            weighting = (weighting_recency + weighting_primacy)/2;
            likelihoods_weighted = likelihoods(animals,:) .^ repmat(vert(weighting),1,nsector);
        else
            likelihoods_weighted = likelihoods(animals,:);
        end
        
        % compute pchoice
        posteriors = normalize1(prod(likelihoods_weighted,1));
        if take_log
            posteriors = log(posteriors);
        end
        if save_posteriors
            all_posteriors(s,itr,:) = posteriors;
        end
        posteriors = posteriors(qsectors);
        pboth = softmaxRL(posteriors, softmax_beta);
        if ~isnan(response)
            pchoices(s,itr) = pboth(response);
        end
        
        % update likelihoods for each animal that apppeared, if feedback was "wrong"
        if response ~= answer
            for a = 1:5
                nappearances = sum(animals==a);
                if nappearances > 0
                    % posterior given the appearances of this animal
                    if w.recency ~=0 || w.primacy ~=0
                        posterior_given_a = normalize1(likelihoods(a,:).^sum(weighting(animals==a)));
                    else
                        posterior_given_a = normalize1(likelihoods(a,:).^nappearances);
                    end
                    if take_log
                        posterior_given_a = log(posterior_given_a);
                    end
                    posteriordiff = abs(diff(posterior_given_a(qsectors)));
                    
                    % bump up/down likelihoods, scaled by posteriordiff
                    likelihoods(a,shouldbe_bigger) = ...
                        bump_up(posteriordiff * alpha.bumpup, likelihoods(a,shouldbe_bigger));
                    likelihoods(a,shouldbe_smaller) = ...
                        bump_down(posteriordiff * alpha.bumpdown, likelihoods(a,shouldbe_smaller));
                end
            end
            likelihoods = normalize1(likelihoods,'c');
        end
    end
end

%% get negative log likelihood (excluding NaN choices)

nanresponses = isnan(vertcat(data.trials.b.response{episess}));
negloglik = -nansum(log(pchoices(~nanresponses)));