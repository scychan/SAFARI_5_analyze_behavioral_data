model = 'feedbackRL_1alpha'
estimated.liks = 1

resultsdir = '../../../results/trialbytrial/csv_fits'
df = read.csv(sprintf('%s/%s.csv',csvdir,model))
df = subset(df, estliks == estimated.liks)

questdir = '../../../results/questionnaire'
q = read.csv(file.path(questdir,'questionnaire.csv'))
adjusted = as.character(q$Adjusted.frequencies.after.touring..during.Safari.Detective..)

hist(df$p2)
nrow(subset(df, p2 == 0))

adjusted[df$p2 == 0]
adjusted[df$p2 != 0]


