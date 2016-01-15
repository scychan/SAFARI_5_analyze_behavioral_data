
%% actual likelihoods

likelihoods = [ 0.1141    0.2617    0.2571    0.4563
                0.1748    0.0778    0.1441    0.2774
                0.0735    0.0677    0.1222    0.0166
                0.3690    0.2181    0.2522    0.0271
                0.2686    0.3747    0.2244    0.2226];  % P(animal|sector)

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
    subplot(nsector,1,sector); hold on
    for animal = 1:nanimal
        bar(likelihoods(:,sector))
        errorbar(1:nanimal,means(:,sector),SE(:,sector))
%         if means(animal,sector) > likelihoods(:,sector)
%             barwitherrors(animal,means(animal,sector),SE(animal,sector))
%             bar(likelihoods(animal,sector))
%         else
%             bar(likelihoods(animal,sector))
%             barwitherrors(animal,means(animal,sector),SE(animal,sector))
%         end
    end
    set(gca,'ylim',[0 0.5])
end