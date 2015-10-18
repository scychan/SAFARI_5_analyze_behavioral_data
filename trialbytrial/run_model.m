function [bestfit, allfits, inits] = run_model(model, subjnum, use_likelihood_estimates, ninits, whichinit, options)
% function [bestfit, allfits] = run_model_on_subj(model, subjnum, use_likelihood_estimates, ninits, [whichinit, options])
% run desired model on an individual subject

% parse inputs
str2num_set('subjnum','use_likelihood_estimates','ninits')
if ~exist('whichinit','var')
    whichinit = 1:ninits;
elseif strcmp(whichinit,'taskID')
    whichinit = gettaskID;
end
str2num_set('whichinit')
assert(length(whichinit) == ninits || length(whichinit) == 1)

% initialize path
addpath(genpath('models'))
addpath('../helpers')

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
        
    case {'feedbackRL','logfeedbackRL','feedbackRL_1alpha','logfeedbackRL_1alpha',...
            'feedbackRL_recencyprimacy','feedbackRL_recencyprimacy_sameweight',...
            'feedbackRL_1alpha_recencyprimacy','feedbackRL_1alpha_recencyprimacy_sameweight'}
        
        % initialize likelihoods
        data.likelihoods = likelihoods;
        
    case {'mostleast_voter','mostleast2_voter',...
            'mostP_voter','most2_voter','least2_voter'}
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

%% parameter initializations + constraints

switch model
    case {'Bayesian','logBayesian','additive'}
        inits(1,:) = exp(linspace(-5,5,ninits)); % softmax beta
        cons.A = -1;
        cons.B = 0;
        
    case 'Bayesian_recencyprimacy'
        inits(1,:) = exp(linspace(-5,5,ninits)); % softmax beta
        temp = exp(linspace(-5,2,ninits));
        inits(2,:) = temp(randperm(ninits)); % w.recency
        temp = exp(linspace(-5,2,ninits));
        inits(3,:) = temp(randperm(ninits)); % w.primacy
        cons.A = [-1 0 0
                  0 -1 0
                  0 0 -1
                  0 1 0
                  0 0 1];
        cons.B = [0; 0; 0; 2; 2];
        
    case {'Bayesian_recency','Bayesian_primacy','Bayesian_recencyprimacy_sameweight'}
        inits(1,:) = exp(linspace(-5,5,ninits)); % softmax beta
        temp = exp(linspace(-5,2,ninits));
        inits(2,:) = temp(randperm(ninits)); % w.recency / w.primacy
        cons.A = [-1 0
                  0 -1
                  0 1];
        cons.B = [0; 0; 2];
        
    case {'feedbackRL','logfeedbackRL','feedbackRL_1alpha','logfeedbackRL_1alpha'}
        if strfind(model,'1alpha')
            inits(1,:) = exp(linspace(-5,5,ninits)); % softmax beta
            inits(2,:) = rand(1,ninits); % alpha
            cons.A = [-1 0
                      0  -1
                      0  1];
            cons.B = [zeros(2,1); 1];
        else
            inits(1,:) = exp(linspace(-5,5,ninits)); % softmax beta
            inits(2,:) = rand(1,ninits); % alpha.bumpup
            inits(3,:) = rand(1,ninits); % alpha.bumpdown
            cons.A = [-1 0  0
                      0  -1 0
                      0  0  -1
                      0  1  0
                      0  0  1];
            cons.B = [zeros(3,1); ones(2,1)];
        end
        
    case {'feedbackRL_recencyprimacy','feedbackRL_recencyprimacy_sameweight',...
            'feedbackRL_1alpha_recencyprimacy','feedbackRL_1alpha_recencyprimacy_sameweight'}
        clear inits cons
        inits(1,:) = exp(linspace(-5,5,ninits)); % softmax beta
        cons.A = -1;
        cons.B = 0;
        if strfind(model,'1alpha')
            inits(2,:) = rand(1,ninits); % alpha
            cons.A = [-1 0
                       0 -1
                       0 1];
            cons.B = [0; 0; 1];
        else
            inits(2,:) = rand(1,ninits); % alpha.bumpup
            inits(3,:) = rand(1,ninits); % alpha.bumpdown
            cons.A = [-1 0  0
                      0  -1 0
                      0  0  -1
                      0  1  0
                      0  0  1];
            cons.B = [zeros(3,1); ones(2,1)];
        end
        dimsA = size(cons.A);
        if strfind(model,'sameweight')
            temp = exp(linspace(-5,2,ninits));
            inits(end+1,:) = temp(randperm(ninits)); % w.recencyprimacy
            cons.A = [cons.A, zeros(dimsA(1),1);
                zeros(2, dimsA(2)), [-1; 1]];
            cons.B = [cons.B; 0; 2];
        else
            temp = exp(linspace(-5,2,ninits));
            inits(end+1,:) = temp(randperm(ninits)); % w.recency
            temp = exp(linspace(-5,2,ninits));
            inits(end+1,:) = temp(randperm(ninits)); % w.primacy
            cons.A = [cons.A, zeros(dimsA(1),2);
                zeros(2*2, dimsA(2)), [-eye(2); eye(2)]];
            cons.B = [cons.B; 0; 0; 2; 2];
        end
                
    case {'mostleast_voter','mostleast2_voter'}
        % how much to weight minP vs maxP animals
        % keep softmax_beta constant at 1 (it just scales the other two params)
        inits(1,:) = exprnd(10,ninits,1); % minPvote
        inits(2,:) = exprnd(10,ninits,1); % maxPvote
        cons.A = -eye(2);
        cons.B = zeros(2,1);
        
    case {'mostP_voter','most2_voter','least2_voter'}
        % how much to weight maxP animals
        % keep softmax_beta constant at 1 (it just scales the other two params)
        inits(1,:) = exprnd(10,ninits,1); % maxPvote / minPvote
        cons.A = -1;
        cons.B = 0;
