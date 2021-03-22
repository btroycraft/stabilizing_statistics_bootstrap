library(ggplot2)
library(egg)

source('rscripts/funcs.R')
source('rscripts/settings_galaxy.R')

r_seq <- seq(0, 35, .1)
band_seq <- seq(3, 33, 3)
ind_seq <- sapply(band_seq, function(x) which(r_seq == x))

color_list <- c('dark red', 'dark blue', 'dark green')

slice_list <- lapply(1:3, function(slice_num){
  read.csv(sprintf('galaxy/slice%d.csv', slice_num))
})

diag_list <- lapply(1:3, function(slice_num){
  read.csv(sprintf('galaxy/diag%d.csv', slice_num))
})


plot_list1 <- do.call(c,
  lapply(1:length(slice_list), function(slice_num){
    
    slice <- slice_list[[slice_num]]
    diag <- diag_list[[slice_num]]
    color <- color_list[[slice_num]]
    
    bw <- BW.ADAPT(slice, min(sqrt(diag(ks::Hpi.diag(slice)))/2))
    
    kde_grid <- {
      x1 <- seq(-155, 155, 1)
      x2 <- seq(-10, 130, 1)
      data.frame(x = rep(x1, each = length(x2)), y = rep(x2, times = length(x1)))
    }
    
    kde_grid$z <- apply(kde_grid, 1, function(x){
      mean(dnorm(x[1], mean = slice$x, sd = bw)*dnorm(x[2], mean = slice$y, sd = bw))
    })
    
    plot1 <- ggplot(slice) +
      theme_classic(base_size = 18) +
      geom_point(aes(x = x, y = y), colour = color, size = .5) +
      coord_fixed(ratio = 1, ylim = c(-10, 130), xlim = c(-155, 155)) +
      xlab(expression(x[1])) +
      ylab(expression(x[2]))
    plot2 <- ggplot() +
      theme_classic(base_size = 18) +
      geom_contour_filled(aes(x = kde_grid$x, y = kde_grid$y, z = (kde_grid$z/max(kde_grid$z))^(1/3)),
                          show.legend = FALSE,
                          color = 'black',
                          bins = 7,
                          size = .05) +
      coord_fixed(ratio = 1, ylim = c(-10, 130), xlim = c(-155, 155)) +
      xlab(expression(x[1])) +
      ylab(expression(x[2])) +
      scale_fill_manual(palette = colorRampPalette(c('white', color)))
    plot3 <- ggplot(SUB.DIAG(diag, 1)) +
      theme_classic(base_size = 18) +
      geom_point(aes(x = birth, y = death), colour = color) +
      geom_abline(intercept = 0, slope = 1) +
      geom_hline(yintercept = 0) +
      geom_vline(xintercept = 0) +
      coord_fixed(ratio = 1, xlim = c(0, 35), ylim = c(0, 35))
    
    return( (list(plot1, plot2, plot3)) )
  })
)

plot1 <- do.call(ggarrange, c(plot_list1, byrow = FALSE, nrow = 3))
ggsave(plot1, file='plots/plot_gal1.pdf', width = 5.5, height = 3.8, scale = 2.5)

