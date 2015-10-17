
==== PROCEDURE ====

1. run_all_subjs(modelname,ninit)   OR   run_all_subj.sh
2. compile_inits (only for those with initializations run separately)
3. compile_subjs
4. compare_models

==== FILES TO UPDATE WHEN ADDING A NEW MODEL ====

1. run_model.m
2. get_nparams.m
3. readme.txt
4. run_all_subjs.sh
5. compare_models.m

==== MODELS AVAILABLE ====

- Bayesian 
    Optimal Bayesian inference, with softmax on the posteriors.
    params: (1) softmax_beta

- logBayesian
    Instead of softmax on the posteriors, we use a softmax on the *log* posteriors. 
    This was inspired by the model used in the Shadlen 2007 paper. 
    In this case, a softmax beta of 1 implies that they are perfectly probability matching.
    params: (1) softmax_beta

- Bayesian_recencyprimacy
    Same as "Bayesian", but with an exponential weightings on likelihoods, 
    to capture recency and primacy effects.
    params: (1) softmax_beta (2) w.recency (3) w.primacy

- Bayesian_recencyprimacy_sameweight
    Same as "Bayesian_recencyprimacy", but with the same weighting for both
    recency and primacy effects.
    params: (1) softmax_beta (2) w.recencyprimacy

- Bayesian_recency, Bayesian_primacy
    Same as "Bayesian_recencyprimacy", but only recency OR primacy effects
    params: (1) softmax_beta (2) w.recency/w.primacy

- mostleast_voter
    This model assumes that subjects are only paying attention to which animals were 
    most common and least common in each sector. During the trials, each animal appearance 
    "votes" for (or against) the sectors in which it is the most common (or least common). 
    For ties, include all the ones that are tied.
    NB: minPvote doesn't make sense, because the min is always animal 3, esp when using the real likelihoods
    params: (1) minPvote (2) maxPvote

- mostleast2_voter
    Same as mostleast_voter, but assumes subjects keep track of which were the TWO 
    most common and least common in each sector. During the trials, each animal appearance 
    "votes" for (or against) the sectors in which it is the most common (or least common). 
    NB: mostleast_voter for just one animal didn't make sense, because the min is always animal 3
    params: (1) minPvote (2) maxPvote

- mostP_voter
    Same as mostleast_voter, except only vote for the maxPanimals
    (It didn't really make sense to include minPvote. See above)
    params: (1) maxPvote

- most2_voter, least2_voter
    Same as mostleast2_voter, except only vote for the max/min animals.
    params: (1) max/minPvote

- additive
    Instead of multiplying likelihoods together to get posterior, add them together.
    params: (1) softmax_beta

- feedbackRL
    Bump likelihoods up or down, depending on how much they contributed correctly/incorrectly to the answer.
    NB: this is a superset of 'Bayesian'
    params: (1) softmax_beta (2) alpha.bumpup (3) alpha.bumpdown

- logfeedbackRL
    Bump likelihoods up or down, depending on how much they contributed correctly/incorrectly to the answer.
    Use softmax(log(posteriors)) for choices, instead of softmax(posteriors)
    NB: this is a superset of 'logBayesian'
    params: (1) softmax_beta (2) alpha.bumpup (3) alpha.bumpdown

- feedbackRL_1alpha, logfeedbackRL_1alpha
    Same as "feedbackRL" and "logfeedbackRL", except with the same alpha for bumping up and down.
    params: (1) softmax_beta (2) alpha