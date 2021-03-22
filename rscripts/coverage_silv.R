source('rscripts/settings.R')
source('rscripts/cases_1-7.R')

pbetti_mean <- read.csv('pbetti/pbetti_mean.csv')

coverage <- do.call(rbind, lapply(split(CASES, 1:nrow(CASES)), function(case){
  
  for(name in names(case)) assign(name, case[1, name])
  
  pb_mean <- pbetti_mean$pb_mean[pbetti_mean$f == f & pbetti_mean$q == q & pbetti_mean$n == n]
  
  boot_reps <- read.csv(sprintf('pbetti/reps/boot_reps_silv_f%d_q%d_n%d.csv', f, q, n))
  
  return( data.frame(f = f, q = q, n = n, r = r, s = s, pb_mean = pb_mean, cov = mean(abs(boot_reps$pb - pb_mean) <= boot_reps$quant)) )
}))

write.csv(coverage, 'pbetti/coverage_silv.csv', row.names = FALSE)