end

%% which pchoices function (for computing negloglik)

switch model
    case {'Bayesian','logBayesian','additive'}
        pchoices_fordata = @(params) pchoices_Bayesian(params, data);
        
    case 'Bayesian_recencyprimacy'
        pchoices_fordata = @(params) pchoices_Bayesian_recencyprimacy(params, data, 2, 3);
        
    case 'Bayesian_recencyprimacy_sameweight'
        pchoices_fordata = @(params) pchoices_Bayesian_recencyprimacy(params, data, 2, 2);
        
    case 'Bayesian_recency'
        pchoices_fordata = @(params) pchoices_Bayesian_recencyprimacy(params, data, 2, nan);
        
    case 'Bayesian_primacy'
        pchoices_fordata = @(params) pchoices_Bayesian_recencyprimacy(params, data, nan, 2);
        
    case 'feedbackRL'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 0, 2, nan, nan);
        
    case 'logfeedbackRL'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 1, 2, nan, nan);
        
    case 'feedbackRL_1alpha'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 0, 1, nan, nan);
        
    case 'logfeedbackRL_1alpha'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 0, 1, nan, nan);
        
    case 'feedbackRL_recencyprimacy'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 0, 2, 4, 5);
        
    case 'feedbackRL_recencyprimacy_sameweight'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 0, 2, 4, 4);
        
    case 'feedbackRL_1alpha_recencyprimacy'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 0, 1, 3, 4);
        
    case 'feedbackRL_1alpha_recencyprimacy_sameweight'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 0, 1, 3, 3);
        
    case {'mostleast_voter','mostleast2_voter'}
        pchoices_fordata = @(params) pchoices_mostleast_voter(params, data, 'minmax');
        
    case {'mostP_voter','most2_voter'}
        pchoices_fordata = @(params) pchoices_mostleast_voter(params, data, 'max');
        
    case 'least2_voter'
        pchoices_fordata = @(params) pchoices_mostleast_voter(params, data, 'min');
end

%% fit with constraints

bestfit.negloglik = Inf;
allfits = struct;
for i = whichinit
    fprintf('iteration %i ...\n',i)
    
    % initialization
    initializations = inits(:,i);
    fprintf('    initialization = ');
    fprintf('   %1.3g ', initializations); fprintf('\n')
    
    % optimize params
    if ~exist('options','var')
        options = optimset('Algorithm','active-set','TolCon',0);
    end
    [allfits(i).params, allfits(i).negloglik] = fmincon(pchoices_fordata, initializations, ...
        cons.A, cons.B, ...              % all params >= 0
        [],[],[],[],[],options);
    fprintf('    fit = ')
    fprintf('  %1.5g ', allfits(i).params); fprintf('\n')
    fprintf('    negloglik = %1.5g \n', allfits(i).negloglik)
    
    % update bestfit
    if ~any(isnan(allfits(i).params)) && allfits(i).negloglik < bestfit.negloglik
        bestfit = allfits(i);
    end
end

%% save results

resultsdir = sprintf('../../results/trialbytrial/fits_%s',model);
mkdir_ifnotexist(resultsdir);

if length(whichinit) == ninits % save final file for all initializations
    save(sprintf('%s/estliks%i_SFR%i',resultsdir,use_likelihood_estimates,subjnum),...
        'bestfit','allfits','inits')
else % save file for individual initialization (to be compiled together later)
    save(sprintf('%s/estliks%i_SFR%i_init%i',resultsdir,use_likelihood_estimates,subjnum,whichinit),...
        'bestfit','allfits','inits')
end