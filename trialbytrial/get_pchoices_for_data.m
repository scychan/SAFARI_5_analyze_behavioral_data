function pchoices_fordata = get_pchoices_for_data(model,data)
% function pchoices_fordata = get_pchoices_for_data(model,data)

switch model
    case {'Bayesian','logBayesian','additive'}
        pchoices_fordata = @(params) pchoices_Bayesian(params, data);
        
    case 'Bayesian_recencyprimacy'
        pchoices_fordata = @(params) pchoices_Bayesian_recencyprimacy(params, data, 2, 3);
        
    case 'Bayesian_recencyprimacy_sameweight'
        pchoices_fordata = @(params) pchoices_Bayesian_recencyprimacy(params, data, 2, 2);
        
    case 'Bayesian_recency'
        pchoices_fordata = @(params) pchoices_Bayesian_recencyprimacy(params, data, 2, nan);
        
    case 'Bayesian_primacy'
        pchoices_fordata = @(params) pchoices_Bayesian_recencyprimacy(params, data, nan, 2);
        
    case 'feedbackRL'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 0, 2, nan, nan, 0);
        
    case 'feedbackRL_correctalso'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 0, 2, nan, nan, 1);
        
    case 'feedbackRL_correctalso_1alpha'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 0, 1, nan, nan, 1);
        
    case 'logfeedbackRL'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 1, 2, nan, nan, 0);
        
    case 'feedbackRL_1alpha'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 0, 1, nan, nan, 0);
        
    case 'logfeedbackRL_1alpha'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 0, 1, nan, nan, 0);
        
    case 'feedbackRL_recencyprimacy'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 0, 2, 4, 5, 0);
        
    case 'feedbackRL_recencyprimacy_sameweight'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 0, 2, 4, 4, 0);
        
    case 'feedbackRL_1alpha_recencyprimacy'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 0, 1, 3, 4, 0);
        
    case 'feedbackRL_1alpha_recencyprimacy_sameweight'
        pchoices_fordata = @(params) pchoices_feedbackRL(params, data, 0, 1, 3, 3, 0);
        
    case {'mostleast_voter','mostleast2_voter'}
        pchoices_fordata = @(params) pchoices_mostleast_voter(params, data, 'minmax');
        
    case {'mostP_voter','most2_voter'}
        pchoices_fordata = @(params) pchoices_mostleast_voter(params, data, 'max');
        
    case 'least2_voter'
        pchoices_fordata = @(params) pchoices_mostleast_voter(params, data, 'min');
end