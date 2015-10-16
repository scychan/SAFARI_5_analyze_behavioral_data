function compile_inits(modelname,estliks,subjnum,ninits)

% info
resultsdir = sprintf('../../results/trialbytrial/fits_%s',modelname);

% compile fits from all initializations
bestfit.negloglik = Inf;
allfits = struct;
inits = nan(1,ninits);
for i = 1:ninits
    % load iteration
    temp = load(sprintf('%s/estliks%i_SFR%i_init%i',...
        resultsdir,estliks,subjnum,i));
    allfits(i).params = temp.allfits(i).params;
    allfits(i).negloglik = temp.allfits(i).negloglik;
    inits(i) = temp.inits(i);
    
    % update bestfit
    if ~any(isnan(allfits(i).params)) && allfits(i).negloglik < bestfit.negloglik
        bestfit = allfits(i);
    end
end

% save
save(sprintf('%s/estliks%i_SFR%i',resultsdir,estliks,subjnum),...
    'bestfit','allfits','inits')