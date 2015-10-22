function nparams = get_nparams(modelname)
% function nparams = get_nparams(modelname)

if strfind(modelname,'feedbackRL')
    nparams = 1; % softmax_beta
    if strfind(modelname,'1alpha') % alphas
        nparams = nparams + 1;
    else
        nparams = nparams + 2;
    end
    if strfind(modelname,'recencyprimacy') % w.recency/primacy
        if strfind(modelname,'sameweight')
            nparams = nparams + 1;
        else
            nparams = nparams + 2;
        end
    end
    
else    
    switch modelname
        case {'Bayesian','logBayesian','additive'}
            nparams = 1;
        case 'Bayesian_recencyprimacy'
            nparams = 3;
        case {'Bayesian_recencyprimacy_sameweight','Bayesian_recency','Bayesian_primacy'}
            nparams = 2;
        case {'mostleast_voter','mostleast2_voter'}
            nparams = 2;
        case {'mostP_voter','most2_voter','least2_voter'}
            nparams = 1;
        case 'mostleast_multiplier'
            nparams = 3;
        case {'mostP_multiplier','most2_multiplier','least2_multiplier'}
            nparams = 2;
    end
end