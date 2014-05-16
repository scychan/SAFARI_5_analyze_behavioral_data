
clear all
close all

%% options

subjnums = 101:106;
nsubj = length(subjnums);

sector_maplocs = [1 2 4 3]; % clockwise around the map

subjsummaries_dir = fullfile('../results/analyze_tours/subject_summaries');

resultsdir = '../results/analyze_tours/allsubjs';
mkdir_ifnotexist(resultsdir)

%% load subject summaries

subjs = struct([]);
for isubj = 1:nsubj
    subjnum = subjnums(isubj);
    load(fullfile(subjsummaries_dir,...
        sprintf('subj%i/subj%i_tours',subjnum,subjnum)))
    subjs = structarray_add_entry(subjs,isubj,subj,0);
end

%% basics

nsector = size(subjs(1).tours_to_use,2);
nrounds = length(subjs(1).sess_to_use);

%% Percent correct on each tour (separately for each sector)

pcorrect_allsubjs = cat(3,subjs.pcorrect);
pcorrect_mean = nanmean(pcorrect_allsubjs,3);
pcorrect_SE = std(pcorrect_allsubjs,[],3)/sqrt(nsubj);

% how they would perform if they had answered optimally every time
optimal_performance = mean(cat(3,subjs.optimal_performance),3);

figure; figuresize('fullscreen')
for isector = 1:nsector
    subplot(2,2,sector_maplocs(isector)); hold on
    barwitherrors(1:nrounds, pcorrect_mean(isector,:), pcorrect_SE(isector,:))
    bar(nrounds+1,optimal_performance(isector))
    legend('pcorrect','SE','optimal')
    drawacross('h',0.5,'--')
    xlabel('Round')
    set(gca,'xtick',1:nrounds+1,'xticklabel',{1:nrounds,'optimal'})
    ylabel('Percent correct')
    ylim([0 1])
    title(sprintf('Sector %i',isector))
end

saveas(gcf,fullfile(resultsdir,'pcorrect'))

%% Percent optimal on each tour (separately for each sector)

poptimal_allsubjs = cat(3,subjs.poptimal);
poptimal_mean = nanmean(poptimal_allsubjs,3);
poptimal_SE = std(poptimal_allsubjs,[],3)/sqrt(nsubj);

% how they would perform if they had answered optimally every time
optimal_performance = mean(cat(3,subjs.optimal_performance),3);

figure; figuresize('fullscreen')
for isector = 1:nsector
    subplot(2,2,sector_maplocs(isector)); hold on
    hold on
    barwitherrors(1:nrounds, poptimal_mean(isector,:), poptimal_SE(isector,:))
    drawacross('h',0.5,'--')
    xlabel('Round')
    ylabel('Percent correct')
    ylim([0 1])
    title(sprintf('Sector %i',isector))
end

saveas(gcf,fullfile(resultsdir,'poptimal'))

%% Psychometric curves (logistic regression) - presponse vs easiness - by tour
% label the sectors

h1 = figure(gcf+1); figuresize('fullscreen')
h2 = figure(gcf+1); figuresize('fullscreen')
for isector = 1:nsector
    
    for isess = 1:nrounds
                
        % plot logistic for each subject
        figure(h1)
        subplot_ij(nrounds,nsector,isess,isector); hold on
        b_lr = nan(2,nsubj);
        for isubj = 1:nsubj
            b_lr(1,isubj) = subjs(isubj).logreg_b1(isector,isess);
            b_lr(2,isubj) = subjs(isubj).logreg_b2(isector,isess);
            if ~all(b_lr(:,isubj)==0)
                xx = linspace(-0.5,0.5);
                yfit = glmval(b_lr(:,isubj),xx,'logit');
                plot(xx,yfit,'-')
            end
        end
        set(gca,'xlim',[-0.5 0.5])
        ylabel('P(''R'')')
        xlabel('likelihood(R) - likelihood(L)')
        title(sprintf('Sector %i',isector))
        
        % plot logistic using average params
        figure(h2)
        subplot_ij(nrounds,nsector,isess,isector); hold on
        xx = linspace(-0.5,0.5);
        yfit = glmval(mean(b_lr,2),xx,'logit');
        plot(xx,yfit,'r-','linewidth',2)
        set(gca,'xlim',[-0.5 0.5])
        ylabel('P(''R'')')
        xlabel('likelihood(R) - likelihood(L)')
        title(sprintf('Sector %i',isector))
    end
