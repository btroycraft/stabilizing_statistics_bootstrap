library(ggplot2)
library(egg)

source('rscripts/gen_data.R')
source('rscripts/funcs.R')        

set.seed(1132645)

if(!dir.exists('plots')) dir.create('plots')

X_orig <- GEN.DATA.3(10^4)
X_boot <- GEN.BOOT(X_orig)

diag_orig <- RIPSER(X_orig, .3, 1)

diag_boot <- RIPSER(X_boot, .3, 1)

diag_tot <- rbind(cbind(SUB.DIAG(diag_orig, 1), sample = 'original'),
                  cbind(SUB.DIAG(diag_boot, 1), sample = 'bootstrap'),
                  cbind(SUB.DIAG(diag_boot, 1)*sqrt(1-exp(-1)), sample = 'transformed'))
diag_tot$sample = factor(diag_tot$sample, levels = c("original", "bootstrap", "transformed"))

plot1 <- ggplot(as.data.frame(X_orig)) +
  theme_classic(base_size = 18) +
  geom_point(aes(x = V1, y = V2), size = .75) +
  xlab('x') +
  ylab('y') +
  coord_fixed(ratio = 1)

plot2 <- ggplot(subset(diag_tot, sample == 'original' | sample == 'bootstrap')) +
  theme_classic(base_size = 18) +
  scale_color_manual(values = c('blue', 'red')) +
  geom_point(aes(x = birth, y = death, col = sample, shape = sample), size=.75) +
  geom_abline(intercept = 0, slope = 1) +
  geom_hline(yintercept = 0) +
  geom_vline(xintercept = 0) +
  geom_vline(xintercept = median(subset(diag_tot, sample == 'original')$birth), size = 1.8, col = 'white') +
  geom_hline(yintercept = median(subset(diag_tot, sample == 'original')$death), size = 1.8, col = 'white') +
  geom_vline(xintercept = median(subset(diag_tot, sample == 'bootstrap')$birth), size = 1.3, col = 'white') +
  geom_hline(yintercept = median(subset(diag_tot, sample == 'bootstrap')$death), size = 1.3, col = 'white') +
  geom_vline(xintercept = median(subset(diag_tot, sample == 'original')$birth), size = 1.5, col = 'blue') +
  geom_hline(yintercept = median(subset(diag_tot, sample == 'original')$death), size = 1.5,  col = 'blue') +
  geom_vline(xintercept = median(subset(diag_tot, sample == 'bootstrap')$birth), size = 1,  col = 'red') +
  geom_hline(yintercept = median(subset(diag_tot, sample == 'bootstrap')$death), size = 1,  col = 'red') +
  coord_fixed(xlim = c(0, .113), ylim = c(0, .113))

plot3 <- ggplot(subset(diag_tot, sample == 'original' | sample == 'transformed')) +
  theme_classic(base_size = 18) +
  scale_color_manual(values = c('blue', 'red')) +
  geom_point(aes(x = birth, y = death, col = sample, shape = sample), size=.75) +
  geom_abline(intercept = 0, slope = 1) +
  geom_hline(yintercept = 0) +
  geom_vline(xintercept = 0) +
  geom_vline(xintercept = median(subset(diag_tot, sample == 'original')$birth), size = 1.8, col = 'white') +
  geom_hline(yintercept = median(subset(diag_tot, sample == 'original')$death), size = 1.8, col = 'white') +
  geom_vline(xintercept = median(subset(diag_tot, sample == 'transformed')$birth), size = 1.3, col = 'white') +
  geom_hline(yintercept = median(subset(diag_tot, sample == 'transformed')$death), size = 1.3, col = 'white') +
  geom_vline(xintercept = median(subset(diag_tot, sample == 'original')$birth), size = 1.5, col = 'blue') +
  geom_hline(yintercept = median(subset(diag_tot, sample == 'original')$death), size = 1.5,  col = 'blue') +
  geom_vline(xintercept = median(subset(diag_tot, sample == 'transformed')$birth), size = 1,  col = 'red') +
  geom_hline(yintercept = median(subset(diag_tot, sample == 'transformed')$death), size = 1,  col = 'red') +
  coord_fixed(xlim = c(0, .113), ylim = c(0, .113))

plot_total <- ggarrange(plot1, plot2, plot3, nrow = 1)

ggsave(plot_total, filename='plots/plot_bootstrap_comp.pdf', width = 5.5, height = 1.3, scale = 2.5)
