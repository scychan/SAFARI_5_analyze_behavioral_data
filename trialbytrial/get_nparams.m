function nparams = get_nparams(modelname)

switch modelname
    case 'Bayesian'
        nparams = 1;
    case 'voter'
        nparams = 2;
    case 'feedbackRL'
        nparams = 3;
end