%% options

% subjnums
subjnums = setdiff(101:134,[111 128]);
nsubj = length(subjnums);

% fMRI sessions
sess_to_use = 10:13;
nsess = length(sess_to_use);

% longest sequence length
maxseqlen = 6;

% results directory
resultsdir = '../../results/sequence_lengths';
mkdir_ifnotexist(resultsdir);

%% iterate through subjects

% initialize
allsess_meanacc_old = nan(nsubj,maxseqlen);
allsess_meanacc_new = nan(nsubj,maxseqlen);
bysess_meanacc_old = nan(nsubj,nsess,maxseqlen);
bysess_meanacc_new = nan(nsubj,nsess,maxseqlen);

for isubj = 1:nsubj
    subjnum = subjnums(isubj);
    
    %% load subject data
    % trials, rescorings, stimlist, stim_to_use
    
    % load rescored data
    load(sprintf('../../results/rescore/subj%i',subjnum));
    
    %% separate correct/incorrect by seqlen
    
    binned_old = cell(nsess,maxseqlen);
    binned_new = cell(nsess,maxseqlen);
    
    for isess = 1:nsess
        sess = sess_to_use(isess);
        
        % get 'correct', for both old and new answer
        sess_responses = trials.b.response{sess};
        sess_answers_old = stimlist.trials.answers_old{sess};
        sess_answers_new = stimlist.trials.answers_new{sess};
        sess_correct_old = (sess_responses == sess_answers_old);
        sess_correct_new = (sess_responses == sess_answers_new);
        
        % get seqlens
        sess_seqlens = stimlist.trials.lengths{sess};
        
        for l = 1:maxseqlen
            binned_old{isess,l} = sess_correct_old(sess_seqlens == l);
            binned_new{isess,l} = sess_correct_new(sess_seqlens == l);
        end
    end
    
    %% accuracy vs seqlen -- all sessions
    
    % compile sessions together
    for l = 1:maxseqlen
        allsess_binned_old{l} = [binned_old{:,l}]; %#ok<SAGROW>
        allsess_binned_new{l} = [binned_new{:,l}]; %#ok<SAGROW>
    end

    % get mean accuracy for each seqlen
    allsess_meanacc_old(isubj,:) = cellfun(@mean,allsess_binned_old);
    allsess_meanacc_new(isubj,:) = cellfun(@mean,allsess_binned_new);
    
    %% accuracy vs seqlen -- per session
    
    bysess_meanacc_old(isubj,:,:) = cellfun(@mean,binned_old);
    bysess_meanacc_new(isubj,:,:) = cellfun(@mean,binned_new);
    
end

%% aggregate over subjects -- all sessions

figure

subplot(121)
barmeans = mean(allsess_meanacc_old);
barSE = std(allsess_meanacc_old)/sqrt(nsubj);
barwitherrors(1:maxseqlen,barmeans,barSE)
xlabel('seqlen')
ylabel('p correct')
title('some incorrect feedback for seqlen 1')

subplot(122)
barmeans = mean(allsess_meanacc_new);
barSE = std(allsess_meanacc_new)/sqrt(nsubj);
barwitherrors(1:maxseqlen,barmeans,barSE)
xlabel('seqlen')
ylabel('p correct')
title('correct feedback')

saveas(gcf,fullfile(resultsdir,'accuracy_vs_seqlen__allsess'))

%% aggregate over subjects -- by session

figure; figuresize('long')

for isess = 1:nsess
    
    subplot_ij(nsess,2,isess,1)
    barmeans = squeeze(nanmean(bysess_meanacc_old(:,isess,:)));
    barSE = squeeze(nanstd(bysess_meanacc_old(:,isess,:),[],1))/sqrt(nsubj);
    barwitherrors(1:maxseqlen,barmeans,barSE)
    xlabel('seqlen')
    ylabel('p correct')
    title('some incorrect feedback for seqlen 1')
    
    subplot_ij(nsess,2,isess,2)
    barmeans = squeeze(nanmean(bysess_meanacc_new(:,isess,:)));
    barSE = squeeze(nanstd(bysess_meanacc_new(:,isess,:),[],1))/sqrt(nsubj);
    barwitherrors(1:maxseqlen,barmeans,barSE)
    xlabel('seqlen')
    ylabel('p correct')
    title('correct feedback')
end

saveas(gcf,fullfile(resultsdir,'accuracy_vs_seqlen__bysess'))
