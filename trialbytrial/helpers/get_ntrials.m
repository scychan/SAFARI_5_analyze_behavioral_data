function ntrials = get_ntrials(subjnum)
% function ntrials = get_ntrials(subjnum)

if strcmp(subjnum,'all')
    subjnums = get_subjnums;
    nsubj = length(subjnums);
    
    ntrials = nan(1,nsubj);
    for isubj = 1:nsubj
        ntrials(isubj) = get_ntrials(subjnums(isubj));
    end
else
    data = load(sprintf('../../results/rescore/subj%i',subjnum));
    ntrials = sum(~isnan([data.trials.b.response{10:13}]));
end