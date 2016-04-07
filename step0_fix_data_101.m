
% want: t, stimlist, tours, trials

clear all

subjnum = 101;

datadir = sprintf('../4_fMRI_subjects/data_fmri/subj%i',subjnum);

%% fix the stimlist
% accidentally read [1 1 1 1 2 2 2 2 3 4 4 4 4] for stimlist.phase

load(dir_filenames(fullfile(datadir,'stimlist*'),0,1))

stimlist.phase = [1 1 1 1 2 2 2 3 3 4 4 4 4]

save(fullfile(datadir,'stimlist_post_facto'),'stim_to_use','stimlist')

%% compile phase1_complete (sess 1-4)
% had to restart after sess1_tour1

phase1_complete_orig = load(dir_filenames(fullfile(datadir,'phase1_complete_131004*'),0,1))

phase1_tour1 = load(dir_filenames(fullfile(datadir,'phase1_sess1_tour1*'),0,1))

clear t stimlist tours trials

t.phase_start = [];
t.savedata = phase1_complete_orig.t.savedata

stimlist = phase1_complete_orig.stimlist;

tours = phase1_complete_orig.tours
t_fieldnames = {'start_music','showmap','fixation1','question','response',...
    'timeoutmsg','fixation2','stim_onset','break'};
for ifield = 1:length(t_fieldnames)
    fn = t_fieldnames{ifield};
    eval(['tours.t.' fn '(1,1) = phase1_tour1.t.' fn '(1,1);'])
end
tours.b.response(1,1) = phase1_tour1.b.response(1,1);

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

sess8_trialsonly = load(fullfile(datadir,'phase3_sess9_trials_131005_1409.mat'))
sess9_trialsonly = load(fullfile(datadir,'phase3_sess9_trials_131005_1418.mat'))

clear t stimlist tours trials

t.phase_start = [];
t.savedata = sess9_trialsonly.t.savedata;

stimlist = phase2_complete.stimlist;

tours = phase2_complete.tours;

trials.t = sess9_trialsonly.t;
t_fieldnames = {'fixation','showmap','stim_onset','question','response','feedback'}; % the ones that are different between sess8 and sess9
for ifield = 1:length(t_fieldnames)
    fn = t_fieldnames{ifield};
    eval(['trials.t.' fn '(8) = sess8_trialsonly.t.' fn '(9);'])
end

trials.b = sess9_trialsonly.b;
trials.b.response(8) = sess8_trialsonly.b.response(9);

save(fullfile(datadir,'phase3_complete_postfacto'),'t','stimlist','tours','trials')

phase3_complete = load(fullfile(datadir,'phase3_complete_postfacto'))

%% compile phase4_complete
% compile with phase3_complete

phase4_trialsonly = load(dir_filenames(fullfile(datadir,'phase4_sess13*'),0,1))

clear t stimlist tours trials

t.phase_start = [];
t.savedata = phase4_trialsonly.t.savedata;

stimlist = phase3_complete.stimlist;
stimlist.phase = [1 1 1 1 2 2 2 3 3 4 4 4 4]

tours = phase3_complete.tours;

trials.t = phase4_trialsonly.t;
trials.b = phase4_trialsonly.b;

t_fieldnames = {'fixation','showmap','stim_onset','question','response','feedback'}; % the fields that are missing for sess8
for ifield = 1:length(t_fieldnames)
    fn = t_fieldnames{ifield};
    eval(['trials.t.' fn '(8) = phase3_complete.trials.t.' fn '(8);'])
end

trials.b.response(8) = phase3_complete.trials.b.response(8);

save(fullfile(datadir,'phase4_complete_postfacto'),'t','stimlist','tours','trials')