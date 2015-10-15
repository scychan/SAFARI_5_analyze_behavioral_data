function [bestfit, allfits, inits] = run_model(model, subjnum, use_likelihood_estimates, ninits)
% function [bestfit, allfits] = run_model_on_subj(model, subjnum, use_likelihood_estimates, ninits)
% run desired model on an individual subject
str2num_set('subjnum','use_likelihood_estimates','ninits')

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
    likelihood_estimates = likelihood_estimates.estimates{temp_isubj};
    likelihood_estimates = normalize1(likelihood_estimates,'c');
    likelihoods = likelihood_estimates;
else
    likelihoods = data.stim_to_use.likelihoods;
end

%% prepare the data

switch model
    
    case {'Bayesian','logBayesian','additive'}
        
        % compute posteriors_qsectors for each trial
        posteriors_final = nan(nsess,sesslen,4);
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
        
    case {'feedbackRL','logfeedbackRL'}
        
        % initialize likelihoods
        data.likelihoods = likelihoods;
        
    case 'mostleast_voter'
        
        % identify the highest and lowest probability animals in each sector
        mins = min(likelihoods,[],1);
        maxs = max(likelihoods,[],1);
        for isector = 1:4
            data.minPanimals{isector} = find(likelihoods(:,isector) == mins(isector));
            data.maxPanimals{isector} = find(likelihoods(:,isector) == maxs(isector));
        end
end

%% parameter initializations + constraints

switch model
    case {'Bayesian','logBayesian','additive'}
        inits(1,:) = exp(linspace(-5,5,ninits)); % softmax beta
        cons.A = -1;
        cons.B = 0;
        
    case {'feedbackRL','logfeedbackRL'}
        inits(1,:) = exp(linspace(-5,5,ninits)); % softmax beta
        inits(2,:) = exprnd(1,ninits,1); % alpha.bumpup
        inits(3,:) = exprnd(1,ninits,1); % alpha.bumpdown
        cons.A = -eye(3);
        cons.B = zeros(3,1);
        
    case 'mostleast_voter'
        % how much to weight minP vs maxP animals
        % keep softmax_beta constant at 1 (it just scales the other two params)
        inits(1,:) = exprnd(10,ninits,1); % minPvote
        inits(2,:) = exprnd(10,ninits,1); % maxPvote
        cons.A = -eye(2);
        cons.B = zeros(2,1);
end

%% which pchoices function (for computing negloglik)

switch model
    case {'Bayesian','logBayesian','additive'}
        pchoices_fordata = @(params) pchoices_Bayesian(params, data);
        
    case 'feedbackRL'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 0);
        
    case 'logfeedbackRL'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 1);
        
    case 'mostleast_voter'
        pchoices_fordata = @(params) pchoices_mostleast_voter(params, data);
end

%% fit with constraints

bestfit.negloglik = Inf;
allfits = struct;
for i = 1:ninits
    fprintf('iteration %i ...\n',i)
    
    % initialization
    initializations = inits(:,i);
    fprintf('    initialization = ');
    fprintf('   %1.3g ', initializations); fprintf('\n')
    
    % optimize params
    options = optimset('Algorithm','active-set');
    [allfits(i).params, allfits(i).negloglik] = fmincon(pchoices_fordata, initializations, ...
        cons.A, cons.B, ...              % all params >= 0
        [],[],[],[],[],options);
    fprintf('    fit = ')
    fprintf('  %1.5g ', allfits(i).params); fprintf('\n')
    fprintf('    negloglik = %1.5g \n', allfits(i).negloglik)
    
    % update bestfit
    if ~isnan(allfits(i).params) & allfits(i).negloglik < bestfit.negloglik
        bestfit = allfits(i);
    end
end

%% save results
resultsdir = sprintf('../../results/trialbytrial/fits_%s',model);
mkdir_ifnotexist(resultsdir);
save(sprintf('%s/estliks%i_SFR%i',resultsdir,use_likelihood_estimates,subjnum),...
     'bestfit','allfits','inits')