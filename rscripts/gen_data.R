GEN.DATA.1 <- function(n) t(replicate(n, {
  
  x <- rnorm(2)
  x <- x / sqrt(sum(x^2))
  x <- x * runif(1)^(.9*sample(c(-1, 1), 1))
  
  return( x )
}))

GEN.DATA.2 <- function(n) t(replicate(n, {
  
  x <- rnorm(2)
  x <- x / sqrt(sum(x^2))
  x <- x * runif(1)^(.55*sample(c(-1, 1), 1))
  
  return( x )
}))

GEN.DATA.3 <- function(n) t(replicate(n, {

  x <- rnorm(2)
  x <- x / sqrt(sum(x^2))
  x <- x + rnorm(2, 0, .2)
  
  return( x )
}))

GEN.DATA.4 <- function(n) t(replicate(n, {
  
  x <- rnorm(3)
  x <- x / sqrt(sum(x^2))
  x <- x * runif(1)^(1/3)
  x <- x + rnorm(3, 0, .1)
  
  return( x )
}))

GEN.DATA.5 <- function(n) t(replicate(n, {

  x <- switch(sample(5, 1),
              c(0.38741799, 0.24263535, 0.09535272),
              c(0.25147839, 0.63824409, 0.62425101),
              c(0.73988542, 0.80749034, 0.84972394),
              c(0.26811913, 0.35911205, 0.08316547),
              c(0.65954757, 0.04704809, 0.02113341))
  x <- x + sample(c(-1, 1), 3, replace = TRUE) * rexp(3, 25)
  
  return( x )
}))

GEN.DATA.6 <- function(n) t(replicate(n, {
  
  x <- rnorm(3)
  x <- x / sqrt(sum(x)^2)
  x <- c(x, rep(0, 2))
  x <- x + rcauchy(5, 0, .1)
  
  return( x )
}))

GEN.DATA.7 <- function(n) t(replicate(n, {
  
  x <- rnorm(2)
  x <- x / sqrt(sum(x^2))
  x[1] <- x[1] + sample(c(-1, 1), 1, replace = TRUE)
  x <- c(x, rep(0, 8))
  x <- x + rnorm(10, 0, .2)
  
  return( x )
}))
