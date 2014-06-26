clear all
close all

subjnum = 109

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
                 
    case 103
        
        estimates = [.15 .2 .25 .5
            .2 .15 .22 .27
            .1 .12 .15 .01
            .3 .18 .18 .02
            .25 .35 .2 .2]
                 
    case 104
        
        estimates = [7 20 20 50
            10 5 20 30
            3 5 20 5
            70 20 20 5
            10 30 20 20]
                 
    case 105
        
        estimates = [10 10 20 60
            10 10 20 15
            10 10 20 5
            30 30 20 10
            30 40 20 10]
                 
    case 106
        
        estimates = [.2 .3 .2 .6
            .1 0 .2 .2
            .1 .1 .2 0
            .3 .2 .2 .05
            .3 .4 .2 .15]
        
    case 107
        
        estimates = [25 20 5 15 35
            30 12 8 30 20
            25 20 5 25 25
            30 35 3 15 17]'
        
    case 108
        
        estimates = [25 25 20 35 25
            20 15 10 25 30
            20 20 15 20 25
            30 20 15 5 30]'
        
    case 109
        
        estimates = [5 20 5 40 30
            30 5 5 20 40
            60 10 10 10 10
            40 30 5 5 20]'
            
    case 'bad' % switch ordering within each sector-- highest is lowest and lowest is highest
        
        estimates = [27 8  12 2
                     17 26 25 3
                     37 37 26 46
                     7  22 14 28
                     11 7  22 22]
end

%% normalize, if not already normalized

sum(estimates)

normalized = normalize1(estimates,'c')

%% compute symmetrized KL div, averaged across sectors

for sector = 1:4
    symKLdiv(sector) = mean([slmetric_pw(normalized(:,sector),likelihoods(:,sector),'kldiv')
        slmetric_pw(normalized(:,sector),likelihoods(:,sector),'kldiv')])
end

average_symKLdiv = mean(symKLdiv)