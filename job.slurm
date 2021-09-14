#!/bin/bash
#SBATCH -p standard
#SBATCH -A your_account
#SBATCH -J firedrake
#SBATCH --nodes=2
#SBATCH --cpus-per-task=1
#SBATCH --qos=standard
#SBATCH -t 00:10:00

# This is your working directory.
export FIREDRAKE_DIR=/your/firedrake/install/dir

# This is the script you want to run.
myScript=example.py

# The following lines should not require modification #######
export FI_OFI_RXM_SAR_LIMIT=64K
module load epcc-job-env
# Activate Firedrake venv (activate once on first node, extract once per node)
source $FIREDRAKE_DIR/firedrake_activate.sh
srun --ntasks-per-node 1 $FIREDRAKE_DIR/firedrake_activate.sh
# Run script.
srun --ntasks-per-node 128 $VIRTUAL_ENV/bin/python ${myScript}
