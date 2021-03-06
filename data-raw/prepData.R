library(devtools)

mwlModel = "model{
  #Data model
  for(i in 1:ndat){
    obs[i, 1:2] ~ dmnorm.vcov(c(h_pred, o_pred), 
                              obs.vcov[(1 + (i-1) * 2):(2 + (i-1) * 2),])
  }
  
  #Process model
  h_pred = source_d2H + E * S
  o_pred = source_d18O + E
  
  #evap prior
  E ~ dunif(0, 15)
  
  #EL slope prior
  S ~ dnorm(slope[1], 1 / slope[2] ^ 2)
  
  #MWL source prior
  source_d2H ~ dnorm(source_d18O * MWL[1] + MWL[2], 1 / sy ^ 2) 
  sy = MWL[5] * sqrt(MWL[7] + (source_d18O - MWL[3])^2 / MWL[4])
  source_d18O ~ dnorm(o_cent, 1 / o_var)
}"

mixModel = "model{
  #Data model
  for(i in 1:ndat){
    obs[i, 1:2] ~ dmnorm.vcov(c(h_pred, o_pred), 
                              obs.vcov[(1 + (i-1) * 2):(2 + (i-1) * 2),])
  }
  
  #Process model
  h_pred = mixture_d2H + E * S
  o_pred = mixture_d18O + E
  
  #evap prior
  E ~ dunif(0, 15)
  
  #EL slope prior
  S ~ dnorm(slope[1], 1 / slope[2] ^ 2)
  
  #mixture
  mixture_d18O = sum(fracs * h_s[, 2])
  mixture_d2H = sum(fracs * h_s[, 1])
  fracs ~ ddirch(alphas)
  
  #sources prior
  for(i in 1:nsource){
    h_s[i, 1:2] ~ dmnorm.vcov(sources[i, 1:2], 
                              sources.vcov[(1 + (i-1) * 2):(2 + (i-1) * 2),])
  }
}"

use_data(mwlModel, mixModel, internal = TRUE, overwrite = TRUE)
