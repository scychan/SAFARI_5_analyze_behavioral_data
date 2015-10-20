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
        
    case {'mostleast_voter','mostleast2_voter'}
        pchoices_fordata = @(params) pchoices_mostleast_voter(params, data, 'minmax');
        
    case {'mostP_voter','most2_voter'}
        pchoices_fordata = @(params) pchoices_mostleast_voter(params, data, 'max');
        
    case 'least2_voter'
        pchoices_fordata = @(params) pchoices_mostleast_voter(params, data, 'min');
        
    otherwise
        
        if strfind(model, 'feedbackRL')
            % parse options
            take_log = ~isempty(strfind(model,'logfeedbackRL'));
            if strfind(model,'1alpha')
                nalpha = 1;
            else
                nalpha = 2;
            end
            if strfind(model,'recencyprimacy')
                if strfind(model,'sameweight')
                    wind_recency = 1 + nalpha + 1;
                    wind_primacy = 1 + nalpha + 1;
                else
                    wind_recency = 1 + nalpha + 1;
                    wind_primacy = 1 + nalpha + 2;
                end
            else
                wind_recency = nan;
                wind_primacy = nan;
            end
            correctalso = ~isempty(strfind(model,'`correctalso'));
            if strfind(model,'nocontrib')
                contrib = 0;
            elseif strfind(model,'oppcontrib')
                contrib = -1;
            else
                contrib = 1;
            end
            
            pchoices_fordata = @(params) pchoices_feedbackRL(params, data, ...
                take_log, nalpha, wind_recency, wind_primacy, correctalso, contrib);
        end
end