clear all
close all

subjnum = 134

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
        
    case 110
        estimates = [14 13 3 40 30
            16 16 8 30 30
            20 30 5 20 15
            35 24 1 10 30]'
        
    case 112
        estimates = [10 10 10 50 20
            50 10 10 20 10
            20 20 20 20 20
            80 10 1 2 5]'
        
    case 113
        estimates = [20 25 10 35 10
            25 0 10 25 40
            40 15 10 10 25
            40 26 0 4 30]';
        
    case 114
        estimates = [15 15 10 30 30
            40 15 10 15 20
            30 20 15 15 20
            10 40 5 10 35]'
        
    case 115
        estimates = [20 20 10 25 25
            25 0 0 30 45
            20 15 10 30 25
            10 10 10 20 50]'
        
    case 116
        estimates = [0 18 5 45 35
            15 5 5 35 40
            20 15 20 20 25
            50 25 0 0 25]'
        
    case 118
        estimates = [5 20 5 35 35
            40 10 10 10 30
            5 30 30 30 5
            40 13 5 12 30]'
        
    case 119
        estimates = [10 15 15 40 20
            14 30 11 20 25
            20 25 15 15 25
            45 15 5 15 20]'
        
    case 120
        estimates = [15 20 5 27.5 27.5
            10 10 10 35 35
            30 13 3.5 40 13
            60 16.5 3.5 3.5 16.5]'
        
    case 121
        estimates = [10 20 10 30 30
            20 15 10 25 30
            20 20 15 25 20
            45 20 5 5 25]'
        
    case 122
        estimates = [20 10 10 20 40
            10 5 5 20 60
            20 20 20 20 20
            80 5 5 5 5]'
        
    case 123
        estimates = [5 10 5 50 30
            30 20 5 20 25
            20 15 15 35 25
            70 20 0 0 10]'
        
    case 124
        estimates = [20 20 10 20 30
            15 15 10 30 30
            20 30 10 30 10
            40 20 20 0 20]'
        
    case 125
        estimates = [5 35 5 30 35
            40 20 5 10 25
            12 18 25 20 25
            20 25 10 30 15]'
        
    case 126
        estimates = [15 20 5 30 20
            20 25 10 15 30
            25 20 10 20 25
            40 30 0 0 30]'
        
    case 127
        estimates = [30 10 10 20 30
            40 10 5 5 40
            30 20 10 10 30
            30 20 10 10 30]'
        
    case 129
        estimates = [15 10 5 40 30
            20 10 5 25 40
            25 20 15 20 20
            60 30 0 5 5]'
        
    case 130
        estimates = [15 15 10 35 25
            30 20 10 20 20
            15 20 15 30 20
            40 20 10 15 15]'
        
    case 131
        estimates = [20 10 5 40 25
            25 5 10 20 40
            30 15 20 30 50
            75 10 2.5 2.5 10]'
        
    case 132
        estimates = [37 10 2 25 30
            20 10 5 25 40
            30 0 10 40 20
            30 20 5 0 45]'
        
    case 133
        estimates = [20 2 2 40 36
            33 6 13 28 20
            22 22 18 20 18
            40 44 0 1 15]'
        
    case 134
        estimates = [30 15 10 15 30
            40 10 10 10 30
            10 15 15 40 20
            20 10 10 20 40]'
            
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
        slmetric_pw(normalized(:,sector),likelihoods(:,sector),'kldiv')]);
end

symKLdiv

average_symKLdiv = mean(symKLdiv)