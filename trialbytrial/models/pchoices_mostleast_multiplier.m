%% function to get the probability of choices
function negloglik = pchoices_mostleast_multiplier(params, data, minP_or_maxP)

% get params
if strcmp(minP_or_maxP,'minmax')
    minPweight = params(2);
    maxPweight = params(3);
elseif strcmp(minP_or_maxP,'min')
    minPweight = params(2);
elseif strcmp(minP_or_maxP,'max')
    maxPweight = params(2);
end
softmax_beta = 1; % keep this constant -- it just scales the other params

% basics
episess = find(data.stimlist.phase == 4);
stimlist = data.stimlist.trials;
sesslen = 30;
nsector = 4;

% compute p(choices)
pchoices = nan(length(episess), sesslen);
for s = 1:length(episess)
    sess = episess(s);
    for itr = 1:sesslen
        animals = stimlist.animals{sess}{itr};
        qsectors = stimlist.questions_sectors{sess}(itr,:);
        qdir = stimlist.questions_biggersmaller{sess}(itr);
        response = data.trials.b.response{sess}(itr);
        
        if ~isnan(response)
            % multiply the votes
            ballotbox = ones(1,4);
            for a = 1:length(animals)
                votes = zeros(1,nsector);
                if strfind(minP_or_maxP,'min')
                        subvotes = cellfun(@(x) ismember(animals(a),x), data.minPanimals);
                        votes(subvotes) = minPweight / sum(subvotes);
                end
                if strfind(minP_or_maxP,'max')
                    plusvotes = cellfun(@(x) ismember(animals(a),x), data.maxPanimals);
                    votes(plusvotes) = maxPweight / sum(plusvotes);
                end
                therest = (votes == 0);
                votes(therest) = (1 - sum(votes))/sum(therest);
                ballotbox = ballotbox .* votes;
            end
            
            % flip the votes if question asks for smaller probability
            if qdir == 2
                ballotbox = -ballotbox;
            end
            
            % softmax to get likelihood of choice
            pboth = softmaxRL(ballotbox(qsectors), softmax_beta);
            pchoices(s,itr) = pboth(response);
        end
    end
end

% get negative log likelihood (excluding NaN choices)
nanresponses = isnan(vertcat(data.trials.b.response{episess}));
negloglik = -sum(log(pchoices(~nanresponses)));