library(parallel)

source('rscripts/funcs.R')
source('rscripts/settings_galaxy.R')

RNGkind("L'Ecuyer-CMRG")

seed_list <- c(8373924, 14781235, 381235)
limit_list <- list(c(.025, .026), c(0.02701429, .028), c(0.0290943, .030))
r_seq <- seq(0, 35, .1)

if(!dir.exists('galaxy')) dir.create('galaxy')

galaxy_data <- read.csv('data/galaxy_dat.csv')

slice_list <- lapply(1:length(limit_list), function(slice_num){
  
  limits1 <- limit_list[[1]]
  limits <- limit_list[[slice_num]]
  
  radius1 <- 299792.458/73.4*mean(limits1)
  radius <- 299792.458/73.4*mean(limits)
  
  slice <- as.matrix({
    
    dat <- galaxy_data[limits[1] <= galaxy_data$redshift & galaxy_data$redshift <= limits[2], c('ra', 'dec')]
    
    x <- (dat$ra-185)*cos(dat$dec*pi/180)*pi/180*radius
    y <- dat$dec*pi/180*radius
    
    ind <- y <= 70*pi/180*radius1
    
    x <- x[ind]
    y <- y[ind]
    
    ind <- abs(x) <= 85*cos(y/radius1)*pi/180*radius1
    
    cbind(x = x[ind], y = y[ind])
  })
  
  write.csv(slice, sprintf('galaxy/slice%d.csv', slice_num), row.names = FALSE)
  
  return( slice )
})

for(slice_num in 1:length(slice_list)){
  
  slice <- slice_list[[slice_num]]
  
  write.csv(RIPSER(slice, 35, 1), sprintf('galaxy/diag%d.csv', slice_num), row.names = FALSE)
  
  bw <- BW.ADAPT(slice, min(sqrt(diag(ks::Hpi.diag(slice))))/3)
  
  set.seed(seed_list[slice_num])
  
  pbetti_boot_list <- mclapply(1:NUM_REPS_BOOT, mc.cores = NUM_CORES, function(i){
    
    diag <- RIPSER(GEN.BOOT.VAR(slice, bw), 35, 1)
    
    return( list(sapply(r_seq, function(r) PBETTI(diag, 0, r, 0) ),
                 sapply(r_seq, function(r) PBETTI(diag, r, r, 1) ),
                 sapply(r_seq, function(r) PBETTI(diag, r, r+1, 1) )) )
  })
  
  pbetti_boot1 <- do.call(rbind, lapply(pbetti_boot_list, function(pbetti) pbetti[[1]] ))
  pbetti_boot2 <- do.call(rbind, lapply(pbetti_boot_list, function(pbetti) pbetti[[2]] ))
  pbetti_boot3 <- do.call(rbind, lapply(pbetti_boot_list, function(pbetti) pbetti[[3]] ))
  
  write.table(pbetti_boot1, file = sprintf('galaxy/pbetti_boot_case1_%d.csv', slice_num), sep = ',', row.names = FALSE)
  write.table(pbetti_boot2, file = sprintf('galaxy/pbetti_boot_case2_%d.csv', slice_num), sep = ',', row.names = FALSE)
  write.table(pbetti_boot3, file = sprintf('galaxy/pbetti_boot_case3_%d.csv', slice_num), sep = ',', row.names = FALSE)
}

