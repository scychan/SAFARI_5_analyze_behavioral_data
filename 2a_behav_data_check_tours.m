
clear all
close all

%%

subjnum = 102;

%% load behavioral data
% t, tours, trials, stimlist, stim_to_use

subj.subjnum = subjnum;

% subject's resultsdir
resultsdir = sprintf('../4_fMRI_subjects/data_fmri/subj%i',subjnum);

% load phase4_complete
load(dir_filenames(fullfile(resultsdir,'phase4_complete*'),0,1))

% load stimlist, stim_to_use
load(dir_filenames(fullfile(resultsdir,'stimlist*'),0,1))

%% directory for saving resulting plots

subjplots_dir = fullfile('analyze_tours','subject_summaries',sprintf('subj%i',subjnum));
mkdir(subjplots_dir)

%% basics

stimlist_master = stimlist;
t_master = t;
stimlist = stimlist.tours;
t = tours.t;
b = tours.b;

if ~exist('sess_to_use')
    sess_to_use = find(stimlist_master.tour_or_trials == 1);
end
tours_to_use_temp = repmat((stimlist_master.tour_or_trials==1)',1,4);
tours_to_use = logical(zeros(size(tours_to_use_temp)));
tours_to_use(sess_to_use,:) = tours_to_use_temp(sess_to_use,:);

likelihoods = stim_to_use.likelihoods;
nanimals = stim_to_use.nanimals;
nsectors = stim_to_use.nsectors;
ntours = nsectors * length(sess_to_use);
nsess = length(sess_to_use);

sectors = stimlist.sectors;

pcorrect_eachtour = nan(size(b.response));
correct = cell(size(tours_to_use));
RTs = cell(size(tours_to_use));
for sess = sess_to_use
    for isector = 1:nsectors
        correct{sess,isector} = b.response{sess,isector}==stimlist.answers{sess,isector};
        pcorrect_eachtour(sess,isector) = mean(correct{sess,isector});

        RTs{sess,isector} = t.response{sess,isector} - t.question{sess,isector};
    end
end

day1sess = find(stimlist_master.phase==1);
day2sess = find(stimlist_master.phase==2);

subj.sess_to_use = sess_to_use;
subj.tours_to_use = tours_to_use;

%% sector order
% 'out of order' sessions suitably out of order?

disp(sectors)

%% Stimuli presented
% Were they in the right proportions?

% stimuli presented
figure; figuresize('fullscreen')
for sector = 1:nsectors
    sector_tours = find(sectors==sector & tours_to_use);
    ntours_in_sector = length(sector_tours);
    
    for itour = 1:length(sector_tours)
        tour = sector_tours(itour);
        [sess sess_tournum] = ind2sub(size(sectors),tour);
        tourlen = length(stimlist.animals{tour});
        
        proportions = hist(stimlist.animals{tour},1:nanimals);
        right_proportions = tourlen*likelihoods(:,sector);
        
        subplot_ij(nsectors,ntours/nsectors,sess_tournum,sess)
        bar([right_proportions(:) proportions(:)])
        title(sprintf('sess %i - tour %i - sector %i',sess,sess_tournum,sector))
    end
end


%% Check within the pseudorandom blocks

binsize = 10;

figure; figuresize('fullscreen');
for isess = 1:length(sess_to_use)
    sess = sess_to_use(isess);
    for isector = 1:nsectors
        sector = sectors(sess,isector);
        tourlen = length(stimlist.animals{sess,isector});
        
        x = reshape(stimlist.animals{sess,isector},binsize,tourlen/binsize);
        proportions = hist(x,1:5);
        if isvector(proportions), proportions = proportions(:); end
        
        correct_proportions = binsize*likelihoods(:,sector);
        
        subplot_ij(length(sess_to_use),nsectors,isess,isector)
        bar([correct_proportions(:) proportions])
        title(sprintf('Sess %i - Sector %i',sess,sectors(sess,isector)))
    end
end
legend('correct proportions','bin1','bin2','bin3','bin4','bin5','bin6')
saveas(gcf,fullfile(subjplots_dir,'stimuli_proportions_withinbins'))

%% Look at their choices over time

figure; figuresize('fullscreen')
string_lengths = [];

for isess = 1:nsess
    sess = sess_to_use(isess);
    for isector = 1:nsectors
        subplot_ij(nsess,nsectors,isess,isector)
        tour_responses = b.response{sess,isector}-1.5;
        tour_responses(isnan(tour_responses)) = 0;
        plot(cumsum(tour_responses),'x-')
        title(sprintf('Sess %i - Sector %i',sess,sectors(sess,isector)))
        hold on; drawacross('h',0)
        
        len_1strings = repeated_elements(b.response{sess,isector},1);
        len_2strings = repeated_elements(b.response{sess,isector},2);
        string_lengths = [string_lengths len_1strings len_2strings];
    end
end
equalize_subplot_axes('y',gcf,nsess,nsectors,'r')
saveas(gcf,fullfile(subjplots_dir,'choices_over_time'))

figure
hist(string_lengths,1:max(string_lengths))
title(sprintf('mean length = %2.2f, max length = %i',mean(string_lengths),max(string_lengths)))
saveas(gcf,fullfile(subjplots_dir,'choices_repeatedstrings'))

subj.keystrokes_meanstrlen = mean(string_lengths);
subj.keystrokes_maxstrlen = max(string_lengths);

%% How would they do if they were performing optimally, for each sector?
% for tours of infinite length

optimal_performance = zeros(1,nsectors);
for isector = 1:nsectors
    sector_likelihoods = likelihoods(:,isector);
    for ianimal = 1:nanimals
        optimal_performance(isector) = optimal_performance(isector) + ...
            sector_likelihoods(ianimal)*1/4*sum(sector_likelihoods(ianimal) > sector_likelihoods);
    end
end
subj.optimal_performance = optimal_performance;


%% Percent correct on each tour (separately for each sector)

pcorrect_eachsector_eachtour = nan(nsectors,sess_to_use(end));
for isess = 1:nsess
    sess = sess_to_use(isess);
    for isector = 1:nsectors
        sector = sectors(sess,isector);
        pcorrect_eachsector_eachtour(sector,sess) = pcorrect_eachtour(sess,isector);
    end
end

figure; figuresize('wide')
bar([optimal_performance' pcorrect_eachsector_eachtour])
legend('Optimal','Round 1','Round 2','Round 3','Round 4','Round 5','Round 6','Round 7')
hold on; drawacross('h',0.5,'--')
xlabel('Sector')
ylabel('Percent correct')
ylim([0 1])
saveas(gcf,fullfile(subjplots_dir,'pcorrect'))

subj.pcorrect = pcorrect_eachsector_eachtour;


%% What is the optimal response for each question?

optimum = cell(size(correct));
optimal = cell(size(correct));
for isess = 1:nsess
    sess = sess_to_use(isess);
    for isector = 1:nsectors
        sector = sectors(sess,isector);
        sector_likelihoods = likelihoods(:,sector);
        questions = stimlist.questions{sess,isector};
        for q = 1:length(questions)
            [temp optimum{sess,isector}(q)] = max(sector_likelihoods(questions(q,:)));
        end
        
        optimal{sess,isector} = b.response{sess,isector}==optimum{sess,isector};
    end
end

%% Look at optimal/nonoptimal, over time

figure; figuresize('fullscreen')
for isess = 1:nsess
    sess = sess_to_use(isess);
    for isector = 1:nsectors
        sector = sectors(sess,isector);
        subplot_ij(nsess,nsectors,isess,sector)
        tour_optimals = optimal{sess,isector}-0.5;
        plot(cumsum(tour_optimals))
        title(sprintf('Sess %i - Sector %i',sess,sector))
        hold on; drawacross('h',0)
    end
end
equalize_subplot_axes('y',gcf,nsess,nsectors,'r')
saveas(gcf,fullfile(subjplots_dir,'poptimal_over_time'))

%% Percent optimal on each tour (separately for each sector)

poptimal_eachtour = cellfun(@mean,optimal);

figure; figuresize('wide')
temp = poptimal_eachtour';
bar(temp(:))
hold on; drawacross('h',0.5,'--')
xlabel('Tournum')
ylabel('Percent optimal')

poptimal_eachsector_eachtour = nan(nsectors,sess_to_use(end));
for isess = 1:nsess
    sess = sess_to_use(isess);
    for isector = 1:nsectors
        sector = sectors(sess,isector);
        poptimal_eachsector_eachtour(sector,sess) = poptimal_eachtour(sess,isector);
    end
end

figure; figuresize('wide')
bar(poptimal_eachsector_eachtour)
legend('Tour 1','Tour 2','Tour 3','Tour 4')
hold on; drawacross('h',0.5,'--')
xlabel('Sector')
ylabel('Percent optimal')
ylim([0 1])
saveas(gcf,fullfile(subjplots_dir,'poptimal'))

subj.poptimal = poptimal_eachsector_eachtour;

%% Average percent optimal

disp('mean poptimal for each sector')
disp(nanmean(poptimal_eachsector_eachtour,2))

disp('poptimal - average across sectors and tours')
nanmean(poptimal_eachsector_eachtour(:))

disp('poptimal - day1 average')
mean(nanmean(poptimal_eachsector_eachtour(:,day1sess),2))

disp('poptimal - day2 average')
mean(nanmean(poptimal_eachsector_eachtour(:,day2sess),2))

%% Fine-grained learning curves: Percent optimal

bins = [5 10];

if 0
for ibin = 1:length(bins)
    bin = bins(ibin);
    figure; figuresize('fullscreen')
    for sector = 1:nsectors
        [sector_sess, sector_tours] = find(tours_to_use & sectors==sector);
        sector_tours = sortAbyv(sector_tours,sector_sess);
        sector_sess = sort(sector_sess);
        optimal_concat = [];
        for itour = 1:length(sector_tours)
            optimal_concat = [optimal_concat optimal{sector_sess(itour),sector_tours(itour)}];
        end
        nbins = length(optimal_concat)/bin;
        optimal_binned = reshape(optimal_concat,bin, nbins);
        learning_curves = mean(optimal_binned,1);

        subplot(1,nsectors,sector); plot(learning_curves,'d-')
        set(gca,'ylim',[0 1])
        set(gca,'xlim',[0 nbins+1])
        hold on;
        last_tour_binend = 0.5;
        for itour = 1:length(sector_tours)
            tour_length = length(optimal{sector_sess(itour),sector_tours(itour)});
            last_tour_binend = last_tour_binend + tour_length/bin;
            drawacross('v',last_tour_binend)
        end
        drawacross('h',0.5,'--')
        ylabel('Percent optimal')
        set(gca,'xtick',nbins*(0:length(sector_tours)-1) + (nbins+1)/2,...
            'xticklabel',1:length(sector_tours))
        xlabel('tour')
        title(sprintf('Sector %i',sector))
    end
    
    subj.poptimal_binned{ibin}.binsize = bin;
    subj.poptimal_binned{ibin}.learning_curves = learning_curves;
end
end


%% Difficulty level for each question 
% (the difference in likelihoods between the two choices)

easiness = cell(size(correct));
for isess = 1:nsess
    sess = sess_to_use(isess);
    for isector = 1:nsectors
        sector = sectors(sess,isector);
        sector_likelihoods = likelihoods(:,sector);
        questions = stimlist.questions{sess,isector};
        for q = 1:length(questions)
            easiness{sess,isector}(q) = diff(sector_likelihoods(questions(q,:)));
        end
    end
end

%% Psychometric curves (logistic regression) - presponse vs easiness - by tour
% label the sectors

subj.logreg_b1 = nan(nsectors,tours_to_use(end)/nsectors);
subj.logreg_b2 = nan(nsectors,tours_to_use(end)/nsectors);
numintercept = 0;

figure; figuresize('fullscreen')
for sector = 1:nsectors
    [sector_sess, sector_tours] = find(tours_to_use & sectors==sector);
    sector_tours = sortAbyv(sector_tours,sector_sess);
    sector_sess = sort(sector_sess);
    ntours_in_sector = length(sector_tours);
    
    for itour = 1:ntours_in_sector
        
        sess = sector_sess(itour);
        isector = sector_tours(itour);
        subplot_ij(sess_to_use(end),nsectors,sess,sector)
        hold on
        
        % scatter plot
        x = easiness{sess,isector}; x = [x(:); zeros(numintercept,1)];
        y = b.response{sess,isector} - 1; y = [y(:); 0.5*ones(numintercept,1)];
        %plot(x,y,'k.')
        
        % scatter plot - binned
        [counts ymeans ystds bincenters] = bincount(x,y,-0.5:0.05:0.5)
        plot(bincenters,ymeans,'md')
        %errorbar(bincenters,ymeans,ystds./sqrt(counts))
        drawacross('h',0.5')
        drawacross('v',0)
        
        % logistic regression
        [b_lr,dev,stats] = glmfit(x,y,'binomial','link','logit');
        xx = linspace(-0.5,0.5);
        yfit = glmval(b_lr,xx,'logit');
        hold on
        plot(xx,yfit,'-')
        set(gca,'xlim',[-0.5 0.5])
        ylabel('P(''R'')')
        xlabel('likelihood(R) - likelihood(L)')
        
        % title
        title(sprintf('Sector %i - slope %2.2f',sector,b_lr(2)))
        
        if numintercept==0
            subj.logreg_b1(sector,sess) = b_lr(1);
            subj.logreg_b2(sector,sess) = b_lr(2);
        else
            subj.logreg_forceintercept_b1(sector,sess) = b_lr(1);
            subj.logreg_forceintercept_b2(sector,sess) = b_lr(2);
        end
    end
end
saveas(gcf,fullfile(subjplots_dir,'logreg_bytour'))

%% Psychometric curves (logistic regression) - presponse vs easiness - collapse all four sectors

subj.logreg_acrosssectors_b1 = nan(1,tours_to_use(end)/nsectors);
subj.logreg_acrosssectors_b2 = nan(1,tours_to_use(end)/nsectors);
numintercept = 0;

figure; figuresize('fullscreen')
rounds = unique(ceil(tours_to_use/nsectors));
for sess = sess_to_use
    
    subplot_square(sess_to_use(end),sess)
    
    % scatter plot
    x = [easiness{sess,:}]; x = [x(:); zeros(numintercept,1)];
    y = [b.response{sess,:}] - 1; y = [y(:); 0.5*ones(numintercept,1)];
    plot(x,y,'rd')
    
    % scatter plot - binned
    [counts ymeans ystds bincenters] = bincount(x(:),y(:),-0.5:0.05:0.5)
    plot(bincenters,ymeans,'md')
    %                 errorbar(bincenters,ymeans,ystds./sqrt(counts))
    
    % logistic regression
    [b_lr,dev,stats] = glmfit(x,y,'binomial','link','logit');
    xx = linspace(-0.5,0.5);
    yfit = glmval(b_lr,xx,'logit');
    hold on
    plot(xx,yfit,'-')
    ylabel('P(''R'')')
    xlabel('likelihood(R) - likelihood(L)')
    ylim([0 1])
    drawacross('h',0.5')
    drawacross('v',0)
    
    title(sprintf('Sess %i - Tour lengths %i - slope %2.2f',sess,length(b.response{sess,1}),b_lr(2)))
    
    if numintercept==0
        subj.logreg_acrosssectors_b1(sess) = b_lr(1);
        subj.logreg_acrosssectors_b2(sess) = b_lr(2);
    else
        subj.logreg_acrosssectors_forceintercept_b1(sess) = b_lr(1);
        subj.logreg_acrosssectors_forceintercept_b2(sess) = b_lr(2);
    end
end

saveas(gcf,fullfile(subjplots_dir,'logreg_acrosssectors'))

%% Psychometric curves (logistic regression) - presponse vs easiness - collapse all data

subj.logreg_alldata_b1 = nan;
subj.logreg_alldata_b2 = nan;
numintercept = 0;

figure

% scatter plot
x = [easiness{:}]; x = [x(:); zeros(numintercept,1)];
y = [b.response{:}] - 1; y = [y(:); 0.5*ones(numintercept,1)];
plot(x,y,'rd')

% scatter plot - binned
[counts ymeans ystds bincenters] = bincount(x(:),y(:),-0.5:0.05:0.5)
plot(bincenters,ymeans,'md')
%                 errorbar(bincenters,ymeans,ystds./sqrt(counts))

% logistic regression
[b_lr,dev,stats] = glmfit(x,y,'binomial','link','logit');
xx = linspace(-0.5,0.5);
yfit = glmval(b_lr,xx,'logit');
hold on
plot(xx,yfit,'-')
ylabel('P(''R'')')
xlabel('likelihood(R) - likelihood(L)')
ylim([0 1])
drawacross('h',0.5')
drawacross('v',0)

title(sprintf('Sess %i - Tour lengths %i - b1 %2.2f - b2 %2.2f',sess,length(b.response{sess,1}),b_lr(1),b_lr(2)))

subj.logreg_alldata_b1 = b_lr(1);
subj.logreg_alldata_b2 = b_lr(2);

saveas(gcf,fullfile(subjplots_dir,'logreg_alldata'))

%% RTs on each tour (separately for each sector)

RTs_eachtour = cellfun(@nanmean,RTs);

figure;
bar(RTs_eachtour(sess_to_use,:))
set(gca,'xticklabel',sess_to_use)
xlabel('Session')
ylabel('Reaction time (secs)')
title(sprintf('mean RT = %2.3f',nanmean([RTs{sess_to_use,:}])))

RTs_eachsector_eachtour = nan(nsectors,nsess);
for sess = sess_to_use
    for isector = 1:nsectors
        sector = sectors(sess,isector);
        RTs_eachsector_eachtour(sector,sess) = RTs_eachtour(sess,isector);
    end
end

figure;
bar(RTs_eachsector_eachtour)
legend('Tour 1','Tour 2')
xlabel('Sector')
ylabel('RTs')
saveas(gcf,fullfile(subjplots_dir,'RTs_bysector'))

subj.RTs = RTs_eachsector_eachtour;

%% experiment timing

for phase = 1:4
    fname = sprintf('phase%i_complete*',phase);
    
    subjfilename = dir_filenames(fullfile(resultsdir,fname));
    
    if ~isempty(subjfilename)
        load(fullfile(resultsdir,subjfilename))
        
        % phase length
        minutes_phase(phase) = (t.savedata - t.phase_start)/60;
    end
end

figure; bar(minutes_phase)
set(gca,'xticklabel',minutes_phase)

subj.phaselen_minutes = minutes_phase;

%% save the subject summary

results_dir = fullfile('analyze_tours','subject_summaries');

save(fullfile(results_dir,sprintf('subj%i_tours',subjnum)),'subj')

