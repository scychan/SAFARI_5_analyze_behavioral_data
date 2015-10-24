function [inits, cons] = get_param_inits_cons(model,ninits)
% function [inits, cons] = get_param_inits_cons(model,ninits)


if strfind(model,'feedbackRL')
    
    clear inits cons
    inits(1,:) = exp(linspace(-5,5,ninits)); % softmax beta
    inits(2,:) = rand(1,ninits); % alpha or alpha.bumpup (if 2 params)
    if strfind(model,'backwards')
        inits(2,:) = 0.01 * inits(2,:); % must be small, for backwardRL
    end
    
    if strfind(model,'1alpha')
        cons.A = [-1 0
            0  1];
        cons.B = [0; 1];
    else
        inits(3,:) = rand(1,ninits); % alpha.bumpdown
        cons.A = [-1 0  0
            0  1  0
            0  0  1];
        cons.B = [0; 1; 1];
    end
    
    if strfind(model,'recencyprimacy')
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
    end
    
else
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
            
        case 'mostleast_multiplier'
            inits(1,:) = exp(linspace(-5,5,ninits)); % softmax beta
            inits(2,:) = 0.5*rand(1,ninits); % minPweight
            inits(3,:) = 0.5 + 0.5*rand(1,ninits); % maxPweight
            sum23 = inits(2,:) + inits(3,:);
            inits(2,sum23 > 1) = inits(2,sum23 > 1) / sum23(sum23 > 1);
            inits(3,sum23 > 1) = inits(3,sum23 > 1) / sum23(sum23 > 1);
            cons.A = [-1 0 0
                0 -1 0
                0 0 -1
                0 1 1   % minPweight + maxPweight <= 1
                0 1 -1];   % minPweight <= maxPweight
            cons.B = [0; 0; 0; 1; 0];
            
        case {'mostP_multiplier','most2_multiplier', 'least2_multiplier'}
            inits(1,:) = exp(linspace(-5,5,ninits)); % softmax beta
            inits(2,:) = rand(1,ninits); % maxPweight/minPweight
            cons.A = [-1 0
                0 -1
                0 1];  % weight <= 1
            cons.B = [0; 0; 1];
    end
end