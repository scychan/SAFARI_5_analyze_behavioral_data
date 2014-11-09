
clear all
close all

%%

subjnum = 101

%% load subject data
% t, tours, trials, stimlist, stim_to_use

subj.subjnum = subjnum;

% % subject's resultsdir
% resultsdir = sprintf('../../4_fMRI_subjects/data_fmri/subj%i',subjnum);
% 
% % load phase4_complete
% load(dir_filenames(fullfile(resultsdir,'phase4_complete*'),0,1))
% 
% % load stimlist, stim_to_use
% load(dir_filenames(fullfile(resultsdir,'stimlist*'),0,1))

% load rescored data
load(sprintf('../results/rescore/subj%i',subjnum));

%% directory for saving resulting plots

subjplots_dir = fullfile('../results/analyze_trials_correctly/subject_summaries',sprintf('subj%i',subjnum));
mkdir(subjplots_dir)

%% Basics

stimlist_master = stimlist;
% t_master = t;
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
sesslengths = cellfun(@length,stimlist.answers_new);

correct_old(sess_to_use) = cellfun(@naneq,b.response(sess_to_use),stimlist.answers_new(sess_to_use),'UniformOutput',0);
correct_new(sess_to_use) = cellfun(@naneq,b.response(sess_to_use),stimlist.answers_new(sess_to_use),'UniformOutput',0);

trainingsess = find(stimlist_master.phase==3);
episess = find(stimlist_master.phase==4);

subj.sess_to_use = sess_to_use;


%% Difficulty level for each question
% (the difference in posterior probability between the two choices)

rightness = cell(size(correct_new));
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
    h = cellfun(@(x) sum(x==r),ybins);
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
ylabel('<- left .. right ->')
drawacross('h',0.5')
drawacross('v',0)

% title
title(sprintf('EPI sessions only   -   b1  %2.2f   -   b2  %2.2f',blr(1),blr(2)))

% saveas(gcf,fullfile(subjplots_dir,'logreg_episess'))

subj.logreg_b1 = blr(1);
subj.logreg_b2 = blr(2);