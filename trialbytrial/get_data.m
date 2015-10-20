function data = get_data(model, subjnum, use_likelihood_estimates)
% function data = get_data(model, subjnum, use_likelihood_estimates)

%% load the subject data
% t, tours, trials, stimlist, stim_to_use

% load rescored data
data = load(sprintf('../../results/rescore/subj%i',subjnum));
stimlist = data.stimlist.trials;

% basics
episess = find(data.stimlist.phase == 4);
nsess = length(episess);
sesslen = length(stimlist.animals{end});

% load likelihoods
if use_likelihood_estimates
    likelihood_estimates = load('../../results/likelihood_estimates/allsubj.mat');
    temp_isubj = (likelihood_estimates.subjnums == subjnum);
    likelihoods = likelihood_estimates.estimates{temp_isubj};
    likelihoods(likelihoods==0) = 0.01; % convert zeros to 0.01
    likelihoods = normalize1(likelihoods,'c'); % normalize
else
    likelihoods = data.stim_to_use.likelihoods;
end
[nanimal, nsector] = size(likelihoods);

%% prepare the data

switch model
    
    case {'Bayesian','logBayesian','additive'}
        
        % compute posteriors_qsectors for each trial
        posteriors_final = nan(nsess,sesslen,nsector);
        posteriors_qsectors = nan(nsess,sesslen,2);
        for s = 1:nsess
            for itr = 1:sesslen
                % compute posteriors for all sectors
                animals = stimlist.animals{episess(s)}{itr};
                switch model
                    case 'Bayesian'
                        posteriors_final(s,itr,:) = normalize1(prod(likelihoods(animals,:),1));
                    case 'additive'
                        posteriors_final(s,itr,:) = normalize1(sum(likelihoods(animals,:),1));
                    case 'logBayesian'
                        posteriors_final(s,itr,:) = log(normalize1(prod(likelihoods(animals,:),1)));
                end
                
                % compute posteriors for the two sectors for each question
                % (flip them if question is 'which smaller')
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
        
    case {'Bayesian_recencyprimacy','Bayesian_recencyprimacy_sameweight',...
            'Bayesian_recency','Bayesian_primacy'}
        
        % get likelihoods
        data.likelihoods = likelihoods;
        
    case {'feedbackRL','logfeedbackRL',...
            'feedbackRL_correctalso','feedbackRL_correctalso_1alpha',...
            'feedbackRL_nocontrib','feedbackRL_nocontrib_1alpha',...
            'feedbackRL_oppcontrib','feedbackRL_oppcontrib_1alpha',...
            'feedbackRL_1alpha','logfeedbackRL_1alpha',...
            'feedbackRL_recencyprimacy','feedbackRL_recencyprimacy_sameweight',...
            'feedbackRL_1alpha_recencyprimacy','feedbackRL_1alpha_recencyprimacy_sameweight'}
        
        % initialize likelihoods
        data.likelihoods = likelihoods;
        
    case {'mostleast_voter','mostleast2_voter',...
            'mostP_voter','most2_voter','least2_voter',...
            'mostleast_multiplier','mostleast2_multiplier',...
            'mostP_multiplier','most2_multiplier','least2_multiplier'}
        % how many to keep track of?
        if strfind(model,'2')
            nkeeptrack = 2;
        else
            nkeeptrack = 1;
        end
        
        % identify the highest and lowest probability animals in each sector
        [data.minPanimals, data.maxPanimals] = deal(cell(1,nsector));
        for isector = 1:nsector
            likelihoods_temp = likelihoods(:,isector);
            for i = 1:nkeeptrack
                sectormin = min(likelihoods_temp);
                sectormax = max(likelihoods_temp);
                likelihoods_temp = setdiff(likelihoods_temp,[sectormin sectormax]);
                
                if length(data.minPanimals{isector}) < nkeeptrack && ~isempty(sectormin)
                    data.minPanimals{isector} = [data.minPanimals{isector}
                        find(likelihoods(:,isector) == sectormin)];
                end
                if length(data.maxPanimals{isector}) < nkeeptrack && ~isempty(sectormax)
                    data.maxPanimals{isector} = [data.maxPanimals{isector}
                        find(likelihoods(:,isector) == sectormax)];
                end
            end
        end
end