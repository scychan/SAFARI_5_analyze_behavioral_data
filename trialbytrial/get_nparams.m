function nparams = get_nparams(modelname)

switch modelname
    case 'Bayesian'
        nparams = 1;
    case 'logBayesian'
        nparams = 1;
    case 'additive'
        nparams = 1;
    case 'mostleast_voter'
        nparams = 2;
    case 'mostleast2_voter'
        nparams = 2;
    case 'mostP_voter'
        nparams = 1;
    case 'feedbackRL'
        nparams = 3;
    case 'logfeedbackRL'
        nparams = 3;
end