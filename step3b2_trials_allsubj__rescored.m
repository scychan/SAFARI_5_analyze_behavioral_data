
clear all
close all

%% options

subjnums = setdiff(101:134,[111 128])
nsubj = length(subjnums);

sector_maplocs = [1 2 4 3]; % clockwise around the map

subjsummaries_dir = fullfile('../results/analyze_trials_correctly/subject_summaries');

resultsdir = '../results/analyze_trials_correctly/allsubjs';
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
episess = sess_to_use(end-3:end);
nsess = length(sess_to_use);

%% Max performance on each session IF they were perfectly probability matching

probmatch_perfs = vertcat(subjs.probmatch_perf);

% mean + SE in each session
mean(probmatch_perfs)
std(probmatch_perfs)/sqrt(nsubj)

% mean + SE for epi sessions
probmatch_perfs_episess = mean(probmatch_perfs(:,episess)');
mean(probmatch_perfs_episess)
std(probmatch_perfs_episess)/sqrt(nsubj)


%% Percent correct - average across episess

% all questions
pcorrect_allsubjs = vertcat(subjs.pcorrect); % nsubj x nsess
pcorrect_allsubjs = mean(pcorrect_allsubjs(:,sess_to_use(3:end)),2);
pcorrect_mean(1) = nanmean(pcorrect_allsubjs,1);
pcorrect_SEM(1) = std(pcorrect_allsubjs,[],1)/sqrt(nsubj);

% noMAP questions
pcorrect_allsubjs = horzcat(subjs.pcorrect_byMAP);
pcorrect_allsubjs = pcorrect_allsubjs(:,1:2:nsubj*2);
pcorrect_allsubjs = nanmean(pcorrect_allsubjs(sess_to_use(3:end),:),1);
pcorrect_mean(2) = nanmean(pcorrect_allsubjs);
pcorrect_SEM(2) = std(pcorrect_allsubjs,[],2)/sqrt(nsubj);

% hasMAP questions
pcorrect_allsubjs = horzcat(subjs.pcorrect_byMAP);
pcorrect_allsubjs = pcorrect_allsubjs(:,2:2:nsubj*2);
pcorrect_allsubjs = nanmean(pcorrect_allsubjs(sess_to_use(3:end),:),1);
pcorrect_mean(3) = nanmean(pcorrect_allsubjs);
pcorrect_SEM(3) = std(pcorrect_allsubjs,[],2)/sqrt(nsubj);

% draw figure
figure; hold on
barwitherrors(1:3, pcorrect_mean, pcorrect_SEM,'basevalue',0.5)
set(gca,'xtick',1:3,'xticklabel',{'all questions','nonMAP','hasMAP'})
ylabel('P(correct)')

saveas(gcf,fullfile(resultsdir,'pcorrect_episessavg'))

%% Percent correct on each session

pcorrect_allsubjs = vertcat(subjs.pcorrect); % nsubj x nsess
pcorrect_allsubjs = pcorrect_allsubjs(:,sess_to_use);
pcorrect_mean = nanmean(pcorrect_allsubjs,1);
pcorrect_SE = std(pcorrect_allsubjs,[],1)/sqrt(nsubj);

figure; hold on
barwitherrors(1:nsess, pcorrect_mean, pcorrect_SE)
drawacross('h',0.5,'--')
xlabel('Session')
set(gca,'xtick',1:nsess)
ylabel('P(correct)')
ylim([0 1])

saveas(gcf,fullfile(resultsdir,'pcorrect_bysess'))


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
    drawacross('h',0.5)
    drawacross('v',0)
end
title('individual subjects')

% plot logistic using average parameters
subplot(1,2,2); hold on
xx = linspace(-0.5,0.5);
yfit = glmval(mean(b_lr,2),xx,'logit');
plot(xx,yfit,'r-','linewidth',2)
set(gca,'xlim',[-0.5 0.5])
equalize_subplot_axes('xy',gcf,1,2)
drawacross('h',0.5)
drawacross('v',0)
ylabel('P(''R'')')
xlabel('likelihood(R) - likelihood(L)')
title('mean params across subjects')

saveas(gcf,fullfile(resultsdir,'logreg_alldata'))

%% Psychometric curves (logistic regression) - by session

h1 = figure; figuresize('fullscreen')
h2 = figure; figuresize('fullscreen')

all_b_lr = nan(nsess,nsubj,2);
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
    
    all_b_lr(isess,:,1) = b_lr(1,:);
    all_b_lr(isess,:,2) = b_lr(2,:);
end

% plot param values - allsubjects
figure
for i = 1:2
    subplot(1,2,i); hold on
    x = repmat(1:nsess,nsubj,1)'; % nsess x nsubj
    y = all_b_lr(:,:,i); % nsess x nsubj
    plot(x,y,'.-')
    xlim([0 nsess+1])
    ylabel(sprintf('b%i',i))
    drawacross('h',0)
end

% plot param values - mean and SE
figure
for i = 1:2
    subplot(1,2,i); hold on
    param_mean = nanmean(all_b_lr(:,:,i),2);
    param_SE = std(all_b_lr(:,:,i),[],2) / sqrt(nsubj);
    barwitherrors([],param_mean,param_SE)
    xlim([0 nsess+1])
    ylabel(sprintf('b%i',i))
    drawacross('h',0)
end

saveas(h1,fullfile(resultsdir,'logreg_bysess'))

%% Psychometric curves (logistic regression) - MAP vs nonMAP

figure; figuresize('wide')

% plot logistic for each subject
b_lr = nan(2,nsubj);
for isubj = 1:nsubj
    for iplot = [1 2]
        useMAP = iplot - 1;
        subplot(1,2,iplot); hold on
        b_lr(1,isubj) = subjs(isubj).logreg_byMAP_b1(iplot);
        b_lr(2,isubj) = subjs(isubj).logreg_byMAP_b2(iplot);
        if ~all(b_lr(:,isubj)==0)
            xx = linspace(-0.5,0.5);
            yfit = glmval(b_lr(:,isubj),xx,'logit');
            plot(xx,yfit,'-')
        end
        drawacross('h',0.5)
        drawacross('v',0)
    end
end
title('individual subjects')

% plot logistic using average parameters
subplot(1,2,2); hold on
xx = linspace(-0.5,0.5);
yfit = glmval(mean(b_lr,2),xx,'logit');
plot(xx,yfit,'r-','linewidth',2)
set(gca,'xlim',[-0.5 0.5])
equalize_subplot_axes('xy',gcf,1,2)
drawacross('h',0.5)
drawacross('v',0)
ylabel('P(''R'')')
xlabel('likelihood(R) - likelihood(L)')
title('mean params across subjects')

saveas(gcf,fullfile(resultsdir,'logreg_alldata'))


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

saveas(gcf,fullfile(resultsdir,'RT'))
