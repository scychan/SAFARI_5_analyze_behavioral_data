1. run_all_subjs(modelname)
2. compare_models

models available:

- Bayesian 
    Optimal Bayesian inference.

- logBayesian
    Instead of softmax on the posteriors, we use a softmax on the *log* posteriors. 
    This was inspired by the model used in the Shadlen 2007 paper. 
    In this case, a softmax beta of 1 implies that they are perfectly probability matching.

- mostleast_voter
    This model assumes that subjects are only paying attention to which animals were 
    most common and least common in each sector. During the trials, each animal appearance 
    "votes" for (or against) the sectors in which it is the most common (or least common). 
    NB: minPvote doesn't make sense when using the real likelihoods, because the min is always animal 3
    
- additive
    Instead of multiplying likelihoods together to get posterior, add them together.

- feedbackRL
    Bump likelihoods up or down, depending on how much they contributed correctly/incorrectly to the answer.

- logfeedbackRL
    Bump likelihoods up or down, depending on how much they contributed correctly/incorrectly to the answer.
    Use softmax(log(posteriors)) for choices, instead of softmax(posteriors)