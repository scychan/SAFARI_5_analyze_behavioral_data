%% options

% subjnums
subjnums = setdiff(101:134,[111 128]);
nsubj = length(subjnums);

% fMRI sessions
sess_to_use = 10:13;
nsess = length(sess_to_use);

% results directory
resultsdir = '../../results/probability_matching';
mkdir_ifnotexist(resultsdir);

%% iterate through subjects

% initialize variables
XX

for isubj = 1:nsubj
    subjnum = subjnums(isubj);
    
    %% load subject data
    % trials, rescorings, stimlist, stim_to_use
    
    % load rescored data
    load(sprintf('../../results/rescore/subj%i',subjnum));
    
    %% how to measure probability matching?
    % linearity? but how to distinguish from poor performance?
    
end

%% aggregate over subjects -- all sessions
