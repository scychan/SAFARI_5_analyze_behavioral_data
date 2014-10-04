function rescore(subjnum)

batchdir = pwd;


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
   
%% get scores

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

trials.answers = cell(1,nsess);
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
        if stimlist.trials.answers_new{isess}(itr) == stimlist.trials.answers{isess}(itr)
            trials_with_incorrect_feedback{isess}(itr) = 0;
        elseif stimlist.trials.answers_new{isess}(itr) ~= stimlist.trials.answers{isess}(itr)
            trials_with_incorrect_feedback{isess}(itr) = 1;
        end
    end
end

ncorrect_thissess = sum(trials.b.response{isess} == stimlist.trials.answers_new{isess});
disp('ncorrect_thissess');
% disp(ncorrect_thissess)

correct_new = cellfun(@(x,y) sum(x==y), trials.b.response(sess_to_use), stimlist.trials.answers_new(sess_to_use), 'UniformOutput',false)

resultsmat = sprintf('subj%i.mat',subjnum);
aa = fullfile(batchdir,resultsmat);
save(aa, 'stim_to_use', 'stimlist', 'subj', 'subjnum', 'trials_with_incorrect_feedback', 'correct_new')

