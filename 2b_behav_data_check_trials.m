
clear all
close all

%%

subjnum = 102

%% load subject data
% t, tours, trials, stimlist, stim_to_use

subj.subjnum = subjnum;

% subject's resultsdir
resultsdir = sprintf('../4_fMRI_subjects/data_fmri/subj%i',subjnum);

% load phase4_complete
load(dir_filenames(fullfile(resultsdir,'phase4_complete*'),0,1))

% load stimlist, stim_to_use
load(dir_filenames(fullfile(resultsdir,'stimlist*'),0,1))

%% directory for saving resulting plots

subjplots_dir = fullfile('analyze_trials','subject_summaries',sprintf('subj%i',subjnum));
mkdir(subjplots_dir)


%% Basics

stimlist_master = stimlist;
t_master = t;
stimlist = stimlist.trials;
t = trials.t;
b = trials.b;

if ~exist('sess_to_use')
    sess_to_use = find(stimlist_master.tour_or_trials == 2);
end

if ~exist('epi_sess')
    epi_sess = intersect(sess_to_use,find(stimlist_master.phase==4))
end


likelihoods = stim_to_use.likelihoods;
nanimals = stim_to_use.nanimals;
nsectors = stim_to_use.nsectors;
nsess = length(sess_to_use);

sectors = stimlist.sectors;
sesslengths = cellfun(@length,stimlist.answers);

timeout = cellfun(@isnan,b.response,'UniformOutput',0);
correct(sess_to_use) = cellfun(@naneq,b.response(sess_to_use),stimlist.answers(sess_to_use),'UniformOutput',0);
RTs = cellfun(@minus,t.response,t.question,'UniformOutput',0);

trainingsess = find(stimlist_master.phase==3);
episess = find(stimlist_master.phase==4);

subj.sess_to_use = sess_to_use;

%% Stimuli presented
% Were they in the right proportions?

if false
    figure; figuresize('wide')
    for sess = sess_to_use
        for sector = 1:nsectors
            sector_trials = find(sectors{sess}==sector);
            ntrials_in_sector = length(sector_trials);
            
            animals_in_sector = [];
            for itr = 1:length(sector_trials)
                trial = sector_trials(itr);
                animals_in_sector = [animals_in_sector; stimlist.animals{sess}{itr}];
            end
            proportions = hist(animals_in_sector,1:nanimals);
            right_proportions = length(animals_in_sector)*likelihoods(:,sector);
            subplot(1,nsectors,sector)
            bar([right_proportions(:) proportions(:)])
            
            title(sprintf('Sector %i',sector))
            xlabel('animal')
        end
        suptitle(sprintf('Session %i',sess))
        pause
    end
    legend('correct proportions','actual proportions')
end

%% Look at their choices over time

for isess = 1:nsess
    sess = sess_to_use(isess);
    
    subplot_square(nsess,isess);
    sess_responses = b.response{sess}-1.5;
    sess_responses(isnan(sess_responses)) = 0;
    plot(cumsum(sess_responses))
    title(sprintf('Sess %i',sess))
    hold on; drawacross('h',0)
end
saveas(gcf,fullfile(subjplots_dir,'choices_over_time'))

%% Percent correct over time - by session

pcorrect = cellfun(@nanmean,correct);

figure; figuresize('wide')
bar(pcorrect)
hold on
drawacross('h',0.5)
ylabel('Percent Correct')
xlabel('Session length (num trials)')
set(gca,'xtick',1:length(pcorrect),'xticklabel',sesslengths)
ylim([0 1])
saveas(gcf,fullfile(subjplots_dir,'pcorrect_over_time'))

subj.pcorrect = pcorrect;

%% Average percent correct

disp('pcorrect - average over all trials')
nanmean([correct{:}])

disp('pcorrect - average for training')
nanmean([correct{trainingsess}])

disp('pcorrect - average for epis')
nanmean([correct{episess}])

%% Difficulty level for each question
% (the difference in posterior probability between the two choices)

rightness = cell(size(correct));
for sess = sess_to_use
    for itr = 1:sesslengths(sess)
        posterior = stimlist.posteriors{sess}{itr}(end,:);
        options = stimlist.questions_sectors{sess}(itr,:);
        switch stimlist.questions_biggersmaller{sess}(itr)
            case 1
                rightness{sess}(itr) = posterior(options(2)) - posterior(options(1));
            case 2
                rightness{sess}(itr) = posterior(options(1)) - posterior(options(2));
        end
    end
end

%% Psychometric curve - "epi" sessions only - p(response=R) vs rightness

figure; hold on

% scatter plot
x = [rightness{epi_sess}]; x = x(:);
y = [b.response{epi_sess}]-1; y = y(:);
% plot(x,y,'rd')

% scatter plot - binned
[counts ymeans ystds bincenters binedges xbins ybins] = bincount(x,y,-1:0.2:1);
plot(bincenters,ymeans,'md')
%errorbar(bincenters,ymeans,ystds./sqrt(counts))

