setwd("/home/r6user2/Documents/TQ/ABC")
library(parallel)

source("utilities.R")
source("ABC_utils.R")


target <- 0.20
ncohort <- 12
cohortsize <- 3
init.level <- 1
nsimu <- 100
seeds <- 1:nsimu

add.args <- list(alp.prior=0.5, bet.prior=0.5, J=2e4, delta=0.10, cutoff.eli=0.95, cutoff.num=3)
p.true <- c(0.05, 0.06, 0.08, 0.11, 0.19, 0.34)
tmtd <- MTD.level(target, p.true)
print(p.true)

ndose <- length(p.true)
set.seed(1)
ps.name <- paste0("./pssprior-ndose-", ndose, "-phi-", 100*target, "-J-", add.args$J, "-delta-", 100*add.args$delta, ".RData")
if (file.exists(ps.name)){
        load(ps.name)
}else{
        pss.prior <- gen.prior(ndose, phi=target, J=add.args$J, delta=add.args$delta)
        save(pss.prior, file=ps.name)
}


run.fn <- function(i){
    print(i)
    set.seed(seeds[i])
    ABC.res <- ABC.simu.fn(target, p.true, ncohort=ncohort, cohortsize=cohortsize, init.level=init.level,  add.args=add.args)
    
    ress <- list(
                 ABC = ABC.res,
                 paras=list(p.true=p.true, 
                             mtd=tmtd, 
                             add.args=add.args,
                             target=target,
                             ncohort=ncohort,
                             cohortsize=cohortsize)
        )
    ress
    
}

ncores <- 50
m.names <- c("ABC")
results <- mclapply(1:nsimu, run.fn, mc.cores=ncores)
file.name <- paste0("./results/", "SimuABC", "_", nsimu, "_ncohort_", ncohort, ".RData")
save(results, file=file.name)


sum.all <- list()
for (m.name in m.names){
   sum.all[[m.name]] <-  phase1.post.fn(lapply(1:nsimu, function(i)results[[i]][[m.name]]))
}
print(tmtd)
print(phase.I.pretty.tb(sum.all))
