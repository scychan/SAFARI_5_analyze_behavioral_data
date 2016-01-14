%% load the estimates

load('../results/likelihood_estimates/allsubj')

nsubj = length(subjnums);
[nanimal, nsector] = size(estimates{1});

%% normalize the estimates to sum to 1

normalized = nan(nanimal,nsector,nsubj);
for isubj = 1:nsubj
    normalized(:,:,isubj) = normalize1(estimates{isubj},'c');
end

%% plot the means

means = mean(normalized,3);
SE = std(normalized,0,3)/sqrt(nsubj);

figure
for sector = 1:nsector
    subplot(nsector,1,sector)
    barwitherrors(1:nanimal,means(:,sector),SE(:,sector))
    set(gca,'ylim',[0 0.5])
end