%% function to get the probability of choices
function negloglik = pchoices_feedbackRL(params, data, take_log, nalpha)

% get params
softmax_beta = params(1);
switch nalpha
    case 1
        alpha.bumpup = params(2);
        alpha.bumpdown = params(2);
    case 2
        alpha.bumpup = params(2);
        alpha.bumpdown = params(3);
end

% basics
stimlist = data.stimlist.trials;
likelihoods = data.likelihoods;
episess = find(data.stimlist.phase == 4);
nsess = length(episess);
sesslen = length(stimlist.animals{end});

% get pchoices and update likelihoods for each trial
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
        
        % get pchoices for this trial
        if ~isnan(response)
            posteriors = normalize1(prod(likelihoods(animals,:),1));
            posteriors = posteriors(qsectors);
            if take_log
                posteriors = log(posteriors);
            end
            pboth = softmaxRL(posteriors, softmax_beta);
            pchoices(s,itr) = pboth(response);
        end
        
        % update likelihoods for each animal that apppeared, if feedback was "wrong"
        if response ~= answer
            for a = 1:5
                nappearances = sum(animals==a);
                if nappearances > 0
                    % posterior given the appearances of this animal
                    posterior_given_a = normalize1(likelihoods(a,:).^nappearances);
                    if take_log
                        posterior_given_a = log(posterior_given_a);
                    end
                    posteriordiff = abs(diff(posterior_given_a(qsectors))); 
                    
                    % bump up/down likelihoods, scaled by posteriordiff
                    likelihoods(a,shouldbe_bigger) = ...
                        bump_up(posteriordiff * alpha.bumpup, likelihoods(a,shouldbe_bigger));
                    likelihoods(a,shouldbe_smaller) = ...
                        bump_down(posteriordiff * alpha.bumpdown, likelihoods(a,shouldbe_smaller));
                    likelihoods(a,:) = normalize1(likelihoods(a,:));
                end
            end
        end
    end
end

% get negative log likelihood (excluding NaN choices)
negloglik = -nansum(log(pchoices(:)));