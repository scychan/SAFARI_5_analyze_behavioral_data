clear all
close all

subjnum = 'bad'

%% actual likelihoods

likelihoods = [ 0.1141    0.2617    0.2571    0.4563
                0.1748    0.0778    0.1441    0.2774
                0.0735    0.0677    0.1222    0.0166
                0.3690    0.2181    0.2522    0.0271
                0.2686    0.3747    0.2244    0.2226];  % P(animal|sector)

%% load estimates

switch subjnum
    
    case 101
        
        estimates = [15 15 30 40
                     15 10 20 25
                     10 5 10 3
                     20 30 20 2
                     40 30 20 25]
                 
    case 102
        
        estimates = [15 25 40 40
                     10 10 10 25
                     10 10 10 10
                     40 15 25 10
                     25 40 15 15]
            
    case 'bad' % switch ordering within each sector-- highest is lowest and lowest is highest
        
        estimates = [27 8  12 2
                     17 26 25 3
                     37 37 26 46
                     7  22 14 28
                     11 7  22 22]
end

%% normalize, if not already normalized

sum(estimates)

normalized = normalize1(estimates,'c');

%% compute symmetrized KL div, averaged across sectors

for sector = 1:4
    symKLdiv(sector) = mean([slmetric_pw(normalized(:,sector),likelihoods(:,sector),'kldiv')
        slmetric_pw(normalized(:,sector),likelihoods(:,sector),'kldiv')])
end

average_symKLdiv = mean(symKLdiv)