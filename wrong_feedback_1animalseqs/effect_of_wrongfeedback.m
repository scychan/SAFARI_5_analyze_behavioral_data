%% set up

% params to set
show_indiv_figs = 0;
nboot = 10000;

% subjnums
subjnums = setdiff(101:134,[111 128]);
nsubj = length(subjnums);

% initialize variables to save
allanimals = struct();
byanimal = struct();

%% get data for each subject...

for isubj = 1:nsubj
    
    clearvars -except show_indiv_figs subjnums nsubj allanimals byanimal isubj allanimals byanimal
    
    subjnum = subjnums(isubj)
    
    %% load subject data
    % t, tours, trials, stimlist, stim_to_use
    
    % load rescored data
    load(sprintf('../results/rescore/subj%i',subjnum));
    
    %% Basics
    
    stimlist_master = stimlist;
    stimlist = stimlist.trials;
    t = trials.t;
    b = trials.b;
    
    sess_to_use = find(stimlist_master.tour_or_trials == 2);
    epi_sess = intersect(sess_to_use,find(stimlist_master.phase==4));
    
    likelihoods = stim_to_use.likelihoods;
    nanimals = stim_to_use.nanimals;
    nsectors = stim_to_use.nsectors;
    nsess = length(sess_to_use);
    
    sectors = stimlist.sectors;
    sesslengths = cellfun(@length,stimlist.answers_new);
    
    correct_old = [b.response{sess_to_use}] == [stimlist.answers_old{sess_to_use}];
    correct_new = [b.response{sess_to_use}] == [stimlist.answers_new{sess_to_use}];
    
    trainingsess = find(stimlist_master.phase==3);
    episess = find(stimlist_master.phase==4);
    
    %% wrong feedback related
    
    % which trials had wrong feedback
    wrong_feedback = [stimlist.answers_old{sess_to_use}] ~= [stimlist.answers_new{sess_to_use}];
    
    % correct/incorrect for single-animal trials
    singleanimal = cellfun(@(x) length(x)==1, [stimlist.animals{sess_to_use}]);
    correct_singletrials = correct_new(singleanimal);
    
    %% all animals together
    
    % pcorrect vs. number of wrong feedback -- all trials
    binlabel = cumsum(wrong_feedback);
    bins = unique(binlabel);
    nbins = length(bins);
    binavg_alltrials = nan(1,nbins);
    for ibin = 1:nbins
        binavg_alltrials(ibin) = nanmean(correct_new(binlabel == bins(ibin)));
    end
    if show_indiv_figs
        figure; plot(unique(binlabel),binavg_alltrials)
        xlabel('number of wrong feedback')
        ylabel('pcorrect')
        pause
    end
    allanimals(isubj).numwf = unique(binlabel);
    allanimals(isubj).pcorrect.alltrials = binavg_alltrials;
    
    % pcorrect vs. number of wrong feedback -- single animal trials
    binlabel_singletrials = binlabel(singleanimal);
    binavg_singletrials = nan(1,nbins);
    for ibin = 1:nbins
        binavg_singletrials(ibin) = nanmean(correct_singletrials(binlabel_singletrials == (ibin-1)));
    end
    if show_indiv_figs
        figure; plot(unique(binlabel),binavg_singletrials)
        xlabel('number of wrong feedback')
        ylabel('pcorrect')
        pause
    end
    allanimals(isubj).pcorrect.singletrials = binavg_singletrials;
    
    % cumulative correct on wrong feedback trials
    correct_wrongfeedbacktrials = correct_new(wrong_feedback);
    cumcorrect_wrongfeedbacktrials = cumsum(2*correct_wrongfeedbacktrials-1);
    if show_indiv_figs
        figure; plot(cumcorrect_wrongfeedbacktrials)
        hold on; drawacross('h',0)
        xlabel('number of wrong feedback')
        ylabel('cumulative correct')
        pause
    end
    allanimals(isubj).cumcorrect.wftrials = cumcorrect_wrongfeedbacktrials;
    
    % change in performance
    % -- (1) all trials (2) single animal trials
    % -- (a) first block vs last block (2) first half vs last half
    blocks.alltrials = {1:40, 121:160};
    halves.alltrials = {1:80, 81:160};
    blocks.singleanimal = {find(singleanimal(blocks.alltrials{1})), find(singleanimal(blocks.alltrials{2}))};
    halves.singleanimal = {find(singleanimal(halves.alltrials{1})), find(singleanimal(halves.alltrials{2}))};
    deltaperf.alltrials.blocks = nanmean(correct_new(blocks.alltrials{2})) - nanmean(correct_new(blocks.alltrials{1}));
    deltaperf.alltrials.halves = nanmean(correct_new(halves.alltrials{2})) - nanmean(correct_new(halves.alltrials{1}));
    deltaperf.singletrials.blocks = nanmean(correct_new(blocks.singleanimal{2})) - nanmean(correct_new(blocks.singleanimal{1}));
    deltaperf.singletrials.halves = nanmean(correct_new(halves.singleanimal{2})) - nanmean(correct_new(halves.singleanimal{1}));
    allanimals(isubj).deltaperf = deltaperf;
    
    %% evaluate performance/feedback for each animal separately
    
    % get the animal for different trial types
    animals = [stimlist.animals{:}]; % all trials
    singletrials_animal = [animals{singleanimal}];
    wftrials_animal = [animals{wrong_feedback}];
    
    % pcorrect vs. num wrong feedback 
    % -- single animal trials
    % -- all trials containing that animal
    % -- all trials containing that animal, except single animal trials
    animal_numwf = nan(1,nanimals);
    animal_pcorrect_singletrials = nan(1,nanimals);
    animal_pcorrect_alltrials = nan(1,nanimals);
    animal_pcorrect_nonsingletrials = nan(1,nanimals);
    for ianimal = 1:nanimals
        animal_numwf(ianimal) = sum(wftrials_animal == ianimal);
        
        animal_pcorrect_singletrials(ianimal) = nanmean(correct_singletrials(singletrials_animal == ianimal));
        
        animal_trials = cellfun(@(x) ismember(ianimal,x), [stimlist.animals{:}]);
        animal_pcorrect_alltrials(ianimal) = nanmean(correct_new(animal_trials));
        
        animal_nonsingletrials = animal_trials & ~singleanimal;
        animal_pcorrect_nonsingletrials(ianimal) = nanmean(correct_new(animal_nonsingletrials));
    end
    if show_indiv_figs
        figure; scatter(animal_numwf,animal_pcorrect_singletrials)
        figure; scatter(animal_numwf,animal_pcorrect_alltrials)
        figure; scatter(animal_numwf,animal_pcorrect_nonsingletrials)
        pause
    end
    byanimal(isubj).numwf = animal_numwf;
    byanimal(isubj).pcorrect.singletrials = animal_pcorrect_singletrials;
    byanimal(isubj).pcorrect.alltrials = animal_pcorrect_alltrials;
    byanimal(isubj).pcorrect.nonsingletrials = animal_pcorrect_nonsingletrials;
    
    % deltaperf vs. num wrong feedback 
    % (1) all trials containing that animal (2) nonsingle trials
    % (a) first block vs last block (b) first half vs last half
    blocks.nonsingle = {find(~singleanimal(blocks.alltrials{1})), find(singleanimal(blocks.alltrials{2}))};
    halves.nonsingle = {find(~singleanimal(halves.alltrials{1})), find(singleanimal(halves.alltrials{2}))};
    clear deltaperf
    for ianimal = 1:nanimals
        animal_trials = find(cellfun(@(x) ismember(ianimal,x), [stimlist.animals{:}]));
        
        perf1 = nanmean(correct_new(intersect(animal_trials,blocks.alltrials{1})));
        perf2 = nanmean(correct_new(intersect(animal_trials,blocks.alltrials{2})));
        deltaperf.alltrials.blocks(ianimal) = perf2 - perf1;
        
        perf1 = nanmean(correct_new(intersect(animal_trials,halves.alltrials{1})));
        perf2 = nanmean(correct_new(intersect(animal_trials,halves.alltrials{2})));
        deltaperf.alltrials.halves(ianimal) = perf2 - perf1;
        
        animal_trials = find(cellfun(@(x) ismember(ianimal,x), [stimlist.animals{:}]));
        perf1 = nanmean(correct_new(intersect(animal_trials,blocks.nonsingle{1})));
        perf2 = nanmean(correct_new(intersect(animal_trials,blocks.nonsingle{2})));
        deltaperf.nonsingle.blocks(ianimal) = perf2 - perf1;
        
        perf1 = nanmean(correct_new(intersect(animal_trials,halves.nonsingle{1})));
        perf2 = nanmean(correct_new(intersect(animal_trials,halves.nonsingle{2})));
        deltaperf.nonsingle.halves(ianimal) = perf2 - perf1;
    end
    byanimal(isubj).deltaperf = deltaperf;
    
    %% close figures
    close all
    
