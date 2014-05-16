
clear all
close all

%% options

subjnums = 101:106;
nsubj = length(subjnums);

sector_maplocs = [1 2 4 3]; % clockwise around the map

subjsummaries_dir = fullfile('../results/analyze_trials/subject_summaries');

resultsdir = '../results/analyze_trials/allsubjs';
mkdir_ifnotexist(resultsdir)

%% load subject summaries

subjs = struct([]);
for isubj = 1:nsubj
    subjnum = subjnums(isubj);
    load(fullfile(subjsummaries_dir, sprintf('subj%i_trials',subjnum)))
    subjs = structarray_add_entry(subjs,isubj,subj,0);
end

%% basics

sess_to_use = subjs(1).sess_to_use;
nsess = length(sess_to_use);

%% Percent correct on each tour (separately for each sector)

pcorrect_allsubjs = vertcat(subjs.pcorrect); % nsubj x nsess
pcorrect_allsubjs = pcorrect_allsubjs(:,sess_to_use);
pcorrect_mean = nanmean(pcorrect_allsubjs,1);
pcorrect_SE = std(pcorrect_allsubjs,[],1)/sqrt(nsubj);

figure; hold on
barwitherrors(1:nsess, pcorrect_mean, pcorrect_SE)
drawacross('h',0.5,'--')
xlabel('Round')
ylabel('Percent correct')
ylim([0 1])
title(sprintf('Sector %i',isector))

saveas(gcf,fullfile(resultsdir,'pcorrect'))


%% Psychometric curves (logistic regression) - epi sessions

figure; figuresize('wide')

% plot logistic for each subject
subplot(1,2,1); hold on
b_lr = nan(2,nsubj);
for isubj = 1:nsubj
    b_lr(1,isubj) = subjs(isubj).logreg_b1;
    b_lr(2,isubj) = subjs(isubj).logreg_b2;
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

%% Psychometric curves (logistic regression) - by session

h1 = figure(gcf+1); figuresize('fullscreen')
h2 = figure(gcf+1); figuresize('fullscreen')

for isess = 1:nsess
        
    % plot logistic for each subject
    figure(h1)
    subplot_square(nsess,isess); hold on
    b_lr = nan(2,nsubj);
    for isubj = 1:nsubj
        b_lr(1,isubj) = subjs(isubj).logreg_bysess_b1(isess);
        b_lr(2,isubj) = subjs(isubj).logreg_bysess_b2(isess);
        if ~all(b_lr(:,isubj)==0)
            xx = linspace(-0.5,0.5);
            yfit = glmval(b_lr(:,isubj),xx,'logit');
            plot(xx,yfit,'-')
        end
    end
    set(gca,'xlim',[-0.5 0.5])
    ylabel('P(''R'')')
    ylim([0 1])
    xlabel('likelihood(R) - likelihood(L)')
    title(sprintf('Session %i',isess))
    
    % plot logistic using average params
    figure(h2)
    subplot_square(nsess,isess); hold on
    xx = linspace(-0.5,0.5);
    yfit = glmval(mean(b_lr,2),xx,'logit');
    plot(xx,yfit,'r-','linewidth',2)
    set(gca,'xlim',[-0.5 0.5])
    ylabel('P(''R'')')
    ylim([0 1])
    xlabel('likelihood(R) - likelihood(L)')
    title(sprintf('Session %i',isess))
end

saveas(h1,fullfile(resultsdir,'logreg_bysess'))


%% Percent correct - nonMAP vs MAP

pcorrect_allsubjs = cat(3,subjs.pcorrect_byMAP); % nsess x isMAP x nsubj
pcorrect_allsubjs = pcorrect_allsubjs(sess_to_use,:,:);
pcorrect_mean = nanmean(pcorrect_allsubjs,3);
pcorrect_SE = std(pcorrect_allsubjs,[],3)/sqrt(nsubj);

figure; figuresize('wide'); hold on
for hasMAP = 0:1
    switch hasMAP
        case 0
            barcolor = 'k';
        case 1
            barcolor = 'b';
    end
    barwitherrors((1:nsess) - 0.2 + hasMAP*0.4, ...
        pcorrect_mean(:,hasMAP+1), ...
        pcorrect_SE(:,hasMAP+1), ...
        'width',0.2,'barcolor',barcolor)
end
legend({'no MAP','SE','has MAP'})
drawacross('h',0.5,'--')
xlabel('Session')
ylabel('Percent correct')
ylim([0 1])

saveas(gcf,fullfile(resultsdir,'pcorrect_byMAP'))

%% RTs on each tour (separately for each sector)

RT_allsubjs = vertcat(subjs.RTs);
RT_allsubjs = RT_allsubjs(:,sess_to_use); % nsubj x nsess
RT_mean = nanmean(RT_allsubjs,1);
RT_SE = std(RT_allsubjs,[],1)/sqrt(nsubj);

figure; hold on
barwitherrors(1:nsess, RT_mean, RT_SE)
xlabel('Session')
ylabel('RT')
ylim([0 2.5])
title(sprintf('Sector %i',isector))

saveas(gcf,fullfile(resultsdir,'RT'))
