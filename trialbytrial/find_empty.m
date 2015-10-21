function find_empty(modelname)

% info
initpath
subjnums = get_subjnums;
nsubj = length(subjnums);
resultsdir = sprintf('../../results/trialbytrial/fits_%s',modelname);

% compile fits from all subjects
for k = 1:2
    use_likelihood_estimates = k-1;
    for isubj = 1:nsubj
        subjnum = subjnums(isubj);
        
        filename = sprintf('%s/estliks%i_SFR%i',resultsdir,use_likelihood_estimates,subjnum);
        temp = load(filename);
        if temp.bestfit.negloglik == Inf || ~isfield(temp.bestfit,'params')
            fprintf('%s \n',filename)
        end
    end
end