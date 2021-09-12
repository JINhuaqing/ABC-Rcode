setwd("/home/r6user2/Documents/TQ/ABC")
source("ABC_utils.R")


target <- 0.20
ncohort <- 12
cohortsize <- 3
init.level <- 1

# alp.prior, bet.prior, cutoff.eli, cutoff.num: parameters for early stopping
# J: number of samples for each event
# h: parameter for weights
# delta: different around phi for the prior samples
add.args <- list(alp.prior=0.5, bet.prior=0.5, J=2e4, delta=0.10, cutoff.eli=0.95, cutoff.num=3, h=0.01)

p.true <- c(0.05, 0.06, 0.08, 0.11, 0.19, 0.34)
tmtd <- MTD.level(target, p.true)

ndose <- length(p.true)

# generate the prior samples 
ps.name <- paste0("./pssprior-ndose-", ndose, "-phi-", 100*target, "-J-", add.args$J, "-delta-", 100*add.args$delta, ".RData")
if (file.exists(ps.name)){
        load(ps.name)
}else{
        pss.prior <- gen.prior(ndose, phi=target, J=add.args$J, delta=add.args$delta)
        save(pss.prior, file=ps.name)
}


ABC.res <- ABC.simu.fn(target, p.true, ncohort=ncohort, cohortsize=cohortsize, init.level=init.level,  add.args=add.args)
print(ABC.res)
    
