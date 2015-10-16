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
        
        % update bestfit
        if ~any(isnan(allfits(i).params)) && allfits(i).negloglik < bestfit.negloglik
            bestfit = allfits(i);
        end
    end
end

% save
save(sprintf('%s/estliks%i_SFR%i',resultsdir,estliks,subjnum),...
    'bestfit','allfits','inits')