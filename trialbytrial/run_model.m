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

%% load the necessary data

data = get_data(model, subjnum, use_likelihood_estimates);

%% parameter initializations + constraints

[inits, cons] = get_param_inits_cons(model,ninits);

%% which pchoices function (for computing negloglik)

pchoices_fordata = get_pchoices_for_data(model,data);

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