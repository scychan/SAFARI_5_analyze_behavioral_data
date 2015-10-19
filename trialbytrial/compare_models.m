modelnames = {'Bayesian'
    'logBayesian'
    'additive'
    'Bayesian_recencyprimacy'
    'Bayesian_recencyprimacy_sameweight'
    'Bayesian_recency'
    'Bayesian_primacy'
    'mostP_voter'
    'most2_voter'
    'least2_voter'
    'mostleast_voter'
    'mostleast2_voter'
    'feedbackRL'
%     'logfeedbackRL'
    'feedbackRL_1alpha'
%     'logfeedbackRL_1alpha'
    'feedbackRL_1alpha_recencyprimacy_sameweight'
    'feedbackRL_1alpha_recencyprimacy'
    'feedbackRL_recencyprimacy_sameweight'
    };
measures = {'geomavglik','AIC','BIC'};
likelihood_types = {'real','estimated'};
ylims = [10 85];

nmodels = length(modelnames);
nsubj = 32;
ntrials = 4*30;

resultsdir = '../../results/trialbytrial';

%% abbreviate the model names

modelnames_abbrev = modelnames;
modelnames_abbrev = strrep(modelnames_abbrev,'_voter','');
modelnames_abbrev = strrep(modelnames_abbrev,'_1alpha','1');
modelnames_abbrev = strrep(modelnames_abbrev,'Bayesian','B');
modelnames_abbrev = strrep(modelnames_abbrev,'recency','r');
modelnames_abbrev = strrep(modelnames_abbrev,'primacy','p');
modelnames_abbrev = strrep(modelnames_abbrev,'sameweight','1');
modelnames_abbrev = strrep(modelnames_abbrev,'feedback','fb');
modelnames_abbrev = strrep(modelnames_abbrev,'_','');

%% load fits

[negloglik, AIC, BIC] = deal(nan(2,nmodels,nsubj));
allfits = struct('params',[],'negloglik',[]);
for m = 1:nmodels
    temp = load(sprintf('%s/fits_%s/allsubj',resultsdir,modelnames{m}));
    nparams = get_nparams(modelnames{m});
    allfits(m) = temp.bestfits;
    
    negloglik(:,m,:) = allfits(m).negloglik;
    geomavglik(:,m,:) = exp(-allfits(m).negloglik/ntrials);
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
            if strcmp(measure,'geomavglik')
                order = flipud(order);
            end
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
        set(gca,'xlim',[0 nmodels*2+1],...
            'xtick',1:nmodels*2,'xticklabel',allmodels_abbrev(order))
        if strcmp(measure,'geomavglik')
            set(gca,'ylim',[0 1])
        else
            set(gca,'ylim',ylims)
        end
        titlebf(measure)
    end
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
equalize_subplot_axes('y',gcf,3,nmodels,[],ylims)

%% view parameter distributions for each model

for m = 1:nmodels
    modelname = modelnames{m};
    nparams = get_nparams(modelname);
    
    figure; figuresize('wide')
    for p = 1:nparams
        subplot(1,nparams,p)
        hist(allfits(m).params(:,:,p)')
    end
    suptitle(strrep(modelname,'_','.'))
end

%% recency primacy model -- 

% are recency/primacy weightings correlated?
m = find(strcmp(modelnames,'Bayesian_recencyprimacy'));
figure
for k = 1:2
    subplot(1,2,k); hold on
    x = vert(allfits(m).params(k,:,2));
    y = vert(allfits(m).params(k,:,3));
    scatter(x,y)
    plotregression(x,y,1);
    [rho, p] = corr(x,y);
    xlabel('recency weight')
    ylabel('primacy weight')
    title(sprintf('estliks %i    rho = %1.2g   p = %1.2g',k-1,rho,p))
end

% modelfit vs. recency/primacy weighting?
figure
for k = 1:2
    subplot(1,2,k); hold on
    m = find(strcmp(modelnames,'Bayesian_recencyprimacy_sameweight'));
    x = vert(allfits(m).params(k,:,2));
    y = vert(allfits(m).negloglik(k,:));
    scatter(x,y)
    plotregression(x,y,1);
    [rho, p] = corr(x,y);
    xlabel('recency/primacy weight')
    ylabel('negloglik')
    title(sprintf('estliks %i    rho = %1.2g   p = %1.2g',k-1,rho,p))
end

%% for feedback models, stats about learning from feedback

% which models
feedback_models = horz(find(cellfun(@(x) ~isempty(strfind(x,'feedbackRL')), modelnames)));

% proportion of fits with learning rate = 0
for m = feedback_models
    model = modelnames{m};
    nparams = get_nparams(model);
    
    figure
    [mean0, meanfit] = deal(nan(2,nparams-1));
    for k = 1:2
        for p = 2:nparams
            mean0(k,p-1) = mean(allfits(m).params(k,:,p) == 0);
            meanfit(k,p-1) = mean(allfits(m).params(k,:,p));
        end
        
        subplot_ij(2,2,k,1)
        bar(mean0(k,:))
        xlabel('alpha param')
        title(sprintf('mean # subjects with 0 fit -- estliks %i',k-1))
        
        subplot_ij(2,2,k,2)
        bar(meanfit(k,:))
        xlabel('alpha param')
        title(sprintf('mean fit -- estliks %i',k-1))
    end
    suptitle(model)
end

% show that these correlate with the performance changes we saw? XX
