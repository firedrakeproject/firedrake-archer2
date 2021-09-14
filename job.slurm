#!/bin/bash
#SBATCH -p standard
#SBATCH -A e682
#SBATCH -J firedrake
#SBATCH -N 1
#SBATCH --qos=short
#SBATCH --reservation=shortqos
#SBATCH -t 0:10:00

export LOCAL_BIN=/work/e682/e682/jbetteri/local/bin
# The script you want to run
myScript=script.py
# The number of nodes and total number of processors to use
nodes=1
nprocs=64

# The following lines should not require modification #######
module load epcc-job-env

# Activate Firedrake venv (activate once on first node, extract once per node)
source $LOCAL_BIN/firedrake_activate.sh
srun -n ${nodes} --ntasks-per-node 1 $LOCAL_BIN/firedrake_activate.sh

# Run Firedrake script
srun -n ${nprocs} $VIRTUAL_ENV/bin/python ${myScript}

# Update tarball with compiled code cache
$LOCAL_BIN/update_firedrake_cache.sh