end
saveas(gcf,fullfile(resultsdir,'logreg_bytour'))

%% Psychometric curves (logistic regression) - presponse vs easiness - collapse all four sectors

h1 = figure(gcf+1); figuresize('fullscreen')
h2 = figure(gcf+1); figuresize('fullscreen')

for isess = 1:nrounds
        
    % plot logistic for each subject
    figure(h1)
    subplot_square(nrounds,isess); hold on
    b_lr = nan(2,nsubj);
    for isubj = 1:nsubj
        b_lr(1,isubj) = subjs(isubj).logreg_acrosssectors_b1(isess);
        b_lr(2,isubj) = subjs(isubj).logreg_acrosssectors_b2(isess);
        if ~all(b_lr(:,isubj)==0)
            xx = linspace(-0.5,0.5);
            yfit = glmval(b_lr(:,isubj),xx,'logit');
            plot(xx,yfit,'-')
        end
    end
    set(gca,'xlim',[-0.5 0.5])
    ylabel('P(''R'')')
    xlabel('likelihood(R) - likelihood(L)')
    title(sprintf('Session %i',isess))
    
    % plot logistic using average params
    figure(h2)
    subplot_square(nrounds,isess); hold on
    xx = linspace(-0.5,0.5);
    yfit = glmval(mean(b_lr,2),xx,'logit');
    plot(xx,yfit,'r-','linewidth',2)
    set(gca,'xlim',[-0.5 0.5])
    ylabel('P(''R'')')
    xlabel('likelihood(R) - likelihood(L)')
    title(sprintf('Session %i',isess))
end

saveas(gcf,fullfile(resultsdir,'logreg_acrosssectors'))

%% Psychometric curves (logistic regression) - presponse vs easiness - collapse all data

figure; figuresize('wide')

% plot logistic for each subject
subplot(1,2,1); hold on
b_lr = nan(2,nsubj);
for isubj = 1:nsubj
    b_lr(1,isubj) = subjs(isubj).logreg_alldata_b1;
    b_lr(2,isubj) = subjs(isubj).logreg_alldata_b2;
    if ~all(b_lr(:,isubj)==0)
        xx = linspace(-0.5,0.5);
        yfit = glmval(b_lr(:,isubj),xx,'logit');
        plot(xx,yfit,'-')
    end
end
title('all subjects')

% plot logistic using average parameters
subplot(1,2,2); hold on
xx = linspace(-0.5,0.5);
yfit = glmval(mean(b_lr,2),xx,'logit');
plot(xx,yfit,'r-','linewidth',2)
set(gca,'xlim',[-0.5 0.5])
ylabel('P(''R'')')
xlabel('likelihood(R) - likelihood(L)')
title('mean params across subjects')

saveas(gcf,fullfile(resultsdir,'logreg_alldata'))

%% RTs on each tour (separately for each sector)

RT_allsubjs = cat(3,subjs.RTs);
RT_mean = nanmean(RT_allsubjs,3);
RT_SE = std(RT_allsubjs,[],3)/sqrt(nsubj);

figure; figuresize('fullscreen')
for isector = 1:nsector
    subplot(2,2,sector_maplocs(isector)); hold on
    hold on
    barwitherrors(1:nrounds, RT_mean(isector,:), RT_SE(isector,:))
    drawacross('h',0.5,'--')
    xlabel('RT')
    ylabel('Percent correct')
    title(sprintf('Sector %i',isector))
end

saveas(gcf,fullfile(resultsdir,'RT'))