% histogram
for r = [0 1]
    h = cellfun(@(x) sum(x==r),ybins)
    switch r
        case 0
            plot(bincenters,h/length(x),'g--')
        case 1
            plot(bincenters,1-h/length(x),'g--')
    end
end

% logistic regression
[blr,dev,stats] = glmfit(x,y,'binomial','link','logit');
xx = linspace(-1,1);
yfit = glmval(blr,xx,'logit');
hold on
plot(xx,yfit,'-')
ylim([0 1])
drawacross('h',0.5')
drawacross('v',0)

% title
title(sprintf('b1  %2.2f   -   b2  %2.2f',blr(1),blr(2)))

saveas(gcf,fullfile(subjplots_dir,'logreg_episess'))

subj.logreg_b1 = blr(1);
subj.logreg_b2 = blr(2);

%% Psychometric curves (logistic regression) - by session

figure; figuresize('wide')
for isess = 1:nsess
    sess = sess_to_use(isess);
    
    subplot(1,nsess,isess); hold on
    
    % scatter plot
    x = rightness{sess}; x = x(:);
    y = b.response{sess}-1; y = y(:);
    %     plot(x,y,'rd')
    
    % scatter plot - binned
    [counts ymeans ystds bincenters binedges xbins ybins] = bincount(x,y,-1:0.25:1);
    plot(bincenters,ymeans,'md')
    %errorbar(bincenters,ymeans,ystds./sqrt(counts))
    
    % histogram
    for r = [0 1]
        h = cellfun(@(x) sum(x==r),ybins)
        switch r
            case 0
                plot(bincenters,h/length(x),'g--')
            case 1
                plot(bincenters,1-h/length(x),'g--')
        end
    end
    
    % logistic regression
    [blr,dev,stats] = glmfit(x,y,'binomial','link','logit');
    xx = linspace(-1,1);
    yfit = glmval(blr,xx,'logit');
    hold on
    plot(xx,yfit,'-')
    ylim([0 1])
    drawacross('h',0.5')
    drawacross('v',0)
    
    % title
    title(sprintf('Session %i  -  Slope  %2.2f',sess,blr(2)))
    
    subj.logreg_bysess_b1(isess) = blr(1);
    subj.logreg_bysess_b2(isess) = blr(2);
end

saveas(gcf,fullfile(subjplots_dir,'logreg_bysess'))

%% divide into MAP questions / nonMAP questions

isMAPquestion = cell(size(stimlist.answers));
for sess = sess_to_use
    for q = 1:length(stimlist.posteriors{sess})
        finalp = stimlist.posteriors{sess}{q}(end,:);
        [temp MAP] = max(finalp);
        isMAPquestion{sess}(q) = ismember(MAP,...
            stimlist.questions_sectors{sess}(q,:));
    end
end

cellfun(@sum,isMAPquestion)
isMAPquestion

%% percent correct - MAP vs nonMAP

for useMAP = [0 1]
    for sess = sess_to_use
        pcorrect_byMAP(sess,useMAP+1) = nanmean(correct{sess}(isMAPquestion{sess}==useMAP));
    end
end
subj.pcorrect_byMAP = pcorrect_byMAP;

figure
bar(pcorrect_byMAP)
hold on
drawacross('h',0.5)
xlabel('Session')
ylabel('Percent Correct')
legend('nonMAP questions','MAP questions')
saveas(gcf,fullfile(subjplots_dir,'pcorrect_byMAP'))

figure; hold on
bar(mean(pcorrect_byMAP(epi_sess,:),1))
ylim([0 1])
drawacross('h',0.5)
xlabel('useMAP'); set(gca,'xtick',[1 2],'xticklabel',[0 1])
ylabel('Percent Correct')

%% psychometric functions - epi sessions only
figure; figuresize('wide')
for useMAP = [0 1]
    subplot(1,2,useMAP+1); hold on
    
    % get data
    x = []; y = [];
    for sess = epi_sess
        x = [x rightness{sess}(isMAPquestion{sess}==useMAP)];
        y = [y b.response{sess}(isMAPquestion{sess}==useMAP)];
    end
    x = x(:); y = y(:)-1;
    
    % scatter plot
    %     plot(x,y,'rd')
    
    % scatter plot - binned
    [counts ymeans ystds bincenters binedges xbins ybins] = bincount(x,y,-1:0.2:1);
    plot(bincenters,ymeans,'md')
    %     errorbar(bincenters,ymeans,ystds./sqrt(counts))
    
    % histogram
    for r = [0 1]
        h = cellfun(@(x) sum(x==r),ybins)
        switch r
            case 0
                plot(bincenters,h/length(x),'g--')
            case 1
                plot(bincenters,1-h/length(x),'g--')
        end
    end
    
    % logistic regression
    [blr,dev,stats] = glmfit(x,y,'binomial','link','logit');
    xx = linspace(-1,1);
    yfit = glmval(blr,xx,'logit');
    hold on
    plot(xx,yfit,'-')
    ylim([0 1])
    drawacross('h',0.5')
    drawacross('v',0)
    
    % title
    title(sprintf('Slope  %2.2f  -  useMAP=%i',blr(2),useMAP))
    horz(counts)
    
    subj.logreg_byMAP_b1(useMAP+1) = blr(1);
    subj.logreg_byMAP_b2(useMAP+1) = blr(2);
end
saveas(gcf,fullfile(subjplots_dir,'logreg_byMAP'))

%% psychometric functions by session - MAP vs nonMAP

figure; figuresize('fullscreen')
for useMAP = [0 1]
    for isess = 1:nsess
        sess = sess_to_use(isess);
        
        subplot_ij(2,nsess,useMAP+1,isess); hold on
        
        % scatter plot
        x = rightness{sess}(isMAPquestion{sess}==useMAP); x = x(:);
        y = b.response{sess}(isMAPquestion{sess}==useMAP)-1; y = y(:);
        %         plot(x,y,'rd')
        
        % scatter plot - binned
        [counts ymeans ystds bincenters binedges xbins ybins] = bincount(x,y,-1:0.25:1);
        plot(bincenters,ymeans,'md')
        %         errorbar(bincenters,ymeans,ystds./sqrt(counts))
        
        % histogram
        for r = [0 1]
            h = cellfun(@(x) sum(x==r),ybins)
            switch r
                case 0
                    plot(bincenters,h/length(x),'g--')
                case 1
                    plot(bincenters,1-h/length(x),'g--')
            end
        end
        
        % logistic regression
        [blr,dev,stats] = glmfit(x,y,'binomial','link','logit');
        xx = linspace(-1,1);
        yfit = glmval(blr,xx,'logit');
        hold on
        plot(xx,yfit,'-')
        ylim([0 1])
        drawacross('h',0.5')
        drawacross('v',0)
        
        % title
        title(sprintf('Session %i  -  Slope  %2.2f',sess,blr(2)))
        
        subj.logreg_byMAP_bysess_b1(useMAP+1,isess) = blr(1);
        subj.logreg_byMAP_bysess_b2(useMAP+1,isess) = blr(2);
    end
end


%% RTs - by session

RTs_bysess = cellfun(@nanmean,RTs);

figure;
bar(RTs_bysess)
xlabel('Session')
ylabel('Reaction time (secs)')
title(sprintf('mean RT (epi sess) = %2.2f',mean(RTs_bysess(episess))))

subj.RTs = RTs_bysess;

%% Timeouts - by session

numtimeouts = cellfun(@(x) sum(isnan(x)),RTs);
figure; bar(numtimeouts)
title('Timeouts')
xlabel('Session length (num trials)')
set(gca,'xtick',1:length(pcorrect),'xticklabel',sesslengths)
title(sprintf('Num timeouts (epi sess) = %2.2f',sum(numtimeouts(episess))))

subj.timeouts = numtimeouts;

%% check timing - stim_onsets vs startscan_trigger
% should be close to integer multiples of 2

allmods = [];
for sess = episess
    sess_len = length(t.stim_onset{sess});
    for trial = 1:sess_len
        trial_len = length(t.stim_onset{sess}{trial});
        timing = t.stim_onset{sess}{trial} - repmat(t.startscan_trigger(sess),1,trial_len);
        mods = mod(timing,2);
        mods(mods>1) = mods(mods>1) - 2;
        allmods = [allmods mods];
    end
end
figure; hist(allmods,10)

%% check timing - stim_onsets vs trigger at the start of each trial
% should be close to integer multiples of 2

allmods = [];
for sess = episess
    sess_len = length(t.stim_onset{sess});
    for trial = 1:sess_len
        trial_len = length(t.stim_onset{sess}{trial});
        timing = t.stim_onset{sess}{trial} - repmat(t.trigger{sess}(trial),1,trial_len);
        mods = mod(timing,2);
        mods(mods>1) = mods(mods>1) - 2;
        allmods = [allmods mods];
    end
end
figure; hist(allmods,10)

%% how many times did we miss a trigger / need to generate a fake trigger?

sum(~isnan([t.fake_trigger{:}]))

%% check timing of triggers -- how precisely 2 seconds?

allmods = [];
for sess = episess
    sess_len = length(t.stim_onset{sess});
    timing = t.trigger{sess} - repmat(t.startscan_trigger(sess),1,sess_len);
    mods = mod(timing,2);
    mods(mods>1) = mods(mods>1) - 2;
    allmods = [allmods mods];
end

figure; hist(allmods,10)

figure; hold on
plot(allmods,'.')
drawacross('h',0)


%% save the subject summary

save(fullfile('analyze_trials','subject_summaries',sprintf('subj%i_trials',subjnum)),'subj')

