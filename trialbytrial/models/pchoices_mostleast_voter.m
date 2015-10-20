%% function to get the probability of choices
function negloglik = pchoices_mostleast_voter(params, data, minP_or_maxP)

% get params
if strcmp(minP_or_maxP,'minmax')
    minPvote = params(1);
    maxPvote = params(2);
elseif strcmp(minP_or_maxP,'min')
    minPvote = params(1);
elseif strcmp(minP_or_maxP,'max')
    maxPvote = params(1);
end
softmax_beta = 1; % keep this constant -- it just scales the other params

% basics
episess = find(data.stimlist.phase == 4);
stimlist = data.stimlist.trials;
sesslen = 30;

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
            % count up the votes
            ballotbox = zeros(1,4);
            for a = 1:length(animals)
                switch minP_or_maxP
                    case 'minmax'
                        subvotes = cellfun(@(x) ismember(animals(a),x), data.minPanimals);
                        plusvotes = cellfun(@(x) ismember(animals(a),x), data.maxPanimals);
                        ballotbox = ballotbox + maxPvote*plusvotes - minPvote*subvotes;
                    case 'min'
                        subvotes = cellfun(@(x) ismember(animals(a),x), data.minPanimals);
                        ballotbox = ballotbox - minPvote*subvotes;
                    case 'max'
                        plusvotes = cellfun(@(x) ismember(animals(a),x), data.maxPanimals);
                        ballotbox = ballotbox + maxPvote*plusvotes;
                end
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