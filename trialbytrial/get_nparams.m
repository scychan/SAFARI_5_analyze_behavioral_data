function nparams = get_nparams(modelname)

switch modelname
    case 'Bayesian'
        nparams = 1;
    case 'logBayesian'
        nparams = 1;
    case 'additive'
        nparams = 1;
    case {'mostleast_voter','mostleast2_voter'}
        nparams = 2;
    case {'mostP_voter','most2_voter','least2_voter'}
        nparams = 1;
    case {'feedbackRL','logfeedbackRL'}
        nparams = 3;
    case {'feedbackRL_1alpha','logfeedbackRL_1alpha'}
        nparams = 2;
end