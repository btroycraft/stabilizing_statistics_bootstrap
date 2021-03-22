cov_top <- read.csv('pbetti/coverage_top.csv')
cov_hpi <- read.csv('pbetti/coverage_hpi.csv')

png('plots/plot_cov.png', 600, 600)
  
  par(mfrow = c(2, 2))
  
  for(n in c(100, 200, 300, 400)){
    
    x = cov_hpi$cov[cov_hpi$n == n]
    y = cov_top$cov[cov_top$n == n]
    q = cov_top$q[cov_top$n == n]
    q = cov_top$q[cov_top$n == n]    
    plot(x, y, xlab = 'Hpi.diag', ylab = 'top.band', main = sprintf('BW Coverage Comp (n = %d)', n), col = q)
    abline(0, 1)
    abline(h = .95)
    abline(v = .95)
  
  }

dev.off()
