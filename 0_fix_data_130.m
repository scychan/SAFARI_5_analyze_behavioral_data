% want: t, stimlist, tours, trials

clear all

subjnum = 130;

datadir = sprintf('../../4_fMRI_subjects/data_fmri/subj%i',subjnum);

%% compile phase1_complete (sess 1-4)
% had to restart after sess1_tour1

phase1_complete_orig = load(dir_filenames(fullfile(datadir,'phase1_complete_140823*'),0,1))

phase1_sess1 = load(dir_filenames(fullfile(datadir,'phase1_sess1_tour4*'),0,1))

t.phase_start = [];
t.savedata = phase1_complete_orig.t.savedata

stimlist = phase1_complete_orig.stimlist;

tours = phase1_complete_orig.tours
t_fieldnames = {'start_music','showmap','fixation1','question','response',...
    'timeoutmsg','fixation2','stim_onset','break'};
for ifield = 1:length(t_fieldnames)
    fn = t_fieldnames{ifield};
    eval(['tours.t.' fn '(1,:) = phase1_sess1.t.' fn '(1,:);'])
end
tours.b.response(1,:) = phase1_sess1.b.response(1,:);

trials = phase1_complete_orig.trials;

save(fullfile(datadir,'phase1_complete_postfacto'),'t','stimlist','tours','trials')

phase1_complete = load(fullfile(datadir,'phase1_complete_postfacto'));

%% compile phase2_complete (sess 5-7)
% compile with phase1_complete

phase2_toursonly = load(dir_filenames(fullfile(datadir,'phase2_sess7_tour4*'),0,1))

clear t stimlist tours trials

t.phase_start = []; % datenum(2013,10,5,13,36,0)
t.savedata = [];

stimlist = phase1_complete.stimlist;

tours = phase1_complete.tours
t_fieldnames = {'start_music','showmap','fixation1','question','response',...
    'timeoutmsg','fixation2','stim_onset','break'};
for ifield = 1:length(t_fieldnames)
    fn = t_fieldnames{ifield};
    eval(['tours.t.' fn '(5:7,:) = phase2_toursonly.t.' fn '(5:7,:);'])
end
tours.b.response(5:7,:) = phase2_toursonly.b.response(5:7,:);

trials = phase1_complete.trials;

save(fullfile(datadir,'phase2_complete_postfacto'),'t','stimlist','tours','trials')

phase2_complete = load(fullfile(datadir,'phase2_complete_postfacto'))

%% compile phase3_complete
% compile with phase2_complete
% sess8 was saved as "sess9", for some reason

phase3_trialsonly = load(fullfile(datadir,'phase3_sess9_trials_140824_1714.mat'))

clear t stimlist tours trials

t.phase_start = [];
t.savedata = phase3_trialsonly.t.savedata;

stimlist = phase2_complete.stimlist;

tours = phase2_complete.tours;

trials.t = phase3_trialsonly.t;
trials.b = phase3_trialsonly.b;

save(fullfile(datadir,'phase3_complete_postfacto'),'t','stimlist','tours','trials')

phase3_complete = load(fullfile(datadir,'phase3_complete_postfacto'))

%% compile phase4_complete
% compile with phase3_complete

phase4_trialsonly = load(dir_filenames(fullfile(datadir,'phase4_sess13*'),0,1))

clear t stimlist tours trials

t.phase_start = [];
t.savedata = phase4_trialsonly.t.savedata;

stimlist = phase3_complete.stimlist;

tours = phase3_complete.tours;

trials.t = phase4_trialsonly.t;
trials.b = phase4_trialsonly.b;

save(fullfile(datadir,'phase4_complete_postfacto'),'t','stimlist','tours','trials')