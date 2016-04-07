
% want: t, stimlist, tours, trials

clear all

subjnum = 103;

datadir = sprintf('../../4_fMRI_subjects/data_fmri/subj%i',subjnum);

%% fix the stimlist
% skipped 4th session of tours on day1 [1 1 1 1 2 2 2 2 3 4 4 4 4] for stimlist.phase

load(dir_filenames(fullfile(datadir,'stimlist*'),0,1))

stimlist.tour_or_trials = [1 1 1 nan 1 1 1 2 2 2 2 2 2];

% save new stimlist
save(fullfile(datadir,'stimlist_post_facto'),'stim_to_use','stimlist')

% rename original stimlist
movefile(fullfile(datadir,'stimlist_subj101_copy.mat'),fullfile(datadir,'origstimlist_subj101_copy.mat'))