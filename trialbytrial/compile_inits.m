function compile_inits(modelname,estliks,subjnum,ninits)

% info
resultsdir = sprintf('../../results/trialbytrial/fits_%s',modelname);
nparams = get_nparams(modelname);

% compile fits from all initializations
bestfit.negloglik = Inf;
allfits = struct('params',cell(1,ninits),'negloglik',cell(1,ninits));
inits = nan(nparams,ninits);
for i = 1:ninits
    % load iteration
    resultfile = sprintf('%s/estliks%i_SFR%i_init%i.mat',...
        resultsdir,estliks,subjnum,i);
    if ~exist(resultfile,'file')
        warning('%s does not exist',resultfile)
    else
        temp = load(resultfile);
        allfits(i).params = temp.allfits(i).params;
        allfits(i).negloglik = temp.allfits(i).negloglik;
        inits(:,i) = temp.inits(:,i);
        
        % re-compute the actual negloglik for the params if
        % (a) negloglik is imaginary (b) params are outside constraints
        [~,cons] = get_param_inits_cons(modelname,ninits);
        outcons = cons.A * allfits(i).params > cons.B;
        if ~isreal(allfits(i).negloglik) || any(outcons)
            allfits(i).params = real(temp.allfits(i).params); % make params real
            if any(outcons)
                for icon = horz(find(outcons))
                    conparam = cons.A(2,:) ~= 0;
                    allfits(i).params(conparam) = cons.B(icon); % set param to closest constraint
                end
            end
            data = get_data(modelname, subjnum, estliks);
            pchoices_fun = get_pchoices_for_data(modelname,data);
            allfits(i).negloglik = pchoices_fun(allfits(i).params);
        end
        
        % update bestfit
        if ~any(isnan(allfits(i).params)) && isreal(allfits(i).negloglik) ...
                && allfits(i).negloglik < bestfit.negloglik
            bestfit = allfits(i);
        end
    end
end

% save
save(sprintf('%s/estliks%i_SFR%i',resultsdir,estliks,subjnum),...
    'bestfit','allfits','inits')