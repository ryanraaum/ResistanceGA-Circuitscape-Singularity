#!/usr/bin/env bash

# if the userspace julia registry doesn't yet exist, create it
if ! [[ -d `pwd`/.julia ]]
then
	# Need to initialize the userspace julia registry, 
	# otherwise it will try to make changes to the (read-only) system registry
	JULIA_DEPOT_PATH=`pwd`/.julia /usr/local/julia/bin/julia -e 'using Pkg; Pkg.add("Example"); Pkg.rm("Example");'
	# Then add needed packages. These won't actually get installed, it will just
	# link to the already installed and precompiled system registry
	JULIA_DEPOT_PATH=`pwd`/.julia:$JULIA_DEPOT_PATH /usr/local/julia/bin/julia -e 'using Pkg; Pkg.add("Suppressor"); Pkg.add("Circuitscape");'
fi

# If you shell into the singularity container, you need to run this in your
# working directory to get the JULIA_DEPOT_PATH set properly
export JULIA_DEPOT_PATH=`pwd`/.julia:$JULIA_DEPOT_PATH

Rscript --vanilla "$@"