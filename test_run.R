library(doParallel)
library(ResistanceGA)

# Need GA_CORES * CS_CORES available
GA_CORES = 2
CS_CORES = 2

## The test data here are what is supplied in the ResistanceGA package
## Sample locations
sp.dat <- sample_pops$sample_cont

## Continuous landscape surface
cont.rast <- raster_orig$cont_orig

## Genetic distance measured between sample locations (chord distance)
gen.dist <- Dc_list$Dc_cont

# Create a directory for the results
if (!dir.exists("rga_examples")) {dir.create("rga_examples")}

# pull the JULIA_HOME value from the environment variable
JULIA_HOME <- Sys.getenv("JULIA_HOME")
JuliaCall::julia_setup(JULIA_HOME)

# I can get parallelization to work on the GA side only if I create 
# the cluster for the R side myself and pass that in.
r_cluster = makeCluster(GA_CORES, type="PSOCK")
registerDoParallel(r_cluster)

GA.inputs <- GA.prep(ASCII.dir = cont.rast, 
					 Results.dir = "rga_examples/",
					 parallel = r_cluster)

jl.inputs <- jl.prep(n.Pops = length(sp.dat),
	                 response = lower(gen.dist), 
	                 CS_Point.File = sp.dat, 
	                 JULIA_HOME = JULIA_HOME,
	                 parallel=TRUE,
	                 cores=CS_CORES)

jl.optim <- SS_optim(jl.inputs = jl.inputs, GA.inputs = GA.inputs)
