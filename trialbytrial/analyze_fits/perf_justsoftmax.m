% Compute the performance that would be expected for a fully Bayesian
% model, using min/max/mean softmax parameters

%% setup

% path
initpath;

% subjnums
subjnums = get_subjnums;
nsubj = length(subjnums);

% use estimated (not actual) likelihoods, since that gave better fits
estliks = 1; 

% expt params
nsess = 4;
sesslen = 30;

%% load fitted softmax betas
% for every subject

fits_dir = '../../results/trialbytrial/fits_Bayesian';

betas = nan(1,nsubj);
for isubj = 1:nsubj
    subjnum = subjnums(isubj);
    
    temp = load(sprintf('%s/estliks%i_SFR%i',fits_dir,estliks,subjnum));
    betas(isubj) = temp.bestfit.params;
end

%% compute mean accuracy given the fitted softmax betas

pcorrect = nan(nsubj,nsess,sesslen);
for isubj = 1:nsubj
    subjnum = subjnums(isubj);
    subjbeta = betas(isubj);
    
    data = get_data('Bayesian',subjnum,estliks);
    posteriors_qsectors = data.posteriors;
    
    for isess = 1:nsess
        for t = 1:sesslen
            posteriors = squeeze(posteriors_qsectors(isess,t,:));
            pboth = softmaxRL(posteriors, subjbeta);
            pcorrect(isubj,isess,t) = max(pboth);
        end
    end
end

%% average within and across subjects

subjmeans = squeeze(mean(mean(pcorrect,1),2));

stats.mean = mean(subjmeans);
stats.stderr = std(subjmeans)/sqrt(nsubj);

disp(stats)

