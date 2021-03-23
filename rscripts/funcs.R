GEN.BOOT <- function(X, bw = 0, m = nrow(X)){
  
  X[sample(nrow(X), m, replace = TRUE), , drop = FALSE] + matrix(rnorm(m*ncol(X), sd = bw), m, ncol(X), byrow = TRUE)
}

GEN.BOOT.VAR <- function(X, bw = rep(0, nrow(X)), m = nrow(X)){
  
  t(replicate(m, {
    ind <- sample(nrow(X), 1, replace = TRUE)
    X[ind, ] + rnorm(ncol(X), sd = bw[ind])
  }))
}

BW.ADAPT <- function(X, bw_pilot){
  
  n <- nrow(X)
  d <- ncol(X)
  
  pilot <- colSums(exp(-(as.matrix(dist(X))/bw_pilot)^2/2)/((2*pi)^(d/2)*n*bw_pilot^d))
  names(pilot) <- NULL
  
  log_pilot <- log(pilot)
  
  return( bw_pilot*exp(-.5*(log_pilot - mean(log_pilot))) )
}

RIPSER <- function(X, t = Inf, q = 1){
  
  diag <- as.data.frame(ripserr::vietoris_rips(X, q, t))
  colnames(diag) <- c('dim', 'birth', 'death')
  
  return( diag )
}

SUB.DIAG <- function(diag, q) subset(diag[, c('birth', 'death')], diag[, 'dim'] == q)

PBETTI <- function(diag, r, s = r, q = 1) sum(diag$dim == q & diag$birth <= r & diag$death > s)
