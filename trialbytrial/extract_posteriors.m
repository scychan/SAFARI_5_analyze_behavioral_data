function extract_posteriors(subjnum,model,use_likelihood_estimates)
% get posteriors using the best fits for the model

str2num_set('subjnum');

initpath;
fits_dir = sprintf('../../results/trialbytrial/fits_%s',model);
posteriors_dir = fullfile('../../results/trialbytrial/posteriors',model);

%% get the best-fitting params

temp = load(sprintf('%s/estliks%i_SFR%i',fits_dir,use_likelihood_estimates,subjnum));
bestfit_params = temp.bestfit.params;

%% load up data and pchoices_fun

data = get_data(model,subjnum,use_likelihood_estimates);
pchoices_fun = get_pchoices_for_data(model,data);

%% get the posteriors

[negloglik, posteriors] = pchoices_fun(bestfit_params);
assert(negloglik == temp.bestfit.negloglik);

%% save the posteriors

mkdir_ifnotexist(posteriors_dir);
save(sprintf('%s/estliks%i_SFR%i',posteriors_dir,use_likelihood_estimates,subjnum), 'posteriors')
