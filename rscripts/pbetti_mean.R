library(ripserr)
library(parallel)

source('rscripts/gen_data.R')
source('rscripts/funcs.R')
source('rscripts/settings.R')
source('rscripts/cases_1-7.R')

RNGkind("L'Ecuyer-CMRG")

set.seed(23463739)

if(!dir.exists('pbetti')) dir.create('pbetti')

pbetti_mean <- do.call(rbind, lapply(split(CASES, 1:nrow(CASES)), function(case){
  
  for(name in names(case)) assign(name, case[1, name])
  
  gen.data <- switch(f, GEN.DATA.1, GEN.DATA.2, GEN.DATA.3, GEN.DATA.4, GEN.DATA.5, GEN.DATA.6, GEN.DATA.7)
  
  pbetti <- unlist(mclapply(1:NUM_REPS_GEN, mc.cores = NUM_CORES, function(x){
    
    PBETTI(RIPSER(gen.data(n), t/mult, q), r/mult, s/mult, q)
  }))
  
  pbetti_mean <- mean(pbetti)
  
  quant <- quantile(abs(pbetti - pbetti_mean), COVERAGE)
  
  return( data.frame(f = f, q = q, n = n, r = r, s = s, pb_mean = pbetti_mean, quant = quant) )
}))

write.csv(pbetti_mean, 'pbetti/pbetti_mean.csv', row.names = FALSE)