end

%% compile across subjects

% across subjects -- pcorrect vs total numwf
numwf_total = nan(1,nsubj);
pcorrect_total = nan(1,nsubj);
for isubj = 1:nsubj
    numwf_total(isubj) = sum(byanimal(isubj).numwf);
    pcorrect_total(isubj) = dot(byanimal(isubj).pcorrect.alltrials, byanimal(isubj).numwf) / numwf_total(isubj);
end
[rho,pval] = corr(numwf_total',pcorrect_total');
figure; scatter(numwf_total,pcorrect_total,'r')
xlabel('numwf_total')
ylabel('pcorrect_total')
title(sprintf('rho = %1.2g   p = %1.2g',rho,pval))

% across subjects -- deltaperf vs total numwf
numwf_total = nan(1,nsubj);
deltaperf = nan(4,nsubj);
for isubj = 1:nsubj
    numwf_total(isubj) = sum(byanimal(isubj).numwf);
    deltaperf(1,isubj) = allanimals(isubj).deltaperf.alltrials.blocks;
    deltaperf(2,isubj) = allanimals(isubj).deltaperf.alltrials.halves;
    deltaperf(3,isubj) = allanimals(isubj).deltaperf.singletrials.blocks;
    deltaperf(4,isubj) = allanimals(isubj).deltaperf.singletrials.halves;
