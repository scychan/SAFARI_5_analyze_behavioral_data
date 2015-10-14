%% function to get the probability of choices
function negloglik = pchoices_voter(params, data)

% get params
minPvote = params(1);
maxPvote = params(2);
softmax_beta = 1; % keep this constant -- it just scales the other two

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
                subvotes = cellfun(@(x) ismember(animals(a),x), data.minPanimals);
                plusvotes = cellfun(@(x) ismember(animals(a),x), data.maxPanimals);
                ballotbox = ballotbox + maxPvote*plusvotes - minPvote*subvotes;
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
negloglik = -nansum(log(pchoices(:)));