modelnames = {'Bayesian'
    'logBayesian'
    'additive'
    'mostP_voter'
    'most2_voter'
    'least2_voter'
    'mostleast_voter'
    'mostleast2_voter'
    'feedbackRL'
    'logfeedbackRL'
    'feedbackRL_1alpha'
    'logfeedbackRL_1alpha'};
measures = {'negloglik','AIC','BIC'};
likelihood_types = {'real','estimated'};

nmodels = length(modelnames);
nsubj = 32;
ntrials = 4*30;

resultsdir = '../../results/trialbytrial';

%% abbreviate the model names

modelnames_abbrev = strrep(modelnames,'_voter','');

%% load fits

[negloglik, AIC, BIC] = deal(nan(2,nmodels,nsubj));
allfits = struct('params',[],'negloglik',[]);
for m = 1:nmodels
    temp = load(sprintf('%s/fits_%s/allsubj',resultsdir,modelnames{m}));
    nparams = get_nparams(modelnames{m});
    allfits(m) = temp.bestfits;
    
    negloglik(:,m,:) = allfits(m).negloglik;
    AIC(:,m,:) = allfits(m).negloglik + nparams/2*log(ntrials);
    BIC(:,m,:) = allfits(m).negloglik + nparams;
end

%% compare models

for order_models = [0 1]
    figure; figuresize('fullscreen')
    for meas = 1:3
        measure = measures{meas};
        clear means stderrs
        for k = 1:2
            numbers = eval(sprintf('squeeze(%s(k,:,:))',measure));
            means(:,k) = mean(numbers,2);
            stderrs(:,k) = std(numbers,[],2)/sqrt(nsubj);
        end
        means = means(:);
        stderrs = stderrs(:);
        if order_models
            [~,order] = sort(means);
        else
            order = 1:length(means);
        end
        
        %allmodels_abbrev = [cellfun(@(x) [x 'R'],modelnames_abbrev,'uniformoutput',0);
        %    cellfun(@(x) [x 'E'],modelnames_abbrev,'uniformoutput',0)];
        allmodels_abbrev = [modelnames_abbrev; modelnames_abbrev];
        
        subplot(3,1,meas); hold on
        % plot the R likelihoods (real)
        x = find(order <= nmodels);
        barwitherrors(x, means(order(x)), stderrs(order(x)))
        % plot the E likelihoods (estimated)
        x = find(order > nmodels);
        barwitherrors(x, means(order(x)), stderrs(order(x)),'barcolor','m','errcolor','k')
        set(gca,'xtick',1:nmodels*2,'xticklabel',allmodels_abbrev(order))
        titlebf(measure)
    end
    equalize_subplot_axes('y',gcf,3,1,[],[60 85])
    subplot(311); legend('real likelihoods','','estimated likelihoods','')
end


%% for each model, compare using likelihood estimates vs. real likelihoods

figure; figuresize('fullscreen')
for meas = 1:3
    measure = measures{meas};
    for m = 1:nmodels
        numbers = eval(sprintf('squeeze(%s(:,m,:))',measure));
        diffs = diff(numbers);
        bootp = compute_bootp(diffs, 'greaterthan', 0);
        
        subplot_ij(3,nmodels,meas,m)
        barwitherrors([1 2], mean(numbers,2), std(numbers,[],2)/sqrt(nsubj))
        titlebf(sprintf('%s    %s    p = %1.2g',modelnames_abbrev{m},measure,bootp))
        set(gca,'xticklabel',{'real','est'})
    end
end
equalize_subplot_axes('y',gcf,3,nmodels,[],[60 85])

%% view parameter distributions for each model

for m = 1:nmodels
    modelname = modelnames{m};
    nparams = get_nparams(modelname);
    
    figure; figuresize('wide')
    for p = 1:nparams
        subplot(1,nparams,p)
        hist(allfits(m).params(:,:,p)')
    end
    suptitle(modelname)
end
