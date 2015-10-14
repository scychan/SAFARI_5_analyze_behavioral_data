function run_all_subjs(modelname)

addpath(genpath('trialbytrial'))

% info
model = str2func(modelname);
nparams = get_nparams(modelname);
subjnums = setdiff(101:134,[111 128]);
nsubj = length(subjnums);
resultsdir = '../results/trialbytrial';
mkdir_ifnotexist(resultsdir)

% fit all subjects
fits.params = nan(2,nsubj,nparams);
fits.negloglik = nan(2,nsubj,1);
for k = 1:2
    use_likelihood_estimates = k-1;
    for isubj = 1:nsubj
        subjnum = subjnums(isubj);
        fprintf('SFR%i...\n',subjnum);
        
        fit = model(subjnum, use_likelihood_estimates);
        assert(length(fit.params) == nparams)
        fits.params(k,isubj,:) = fit.params;
        fits.negloglik(k,isubj) = fit.negloglik;
    end
end

% save results
save(sprintf('%s/fits_%s',resultsdir,modelname),'fits')