
==== PROCEDURE ====

1. run_all_subjs(modelname,ninit)   OR   run_all_subj.sh
2. compile_inits (only for those with initializations run separately)
3. compile_subjs
    - find_empty.m -- if some had no completed runs
4. compare_models

-- To analyze / extract posteriors, etc --
extract_posteriors

==== FILES TO UPDATE WHEN ADDING A NEW MODEL ====

1. get_data.m
2. get_param_inits_cons
3. get_pchoices_for_data
4. pchoices_XX

5. get_nparams.m

6. readme.txt
7. run_all_subjs.sh
8. compare_models.m

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

- mostleast_multiplier, mostP_multiplier, most2_multiplier, least2_multiplier
    Similar in principle to mostleast_voter, except that the evidence is multiplied together instead of added.
    A certain weight is given to the most common and the least common animals. The rest is divided between the
    remaining animals.
    params: (1) softmax_beta (2) minPweight (3) maxPweight 
    (minPweight + maxPweight <= 1, minPweight < maxPweight)

- additive
    Instead of multiplying likelihoods together to get posterior, add them together.
    params: (1) softmax_beta

- feedbackRL
    Bump likelihoods up or down, depending on how much they contributed correctly/incorrectly to the answer.
    NB: this is a superset of 'Bayesian'

    options:
        logfeedbackRL_*
        	use softmax(log(posteriors)) for choices, instead of softmax(posteriors)
        1alpha
            use the same alpha for both bumping up and bumping down (instead of two separate alphas)
        correctalso
            also learn on trials where the response was correct
        nocontrib
            without weighting the learning by "posteriordiff" for each animal
        oppcontrib
            weighting the learning *less* for animals that contributed more (e.g. because of confidence)
        recencyprimacy
        recencyprimacy_sameweight
            include recency and primacy

    params: (1) softmax_beta (2) alpha (1-2 params) (3) w.recency/primacy params (0-2 params)
