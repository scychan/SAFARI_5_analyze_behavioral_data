function run_all_subjs(modelname,ninit)
str2num_set('ninit')

addpath('models')
addpath('../helpers')

% info
nparams = get_nparams(modelname);
subjnums = setdiff(101:134,[111 128]);
nsubj = length(subjnums);
resultsdir = '../../results/trialbytrial';
mkdir_ifnotexist(resultsdir)

% fit all subjects
bestfits.params = nan(2,nsubj,nparams);
bestfits.negloglik = nan(2,nsubj);
allfits.params = nan(2,nsubj,ninit,nparams);
allfits.negloglik = nan(2,nsubj,ninit);
inits = nan(2,nsubj,ninit,nparams);
for k = 1:2
    use_likelihood_estimates = k-1;
    for isubj = 1:nsubj
        subjnum = subjnums(isubj);
        fprintf('SFR%i...\n',subjnum);
        
        [temp.bestfit, temp.allfits, temp.inits] = run_model(modelname, subjnum, use_likelihood_estimates, ninit);
        assert(length(temp.bestfit.params) == nparams)
        
        bestfits.params(k,isubj,:) = temp.bestfit.params;
        bestfits.negloglik(k,isubj) = temp.bestfit.negloglik;
        for i = 1:ninit
            allfits.params(k,isubj,i,:) = temp.allfits(i).params;
            allfits.negloglik(k,isubj,i,:) = temp.allfits(i).negloglik;
        end
        inits(k,isubj,:,:) = temp.inits';
    end
end

% save results
save(sprintf('%s/fits_%s',resultsdir,modelname),'bestfits','allfits','inits')