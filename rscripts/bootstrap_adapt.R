library(parallel)

source('rscripts/gen_data.R')
source('rscripts/funcs.R')
source('rscripts/settings.R')
source('rscripts/cases_1-6.R')

RNGkind("L'Ecuyer-CMRG")

set.seed(87129442)

if(!dir.exists('pbetti')) dir.create('pbetti')
if(!dir.exists('pbetti/reps')) dir.create('pbetti/reps')

for(case in split(CASES, 1:nrow(CASES))){
  
  for(name in names(case)) assign(name, case[1, name])
  gen.data <- switch(f, GEN.DATA.1, GEN.DATA.2, GEN.DATA.3, GEN.DATA.4, GEN.DATA.5, GEN.DATA.6, GEN.DATA.7)
  
  boot_reps <- as.data.frame(do.call(rbind, mclapply(1:NUM_REPS_SIM, mc.cores = NUM_CORES, function(x){
    
    repeat{
      X_orig <- gen.data(n)
      pbetti_orig <- PBETTI(RIPSER(X_orig, t/mult, q), r/mult, s/mult, q)
      
      bw <- try(BW.ADAPT(X_orig, min(sqrt(diag(ks::Hpi.diag(X_orig)))/3)), silent = TRUE)
      
      if(is.numeric(bw)){
        if(length(bw) == n){
          break
        }
      }
    }
    
    pbetti_boot <- replicate(NUM_REPS_BOOT, {
      
      PBETTI(RIPSER(GEN.BOOT.VAR(X_orig, bw), t/mult, q), r/mult, s/mult, q)
    })
    
    quant_boot <- quantile(abs(pbetti_boot - mean(pbetti_boot)), COVERAGE)
    
    return( data.frame(pb = pbetti_orig, quant_boot = quant_boot) )
  })))
  
  write.csv(boot_reps, sprintf('pbetti/reps/boot_reps_adapt_f%d_q%d_n%d.csv', f, q, n), row.names = FALSE)
}
