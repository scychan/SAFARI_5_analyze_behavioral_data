function find_empty(modelname,ninit)

% info
initpath
subjnums = get_subjnums;
nsubj = length(subjnums);
resultsdir = sprintf('../../results/trialbytrial/fits_%s',modelname);

% find the k+subj that are missing
for k = 1:2
    use_likelihood_estimates = k-1;
    
    missing_subj = [];
    for isubj = 1:nsubj
        subjnum = subjnums(isubj);
        
        filename = sprintf('%s/estliks%i_SFR%i',resultsdir,use_likelihood_estimates,subjnum);
        temp = load(filename);
        if temp.bestfit.negloglik == Inf || ~isfield(temp.bestfit,'params')
%             fprintf('%s \n',filename)
            missing_subj = [missing_subj subjnum];
        end
    end
    
    % print the required bash command
    if ~isempty(missing_subj)
        fprintf('bash run_all_subjs.sh %s %i ''',modelname,ninit)
        fprintf('%i ',missing_subj)
        fprintf(''' %i \n',use_likelihood_estimates)
    end
end