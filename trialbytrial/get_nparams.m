function nparams = get_nparams(modelname)
% function nparams = get_nparams(modelname)

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
    case {'feedbackRL','feedbackRL_correctalso','logfeedbackRL','feedbackRL_nocontrib','feedbackRL_oppcontrib',...
            'feedbackRL_correctalso_nocontrib','feedbackRL_correctalso_oppcontrib',...
            'backwards_feedbackRL_correctalso_nocontrib','backwards_feedbackRL_1alpha_correctalso_nocontrib',...
            'oldfeedbackRL'}
        nparams = 3;
    case {'feedbackRL_1alpha','feedbackRL_correctalso_1alpha','logfeedbackRL_1alpha',...
            'feedbackRL_nocontrib_1alpha','feedbackRL_oppcontrib_1alpha',...
            'feedbackRL_1alpha_correctalso_nocontrib','feedbackRL_1alpha_correctalso_oppcontrib',...
            'oldfeedbackRL_1alpha'}
        nparams = 2;
    case 'feedbackRL_recencyprimacy'
        nparams = 5;
    case {'feedbackRL_recencyprimacy_sameweight','feedbackRL_1alpha_recencyprimacy'}
        nparams = 4;
    case 'feedbackRL_1alpha_recencyprimacy_sameweight'
        nparams = 3;
end