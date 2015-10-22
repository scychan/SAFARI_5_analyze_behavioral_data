modelnames = {
    'Bayesian'
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
    'mostleast_multiplier'
    'mostP_multiplier'
    'most2_multiplier'
    'least2_multiplier'

    'feedbackRL'
    'feedbackRL_1alpha'
    'oldfeedbackRL'
    'oldfeedbackRL_1alpha'
    'feedbackRL_correctalso'
    'feedbackRL_correctalso_1alpha'

    'logfeedbackRL'
    'logfeedbackRL_1alpha'

    'feedbackRL_nocontrib'
    'feedbackRL_nocontrib_1alpha'
    'feedbackRL_oppcontrib'
    'feedbackRL_oppcontrib_1alpha'

    'feedbackRL_correctalso_nocontrib'
    'feedbackRL_correctalso_nocontrib_1alpha'
    'feedbackRL_correctalso_oppcontrib'
    'feedbackRL_correctalso_oppcontrib_1alpha'

    'feedbackRL_recencyprimacy_sameweight'
    'feedbackRL_1alpha_recencyprimacy_sameweight'
    'feedbackRL_recencyprimacy'
    'feedbackRL_1alpha_recencyprimacy'
    
    'feedbackRL_correctalso_1alpha_recencyprimacy'
    'feedbackRL_correctalso_1alpha_recencyprimacy_sameweight'
    'feedbackRL_correctalso_recencyprimacy'
    'feedbackRL_correctalso_recencyprimacy_sameweight'
    
    'backwards_feedbackRL_correctalso_nocontrib'
    'backwards_feedbackRL_1alpha_correctalso_nocontrib'
    };
measures = {'geomavglik','AIC','BIC'};
likelihood_types = {'real','estimated'};
ylims = [60 85];
ylims_geomavglik = [0.5 0.6];

initpath
nmodels = length(modelnames);
subjnums = get_subjnums;
nsubj = length(subjnums);
ntrials = get_ntrials('all');

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
modelnames_abbrev = strrep(modelnames_abbrev,'correctalso','c');
modelnames_abbrev = strrep(modelnames_abbrev,'nocontrib','no');
modelnames_abbrev = strrep(modelnames_abbrev,'oppcontrib','opp');
modelnames_abbrev = strrep(modelnames_abbrev,'multiplier','mult');
modelnames_abbrev = strrep(modelnames_abbrev,'most','m');
modelnames_abbrev = strrep(modelnames_abbrev,'least','l');
modelnames_abbrev = strrep(modelnames_abbrev,'_','');

% print key
for m = 1:nmodels
    fprintf('%s \t - %s \n',modelnames_abbrev{m},modelnames{m});
end


%% load fits

[negloglik, geomavglik, AIC, BIC] = deal(nan(2,nmodels,nsubj));
allfits = struct('params',[],'negloglik',[]);
for m = 1:nmodels
    temp = load(sprintf('%s/fits_%s/allsubj',resultsdir,modelnames{m}));
    nparams = get_nparams(modelnames{m});
    allfits(m) = temp.bestfits;
    
    negloglik(:,m,:) = allfits(m).negloglik;
    geomavglik(:,m,:) = exp(-allfits(m).negloglik./repmat(ntrials,2,1));
    AIC(:,m,:) = allfits(m).negloglik + nparams;
    BIC(:,m,:) = allfits(m).negloglik + nparams.*log(repmat(ntrials,2,1))/2;
end

%% print param fits to txt

paramdir = fullfile(resultsdir,'csv_fits');
mkdir_ifnotexist(paramdir)

for m = 1:nmodels
    modelname = modelnames{m};
    nparams = get_nparams(modelname);
    
    filename = sprintf('%s/%s.csv',paramdir,modelname);
    fid = fopen(filename,'w');
    
    % header
    fprintf(fid,'estliks,subjnum,negloglik');
    for p = 1:nparams
        fprintf(fid,',p%i',p);
    end
    fprintf(fid,'\n');
    
    % print each entry
    for k = [1 2]
        for isubj = 1:nsubj
            fprintf(fid,'%i,%i,%1.5g',k-1,subjnums(isubj),allfits(m).negloglik(k,isubj));
            for p = 1:nparams
                fprintf(fid,',%1.5g',allfits(m).params(k,isubj,p));
            end
            fprintf(fid,'\n');
        end
    end
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
            set(gca,'ylim',ylims_geomavglik)
        else
            set(gca,'ylim',ylims)
        end
        titlebf(measure)
    end
    subplot(311); legend('real likelihoods','','estimated likelihoods','')
