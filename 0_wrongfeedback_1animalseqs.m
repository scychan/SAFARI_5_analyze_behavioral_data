% on average, how many of the single-animal trials had the wrong feedback?

likelihoods = [ 0.1141    0.2617    0.2571    0.4563
                0.1748    0.0778    0.1441    0.2774
                0.0735    0.0677    0.1222    0.0166
                0.3690    0.2181    0.2522    0.0271
                0.2686    0.3747    0.2244    0.2226];
            
pairs = [1 2
    1 3
    1 4
    2 3
    2 4
    3 4];

reversed_order = nan(5,length(pairs));
for animal = 1:5
    for ipair = 1:length(pairs)
        pair = pairs(ipair,:);
        if likelihoods(animal,pair(2)) > likelihoods(animal,pair(1))
            reversed_order(animal,ipair) = 1;
        else
            reversed_order(animal,ipair) = 0;
        end
    end
end

mean(reversed_order(:))