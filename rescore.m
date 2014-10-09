function rescore(subjnum)


%% load subject data
% t, tours, trials, stimlist, stim_to_use

subj.subjnum = subjnum;

% subject's resultsdir
resultsdir = sprintf('../../4_fMRI_subjects/data_fmri/subj%i',subjnum);

% load phase4_complete
load(dir_filenames(fullfile(resultsdir,'phase4_complete*'),0,1))

% load stimlist, stim_to_use
load(dir_filenames(fullfile(resultsdir,'stimlist*'),0,1))

%% basics

nsess = length(stimlist.tour_or_trials);
sess_to_use = 1:nsess;
trialsessions = find(stimlist.tour_or_trials==2);
trialsesslengths = [nan nan nan nan nan nan nan ...
        20 20 30 30 30 30];
   
%% compute true posteriors, compare with old

for isess = trialsessions
    ntrials_sess = trialsesslengths(isess);
    stimlist.trials.posteriors_new{isess} = cell(1,ntrials_sess);
    for itr = 1:ntrials_sess
        trial_length = stimlist.trials.lengths{isess}(itr);
        animals = stimlist.trials.animals{isess}{itr};
        
        unnormalized = cumprod(stim_to_use.likelihoods(animals,:),1);
        stimlist.trials.posteriors_new{isess}{itr} = normalize1(unnormalized,'r');
        if all(stimlist.trials.posteriors{isess}{itr} == stimlist.trials.posteriors_new{isess}{itr}) == 0
            orig = stimlist.trials.posteriors{isess}{itr};
            corrected = stimlist.trials.posteriors_new{isess}{itr};
            disp([orig; corrected]);
        end
    end
end

%% compute correct feedback, compare with old

stimlist.trials.answers_old = stimlist.trials.answers;
stimlist.trials = rmfield(stimlist.trials,'answers');
stimlist.trials.answers_new = cell(1,nsess);
for isess = trialsessions
    ntrials_sess = trialsesslengths(isess);
    trials.answers{isess} = nan(1,ntrials_sess);
    for itr = 1:ntrials_sess
        final_posterior = stimlist.trials.posteriors_new{isess}{itr}(end,:);
        options_posteriors = final_posterior(stimlist.trials.questions_sectors{isess}(itr,:));
        switch stimlist.trials.questions_biggersmaller{isess}(itr)
            case 1
                [temp, stimlist.trials.answers_new{isess}(itr)] = max(options_posteriors);
            case 2
                [temp, stimlist.trials.answers_new{isess}(itr)] = min(options_posteriors);
        end
        if stimlist.trials.answers_new{isess}(itr) == stimlist.trials.answers_old{isess}(itr)
            trials_with_incorrect_feedback{isess}(itr) = 0;
        elseif stimlist.trials.answers_new{isess}(itr) ~= stimlist.trials.answers_old{isess}(itr)
            trials_with_incorrect_feedback{isess}(itr) = 1;
        end
    end
end

fprintf('\nproportion of trials with incorrect feedback: %0.2g\n',...
    mean([trials_with_incorrect_feedback{:}]))

%% re-evaluate their responses

correct_new = cellfun(@(x,y) sum(x==y), ...
    trials.b.response(sess_to_use), stimlist.trials.answers_new(sess_to_use),...
    'UniformOutput',false);

correct_old = cellfun(@(x,y) sum(x==y), ...
    trials.b.response(sess_to_use), stimlist.trials.answers_old(sess_to_use),...
    'UniformOutput',false);

fprintf('\nperformance - practice sessions: %0.2g (old = %0.2g)\n',...
    mean([correct_new{8:9}]),mean([correct_old{8:9}]))

fprintf('\nperformance - scan sessions: %0.2g (old = %0.2g)\n',...
    mean([correct_new{10:13}]),mean([correct_old{10:13}]))

%% save results

rescorings = var2struct(trials_with_incorrect_feedback, correct_new);

resultsdir = '../results/rescore';
resultsmat = sprintf('subj%i.mat',subjnum);
save(fullfile(resultsdir,resultsmat), ...
    'stim_to_use', 'stimlist', 'subj', 'subjnum', 'trials', 'rescorings');