end
[rhos, pvals] = corr(numwf_total',deltaperf');
figure; 
for i = 1:4, 
    subplot(2,2,i)
    scatter(numwf_total,deltaperf(i,:),'r')
    xlabel('numwf_total')
    ylabel('pcorrect_total')
    title(sprintf('rho = %1.2g   p = %1.2g',rhos(i),pvals(i)))
end

% compute correlations within each subject -- pcorrect vs numwf, for each animal
animal_rho.alltrials = nan(1,nsubj);
animal_rho.singletrials = nan(1,nsubj);
animal_rho.nonsingletrials = nan(1,nsubj);
for isubj = 1:nsubj
    animal_rho.alltrials(isubj) = corr(byanimal(isubj).numwf', byanimal(isubj).pcorrect.alltrials');
    animal_rho.singletrials(isubj) = corr(byanimal(isubj).numwf', byanimal(isubj).pcorrect.singletrials');
    animal_rho.nonsingletrials(isubj) = corr(byanimal(isubj).numwf', byanimal(isubj).pcorrect.nonsingletrials');
end
% all trials
figure; hist(animal_rho.alltrials)
fprintf('mean rho -- alltrials = %0.3g \n',mean(animal_rho.alltrials))
[~, pval] = ttest(animal_rho.alltrials);
fprintf('pval -- alltrials = %0.3g \n',pval)
% single trials
figure; hist(animal_rho.singletrials)
fprintf('mean rho -- singletrials = %0.3g \n',mean(animal_rho.singletrials))
[~, pval] = ttest(animal_rho.singletrials);
fprintf('pval -- singletrials = %0.3g \n',pval)
% nonsingle trials
figure; hist(animal_rho.nonsingletrials)
fprintf('mean rho -- nonsingletrials = %0.3g \n',mean(animal_rho.nonsingletrials))
[~, pval] = ttest(animal_rho.nonsingletrials);
fprintf('pval -- nonsingletrials = %0.3g \n',pval)

% compute correlations within each subject -- deltaperf vs numwf, for each animal
deltaperf_rhos = nan(4,nsubj);
for isubj = 1:nsubj
    deltaperf_subj = nan(4,nanimals);
    deltaperf_subj(1,:) = byanimal(isubj).deltaperf.alltrials.blocks;
    deltaperf_subj(2,:) = byanimal(isubj).deltaperf.alltrials.halves;
    deltaperf_subj(3,:) = byanimal(isubj).deltaperf.nonsingle.blocks;
    deltaperf_subj(4,:) = byanimal(isubj).deltaperf.nonsingle.halves;
    deltaperf_rhos(:,isubj) = corr(byanimal(isubj).numwf',deltaperf_subj');
end
figure
for i = 1:4
    subplot(2,2,i); hold on
    hist(deltaperf_rhos(i,:))
    drawacross('v')
    [~,p] = ttest(deltaperf_rhos');
    title(sprintf('p = %1.2g',p(i)))
end
equalize_subplot_axes('xy',gcf,2,2)

%% save the results