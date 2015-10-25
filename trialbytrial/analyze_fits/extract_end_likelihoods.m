function extract_end_likelihoods(model,use_likelihood_estimates)
% get end_likelihoods using the best fits for the model
% compare with the start_likelihoods

initpath;
fits_dir = sprintf('../../results/trialbytrial/fits_%s',model);

subjnums = get_subjnums;
nsubj = length(subjnums);

%% for each subj

[corr_init_final, corr_init_actual, corr_final_actual] = deal(nan(1,nsubj));
for isubj = 1:nsubj
    subjnum = subjnums(isubj);
    
    %% get the best-fitting params
    
    temp = load(sprintf('%s/estliks%i_SFR%i',fits_dir,use_likelihood_estimates,subjnum));
    bestfit_params = temp.bestfit.params;
    
    %% load up data and pchoices_fun
    
    data = get_data(model,subjnum,use_likelihood_estimates);
    pchoices_fun = get_pchoices_for_data(model,data);
    
    %% get the end_likelihoods
    
    [negloglik, ~, end_likelihoods] = pchoices_fun(bestfit_params);
    assert(negloglik == temp.bestfit.negloglik);
    
    %% compute correlation with the initial likelihoods + real likelihoods
    
    corr_init_final(isubj) = corr(data.likelihoods(:),end_likelihoods(:));
    corr_init_actual(isubj) = corr(data.likelihoods(:),data.stim_to_use.likelihoods(:));
    corr_final_actual(isubj) = corr(data.stim_to_use.likelihoods(:),end_likelihoods(:));

end

%% plot

allcorrs = [corr_init_final; corr_init_actual; corr_final_actual]';
means = mean(allcorrs);
stderrs = std(allcorrs)/sqrt(nsubj);

figure; hold on
barwitherrors(1:3,means,stderrs)
set(gca,'xtick',1:3,'xticklabel',{'init.final','init.actual','final.actual'})

%% save the likelihoods
% 
% mkdir_ifnotexist(posteriors_dir);
% save(sprintf('%s/estliks%i_SFR%i',posteriors_dir,use_likelihood_estimates,subjnum), 'posteriors')