plot_list2 <- {
  pbetti_list1 <- lapply(diag_list, function(diag){
    sapply(r_seq, function(r) PBETTI(diag, 0, r, 0) )
  })
  pbetti_list2 <- lapply(diag_list, function(diag){
    sapply(r_seq, function(r) PBETTI(diag, r, r, 1) )
  })
  pbetti_list3 <- lapply(diag_list, function(diag){
    sapply(r_seq, function(r) PBETTI(diag, r, r+1, 1) )
  })
  
  pbetti_boot1_list <- lapply(1:3, function(slice_num){
    x <- as.matrix(read.csv(sprintf('galaxy/pbetti_boot_case1_%d.csv', slice_num)))[, ind_seq]
    sweep(x, 2, colMeans(x))
  })
  pbetti_boot2_list <- lapply(1:3, function(slice_num){
    x <- as.matrix(read.csv(sprintf('galaxy/pbetti_boot_case2_%d.csv', slice_num)))[, ind_seq]
    sweep(x, 2, colMeans(x))
  })
  pbetti_boot3_list <- lapply(1:3, function(slice_num){
    x <- as.matrix(read.csv(sprintf('galaxy/pbetti_boot_case3_%d.csv', slice_num)))[, ind_seq]
    sweep(x, 2, colMeans(x))
  })
  
  lower_pw_list1 <- lapply(1:3, function(slice_num){
    x <- pbetti_list1[[slice_num]][ind_seq] - apply(pbetti_boot1_list[[slice_num]], 2, function(x) quantile(x, 1-(1-COVERAGE)/2) )
    pmax(x, 0)
  })
  lower_pw_list2 <- lapply(1:3, function(slice_num){
    x <- pbetti_list2[[slice_num]][ind_seq] - apply(pbetti_boot2_list[[slice_num]], 2, function(x) quantile(x, 1-(1-COVERAGE)/2) )
    pmax(x, 0)
  })
  lower_pw_list3 <- lapply(1:3, function(slice_num){
    x <- pbetti_list3[[slice_num]][ind_seq] - apply(pbetti_boot3_list[[slice_num]], 2, function(x) quantile(x, 1-(1-COVERAGE)/2) )
    pmax(x, 0)
  })
  
  upper_pw_list1 <- lapply(1:3, function(slice_num){
    pbetti_list1[[slice_num]][ind_seq] - apply(pbetti_boot1_list[[slice_num]], 2, function(x) quantile(x, (1-COVERAGE)/2) )
  })
  upper_pw_list2 <- lapply(1:3, function(slice_num){
    pbetti_list2[[slice_num]][ind_seq] - apply(pbetti_boot2_list[[slice_num]], 2, function(x) quantile(x, (1-COVERAGE)/2) )
  })
  upper_pw_list3 <- lapply(1:3, function(slice_num){
    pbetti_list3[[slice_num]][ind_seq] - apply(pbetti_boot3_list[[slice_num]], 2, function(x) quantile(x, (1-COVERAGE)/2) )
  })
  
  quant_unif_list1 <- lapply(1:3, function(slice_num){
    x <- apply(abs(pbetti_boot1_list[[slice_num]]), 1, max)
    quantile(x, COVERAGE)
  })
  quant_unif_list2 <- lapply(1:3, function(slice_num){
    x <- apply(abs(pbetti_boot2_list[[slice_num]]), 1, max)
    quantile(x, COVERAGE)
  })
  quant_unif_list3 <- lapply(1:3, function(slice_num){
    x <- apply(abs(pbetti_boot3_list[[slice_num]]), 1, max)
    quantile(x, COVERAGE)
  })
    
  lower_unif_list1 <- lapply(1:3, function(slice_num){
    x <- pbetti_list1[[slice_num]][ind_seq] - quant_unif_list1[[slice_num]]
    pmax(x, 0)
  })
  lower_unif_list2 <- lapply(1:3, function(slice_num){
    x <- pbetti_list2[[slice_num]][ind_seq] - quant_unif_list2[[slice_num]]
    pmax(x, 0)
  })
  lower_unif_list3 <- lapply(1:3, function(slice_num){
    x <- pbetti_list3[[slice_num]][ind_seq] - quant_unif_list3[[slice_num]]
    pmax(x, 0)
  })
  
  upper_unif_list1 <- lapply(1:3, function(slice_num){
    pbetti_list1[[slice_num]][ind_seq] + quant_unif_list1[[slice_num]]
  })
  upper_unif_list2 <- lapply(1:3, function(slice_num){
    pbetti_list2[[slice_num]][ind_seq] + quant_unif_list2[[slice_num]]
  })
  upper_unif_list3 <- lapply(1:3, function(slice_num){
    pbetti_list3[[slice_num]][ind_seq] + quant_unif_list3[[slice_num]]
  })
  
  do.call(c, lapply(1:length(slice_list), function(slice_num){
    plot1 <- ggplot() +
      theme_classic(base_size = 18) +
      geom_errorbar(aes(x = band_seq, ymin = lower_unif_list1[[slice_num]], ymax = upper_unif_list1[[slice_num]]),
                    color = 'dark gray') +
      geom_errorbar(aes(x = band_seq + .5, ymin = lower_pw_list1[[slice_num]], ymax = upper_pw_list1[[slice_num]])) +
      geom_line(aes(x = r_seq, y = (pbetti_list1[[slice_num]])),
                colour = color_list[[slice_num]],
                size = 1.5) +
      xlab(expression(r)) +
      ylab('number')
    plot2 <- ggplot() +
      theme_classic(base_size = 18) +
      geom_errorbar(aes(x = band_seq, ymin = lower_unif_list2[[slice_num]], ymax = upper_unif_list2[[slice_num]]),
                    color = 'dark gray') +
      geom_errorbar(aes(x = band_seq + .5, ymin = lower_pw_list2[[slice_num]], ymax = upper_pw_list2[[slice_num]])) +
      geom_line(aes(x = r_seq, y = pbetti_list2[[slice_num]]),
                colour = color_list[[slice_num]],
                size = 1.5) +
      coord_cartesian(ylim = c(0, 40)) +
      xlab(expression(r)) +
      ylab('number')
    plot3 <- ggplot() +
      theme_classic(base_size = 18) +
      geom_errorbar(aes(x = band_seq, ymin = lower_unif_list3[[slice_num]], ymax = upper_unif_list3[[slice_num]]),
                    color = 'dark gray') +
      geom_errorbar(aes(x = band_seq + .5, ymin = lower_pw_list3[[slice_num]], ymax = upper_pw_list3[[slice_num]])) +
      geom_line(aes(x = r_seq, y = pbetti_list3[[slice_num]]),
                colour = color_list[[slice_num]],
                size = 1.5) +
      coord_cartesian(ylim = c(0, 25)) +
      xlab(expression(r)) +
      ylab('number')
    
    list(plot1, plot2, plot3)
  }))
}

plot2 <- do.call(ggarrange, c(plot_list2, byrow = FALSE, nrow = 3))
ggsave(plot2, file='plots/plot_gal2.pdf', width = 5.5, height = 3.8, scale = 2.5)
