% Fit the 3-param logistic (with lower and upper asymptotes) to all subjects

%% options

separate_subjplots = 0; % each subj in a separate subfig, or all on top of each other

%% prep

% subjnums
subjnums = setdiff(101:134,[111 128]);
nsubj = length(subjnums);

% path
addpath('helpers')

%% for all options on whichquestions

whichquestions_options = {'all','MAP','nonMAP'};

for iwq = 1:length(whichquestions_options)
    whichquestions = whichquestions_options{iwq};
    
    figure; figuresize('fullscreen')
    for isubj = 1:nsubj
        subjnum = subjnums(isubj);
        
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
        
        
        %% include only MAP vs nonMAP questions, if necessary
        
        if ismember(whichquestions,{'MAP','nonMAP'})
            % figure out which questions are MAP vs nonMAP
            hasMAP = cell(size(correct_new));
            for sess = sess_to_use
                hasMAP{sess} = false(1,sesslengths(sess));
                for itr = 1:sesslengths(sess)
                    posterior = stimlist.posteriors{sess}{itr}(end,:);
                    options = stimlist.questions_sectors{sess}(itr,:);
                    if ismember(max(posterior),posterior(options))
                        hasMAP{sess}(itr) = true;
                    end
                end
            end
            
            % include only MAP/nonMAP from 'rightness' and 'b.response'
            for sess = sess_to_use
                if strcmp(whichquestions,'MAP')
                    include = hasMAP{sess};
                else
                    include = ~hasMAP{sess};
                end
                rightness{sess} = rightness{sess}(include);
                b.response{sess} = b.response{sess}(include);
            end
        end
        
        %% Psychometric curve - "epi" sessions only - p(response=R) vs rightness
        
        if separate_subjplots
            isubplot = isubj;
            subplot_square(nsubj,isubplot); hold on
        else
            hold on
        end
        
        % load data to be fitted (and remove NaNs)
        x = [rightness{epi_sess}]; x = x(:);
        y = [b.response{epi_sess}]-1; y = y(:);
        x = x(~isnan(y));
        y = y(~isnan(y));
        
        % scatter plot
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
        
        % fit the 3-param logistic
        params_init = [0.1, 0, 1]; % [K,a,b]
        lb = [0, -1, -Inf];
        ub = [0.5, 1, Inf];
        params = lsqcurvefit(@logistic_3param,params_init,x,y);
        
        % plot the fitted curve
        xx = linspace(-1,1);
        yfit = logistic_3param(params,xx);
        hold on
        plot(xx,yfit,'-')
        ylim([0 1])
        drawacross('h',0.5')
        drawacross('v',0)
        
        % title
        titlebf(sprintf('SFR%i  K = %2.2f  a = %2.2f  b = %2.1f',...
            subjnum,params(1),params(2),params(3)))
        
        % save subj params
        allsubj{iwq}.K(isubj) = params(1);
        allsubj{iwq}.a(isubj) = params(2);
        allsubj{iwq}.b(isubj) = params(3);
    end
    
    %% histograms of parameter values
    
    figure; isubplot = 0;
    
    % K values
    isubplot = isubplot+1;
    subplot_square(5,isubplot)
    hist(allsubj{iwq}.K)
    titlebf('K (hist)')
    
    % K values
    isubplot = isubplot+1;
    subplot_square(5,isubplot)
    hist(allsubj{iwq}.K(allsubj{iwq}.K > 0))
    set(gca,'xlim',[0,0.5])
    titlebf('K > 0 (hist)')
    
    % a values
    isubplot = isubplot+1;
    subplot_square(5,isubplot)
    hist(allsubj{iwq}.a)
    titlebf('a (hist)')
    
    % b values
    isubplot = isubplot+1;
    subplot_square(5,isubplot)
    hist(allsubj{iwq}.b)
    titlebf('b (hist)')
    
    %% scatterplot -- b vs. K
    
    isubplot = isubplot+1;
    subplot_square(5,isubplot)
    scatter(allsubj{iwq}.K, allsubj{iwq}.b)
    xlabel('K')
    ylabel('b')
    titlebf('b vs. K')
    
    %% save figure
    % saveas(gcf,fullfile(subjplots_dir,'logreg_episess'))
    
end

%% compare parameters for MAP vs. nonMAP

figure
params_to_plot = {'K','a','b'};
for iparam = 1:3
    param = params_to_plot{iparam};
    subplot(1,3,iparam)
    means = eval(sprintf('[mean(allsubj{2}.%s), mean(allsubj{3}.%s)]',param,param));
    SEs = eval(sprintf('[std(allsubj{2}.%s)/sqrt(nsubj), std(allsubj{3}.%s)/sqrt(nsubj)]',param,param));
    barwitherrors([1 2],means,SEs)
    set(gca,'xticklabel',{whichquestions_options{2},whichquestions_options{3}})
    titlebf(param)
end
