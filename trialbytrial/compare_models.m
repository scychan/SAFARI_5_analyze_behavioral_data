modelnames = {'Bayesian','voter','feedbackRL'};
measures = {'negloglik','AIC','BIC'};
likelihood_types = {'real','estimated'};

nmodels = length(modelnames);
nsubj = 32;
ntrials = 4*30;

resultsdir = '../results/trialbytrial';

%% load fits

[negloglik, AIC, BIC] = deal(nan(2,nmodels,nsubj));
for m = 1:nmodels
    load(sprintf('%s/fits_%s',resultsdir,modelnames{m}))
    nparams = get_nparams(modelnames{m});
     
    negloglik(:,m,:) = fits.negloglik;
    AIC(:,m,:) = fits.negloglik + nparams/2*log(ntrials);
    BIC(:,m,:) = fits.negloglik + nparams;
end

%% compare models

figure; figuresize('long')
for meas = 1:3
    measure = measures{meas};
    for k = 1:2
        numbers = eval(sprintf('squeeze(%s(k,:,:))',measure));
        bootp = nan;
%         diffs = diff(numbers);
%         bootp = compute_bootp(diffs, 'greaterthan', 0);
        
        subplot_ij(3,2,meas,k)
        barwitherrors(1:nmodels, mean(numbers,2), std(numbers,[],2)/sqrt(nsubj))
        title(sprintf('%s    %s likelihoods  p = %1.2g',...
            measure,likelihood_types{k},bootp))
        set(gca,'xticklabel',modelnames)
    end
end

%% for each model, compare using likelihood estimates vs. real likelihoods

figure
for meas = 1:3
    measure = measures{meas};
    for m = 1:nmodels
        numbers = eval(sprintf('squeeze(%s(:,m,:))',measure));
        diffs = diff(numbers);
        bootp = compute_bootp(diffs, 'greaterthan', 0);
        
        subplot_ij(3,nmodels,meas,m)
        barwitherrors([1 2], mean(numbers,2), std(numbers,[],2)/sqrt(nsubj))
        title(sprintf('%s    %s    p = %1.2g',measure,modelnames{m},bootp))
        set(gca,'xticklabel',{'real','estimates'})
    end
end

%% view parameter distributions for each model

for m = 1:nmodels
    modelname = modelnames{m};
    nparams = get_nparams(modelname);
    
    figure; figuresize('wide')
    for p = 1:nparams
        subplot(1,nparams,p)
        hist(fits.params(:,:,p)')
    end
    suptitle(modelname)
end