end


%% for each model, compare using likelihood estimates vs. real likelihoods

outdir = fullfile(resultsdir,'real_vs_est_liks');
mkdir_ifnotexist(outdir);

figure; figuresize('fullscreen')
for meas = 1:3
    measure = measures{meas};
    fid = fopen(sprintf('%s/%s.csv',outdir,measure),'w');
    fprintf(fid,'model,real_liks,est_liks,bootp\n')
    for m = 1:nmodels
        numbers = eval(sprintf('squeeze(%s(:,m,:))',measure));
        diffs = diff(numbers);
        bootp = compute_bootp(diffs, 'lessthan', 0);
        
        subplot_ij(3,nmodels,meas,m)
        barwitherrors([1 2], mean(numbers,2), std(numbers,[],2)/sqrt(nsubj))
        titlebf(sprintf('%s    %s    p = %1.2g',modelnames_abbrev{m},measure,bootp))
        set(gca,'xticklabel',{'real','est'})
        
        fprintf(fid,'%s,%1.3g,%1.3g,%1.3g\n',...
            modelnames{m},mean(numbers(1,:)),mean(numbers(2,:)),bootp)
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

%% recency primacy model

% are recency/primacy weightings correlated?
RP2models = find(cellfun(@(x) ~isempty(strfind(x,'recencyprimacy')), modelnames) ...
    & cellfun(@(x) isempty(strfind(x,'sameweight')), modelnames));
for m = horz(RP2models)
    nparams = get_nparams(modelnames{m});
    figure
    for k = 1:2
        subplot(1,2,k); hold on
        x = vert(allfits(m).params(k,:,nparams-1));
        y = vert(allfits(m).params(k,:,nparams));
        scatter(x,y)
        plotregression(x,y,1);
        [rho, p] = corr(x,y);
        xlabel('recency weight')
        ylabel('primacy weight')
        title(sprintf('estliks %i    rho = %1.2g   p = %1.2g',k-1,rho,p))
    end
    suptitle(modelnames{m})
end

% modelfit vs. recency/primacy weighting?
RP1models = find(cellfun(@(x) ~isempty(strfind(x,'recencyprimacy')), modelnames) ...
    & cellfun(@(x) ~isempty(strfind(x,'sameweight')), modelnames));
for m = horz(RP1models)
    nparams = get_nparams(modelnames{m});
    figure
    for k = 1:2
        subplot(1,2,k); hold on
        x = vert(allfits(m).params(k,:,nparams));
        y = vert(allfits(m).negloglik(k,:));
        scatter(x,y)
        plotregression(x,y,1);
        [rho, p] = corr(x,y);
        xlabel('recency/primacy weight')
        ylabel('negloglik')
        title(sprintf('estliks %i    rho = %1.2g   p = %1.2g',k-1,rho,p))
    end
    suptitle(modelnames{m})
end

%% for feedback models, stats about learning from feedback

% which models
feedback_models = horz(find(cellfun(@(x) ~isempty(strfind(x,'feedbackRL')), modelnames)));

for m = feedback_models
    model = modelnames{m};
    nparams = get_nparams(model);
    if isempty(strfind(model,'recencyprimacy'))
        whichparams = 2:nparams;
    elseif strfind(model,'sameweight')
        whichparams = 2:nparams-1;
    else
        whichparams = 2:nparams-2;
    end
    
    % - proportion of fits with learning rate = 0
    % - mean fit
    figure
    [mean0, meanfit] = deal(nan(2,length(whichparams)));
    for k = 1:2
        for p = whichparams
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
    suptitle(strrep(model,'_','.'))
end

% show that these correlate with the performance changes we saw? XX
