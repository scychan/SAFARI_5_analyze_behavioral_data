function compile_subjs(modelname,ninit)

addpath('models')
addpath('../helpers')

% info
nparams = get_nparams(modelname);
subjnums = setdiff(101:134,[111 128]);
nsubj = length(subjnums);
resultsdir = sprintf('../../results/trialbytrial/fits_%s',modelname);

% compile fits from all subjects
bestfits.params = nan(2,nsubj,nparams);
bestfits.negloglik = nan(2,nsubj);
allfits.params = nan(2,nsubj,ninit,nparams);
allfits.negloglik = nan(2,nsubj,ninit);
inits = nan(2,nsubj,ninit,nparams);
for k = 1:2
    use_likelihood_estimates = k-1;
    for isubj = 1:nsubj
        subjnum = subjnums(isubj);
        
        temp = load(sprintf('%s/estliks%i_SFR%i',resultsdir,use_likelihood_estimates,subjnum));
        assert(length(temp.bestfit.params) == nparams)
        
        bestfits.params(k,isubj,:) = temp.bestfit.params;
        bestfits.negloglik(k,isubj) = temp.bestfit.negloglik;
        assert(isreal(bestfits.negloglik));
        for i = 1:ninit
            if ~isempty(temp.allfits(i).params)
                allfits.params(k,isubj,i,:) = temp.allfits(i).params;
                allfits.negloglik(k,isubj,i,:) = temp.allfits(i).negloglik;
            end
        end
        inits(k,isubj,:,:) = temp.inits';
    end
    fprintf('best fits for k=%i: \n',k)
    fprintf('%1.3g ', bestfits.negloglik(k,:)); fprintf('\n')
end

% save results
save(sprintf('%s/allsubj',resultsdir),'bestfits','allfits','inits')