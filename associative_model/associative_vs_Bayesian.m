%% options

% models
models = {'associative','Bayesian'}; % others to try: 
                                     % associative with recency/primacy effects?
                                     % Bayesian with recency/primacy effects?
nmodels = length(models);

% subjnums
subjnums = setdiff(101:134,[111 128]);
nsubj = length(subjnums);

% fMRI sessions
sess_to_use = 10:13;
nsess = length(sess_to_use);
sesslen = 30;

% longest sequence length
maxseqlen = 6;

% results directory
resultsdir = '../../results/sequence_lengths';
mkdir_ifnotexist(resultsdir);

%% iterate through subjects

% initialize variables
pcorrect = nan(nsubj,nmodels);

for isubj = 1:nsubj
    subjnum = subjnums(isubj) %#ok<NOPTS>
    
    %% load subject data
    % trials, rescorings, stimlist, stim_to_use
    
    % load rescored data
    load(sprintf('../../results/rescore/subj%i',subjnum));
    
    % load likelihoods
    likelihoods = stim_to_use.likelihoods;
    
    %% compute "pcorrect" for both models
    
    for imodel = 1:nmodels
        model = models{imodel};
        
        correct = nan(nsess,sesslen);
        for isess = 1:nsess
            sess = sess_to_use(isess);
            
            for trial = 1:sesslen
            
                % compute the final "posterior"
                animals = stimlist.trials.animals{sess}{trial};
                switch model
                    case 'associative'
                        unnormalized = sum(likelihoods(animals,:),1);
                        posterior = normalize1(unnormalized);
                    case 'Bayesian'
                        unnormalized = prod(likelihoods(animals,:),1);
                        posterior = normalize1(unnormalized);
                end
                
                % compute the correct answer
                question_sectors = stimlist.trials.questions_sectors{sess}(trial,:);
                question_posteriors = posterior(question_sectors);
                question_biggersmaller = stimlist.trials.questions_biggersmaller{sess}(trial);
                answer = 1;
                switch question_biggersmaller
                    case 1
                        if question_posteriors(1) < question_posteriors(2)
                            answer = 2;
                        end
                    case 2
                        if question_posteriors(1) > question_posteriors(2)
                            answer = 2;
                        end
                end
                
                % was the subject correct?
                correct(isess,trial) = (trials.b.response{sess}(trial) == answer);
            end
        end
        pcorrect(isubj,imodel) = mean(correct(:));
    end
end

%% do stats, make figure

model_means = mean(pcorrect,1);
model_SE = std(pcorrect,[],1)/sqrt(nsubj);

[h,p] = ttest(pcorrect(:,1), pcorrect(:,2));

figure
barwitherrors(1:nmodels,model_means,model_SE,'basevalue',0.5)