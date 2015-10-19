function [inits, cons] = get_param_inits_cons(model,ninits)
% function [inits, cons] = get_param_inits_cons(model,ninits)

switch model
    case {'Bayesian','logBayesian','additive'}
        inits(1,:) = exp(linspace(-5,5,ninits)); % softmax beta
        cons.A = -1;
        cons.B = 0;
        
    case 'Bayesian_recencyprimacy'
        inits(1,:) = exp(linspace(-5,5,ninits)); % softmax beta
        temp = exp(linspace(-5,2,ninits));
        inits(2,:) = temp(randperm(ninits)); % w.recency
        temp = exp(linspace(-5,2,ninits));
        inits(3,:) = temp(randperm(ninits)); % w.primacy
        cons.A = [-1 0 0
                  0 -1 0
                  0 0 -1
                  0 1 0
                  0 0 1];
        cons.B = [0; 0; 0; 2; 2];
        
    case {'Bayesian_recency','Bayesian_primacy','Bayesian_recencyprimacy_sameweight'}
        inits(1,:) = exp(linspace(-5,5,ninits)); % softmax beta
        temp = exp(linspace(-5,2,ninits));
        inits(2,:) = temp(randperm(ninits)); % w.recency / w.primacy
        cons.A = [-1 0
                  0 -1
                  0 1];
        cons.B = [0; 0; 2];
        
    case {'feedbackRL','feedbackRL_correctalso','feedbackRL_correctalso_1alpha',...
            'logfeedbackRL',...
            'feedbackRL_1alpha','logfeedbackRL_1alpha'}
        if strfind(model,'1alpha')
            inits(1,:) = exp(linspace(-5,5,ninits)); % softmax beta
            inits(2,:) = rand(1,ninits); % alpha
            cons.A = [-1 0
                      0  -1
                      0  1];
            cons.B = [zeros(2,1); 1];
        else
            inits(1,:) = exp(linspace(-5,5,ninits)); % softmax beta
            inits(2,:) = rand(1,ninits); % alpha.bumpup
            inits(3,:) = rand(1,ninits); % alpha.bumpdown
            cons.A = [-1 0  0
                      0  -1 0
                      0  0  -1
                      0  1  0
                      0  0  1];
            cons.B = [zeros(3,1); ones(2,1)];
        end
        
    case {'feedbackRL_recencyprimacy','feedbackRL_recencyprimacy_sameweight',...
            'feedbackRL_1alpha_recencyprimacy','feedbackRL_1alpha_recencyprimacy_sameweight'}
        clear inits cons
        inits(1,:) = exp(linspace(-5,5,ninits)); % softmax beta
        cons.A = -1;
        cons.B = 0;
        if strfind(model,'1alpha')
            inits(2,:) = rand(1,ninits); % alpha
            cons.A = [-1 0
                       0 -1
                       0 1];
            cons.B = [0; 0; 1];
        else
            inits(2,:) = rand(1,ninits); % alpha.bumpup
            inits(3,:) = rand(1,ninits); % alpha.bumpdown
            cons.A = [-1 0  0
                      0  -1 0
                      0  0  -1
                      0  1  0
                      0  0  1];
            cons.B = [zeros(3,1); ones(2,1)];
        end
        dimsA = size(cons.A);
        if strfind(model,'sameweight')
            temp = exp(linspace(-5,2,ninits));
            inits(end+1,:) = temp(randperm(ninits)); % w.recencyprimacy
            cons.A = [cons.A, zeros(dimsA(1),1);
                zeros(2, dimsA(2)), [-1; 1]];
            cons.B = [cons.B; 0; 2];
        else
            temp = exp(linspace(-5,2,ninits));
            inits(end+1,:) = temp(randperm(ninits)); % w.recency
            temp = exp(linspace(-5,2,ninits));
            inits(end+1,:) = temp(randperm(ninits)); % w.primacy
            cons.A = [cons.A, zeros(dimsA(1),2);
                zeros(2*2, dimsA(2)), [-eye(2); eye(2)]];
            cons.B = [cons.B; 0; 0; 2; 2];
        end
                
    case {'mostleast_voter','mostleast2_voter'}
        % how much to weight minP vs maxP animals
        % keep softmax_beta constant at 1 (it just scales the other two params)
        inits(1,:) = exprnd(10,ninits,1); % minPvote
        inits(2,:) = exprnd(10,ninits,1); % maxPvote
        cons.A = -eye(2);
        cons.B = zeros(2,1);
        
    case {'mostP_voter','most2_voter','least2_voter'}
        % how much to weight maxP animals
        % keep softmax_beta constant at 1 (it just scales the other two params)
        inits(1,:) = exprnd(10,ninits,1); % maxPvote / minPvote
        cons.A = -1;
        cons.B = 0;
end