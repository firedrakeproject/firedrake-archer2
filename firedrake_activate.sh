#!/bin/bash

##################################################
# Script for activating the Firedrake venv       #
# on Archer2 when installed using corresponding  #
# script                                         #
# Written by Jack Betteridge April 2020          #
# Updated by Koki Sagiyama September 2021        #
# Update by Joe Wallwork December 2021           #
#                                                #
##################################################

### User Settings ###
export VENV_NAME=firedrake
export LOCAL_BIN=$FIREDRAKE_DIR/local/bin
export PTSCOTCH_PKG_CONFIG_DIR=$LOCAL_BIN
export PETSC_DIR=/tmp/$USER/petsc
export PETSC_ARCH=default

### You shouldn't need to modify anything below here ###
### Load required modules ###
# Clear everything
module purge
module load load-epcc-module
module load epcc-setup-env
# Compiler
module load gcc/10.2.0
module load cmake/3.18.4
# module load cpe-gnu       NOTE: no longer available
module load craype
module load craype-x86-rome
# Interconnect
module load libfabric
module load craype-network-ofi
module load xpmem
# Module broken!
module load cray-dsmml/0.1.4
# Python and MPICH
module load cray-python/3.8.5.0
module load cray-mpich/8.1.9
# Symbols are missing from the 8.1.3 Cray MPICH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CRAY_MPICH_BASEDIR/gnu/9.1/lib
# Scientific libraries
module load cray-libsci/21.08.1.2
module load cray-hdf5-parallel/1.12.0.7
module load cray-netcdf-hdf5parallel/4.7.4.7
module load cray-parallel-netcdf/1.12.1.7
module load PrgEnv-gnu
module load metis/5.1.0
module load parmetis/4.0.3
module load scotch
module load mumps
module load superlu-dist
module load hypre
export HDF5_MPI="ON"
export PTSCOTCH_PKG_CONFIG_DIR=$LOCAL_BIN
mkdir -p $PTSCOTCH_PKG_CONFIG_DIR
if [ ! -f $PTSCOTCH_PKG_CONFIG_DIR/ptscotch.pc ]; then
    ln -s /work/y07/shared/libs/core/scotch/6.1.0/GNU/9.3/lib/pkgconfig/ptscotch_gnu_mpi.pc $PTSCOTCH_PKG_CONFIG_DIR/ptscotch.pc
fi
# Dynamic linking
export CRAYPE_LINK_TYPE=dynamic
export MPICH_GNI_FORK_MODE=FULLCOPY
# Set all compilers to be Cray wrappers
export CC=cc
export CXX=CC
export F90=ftn
export MPICC=cc
export MPICXX=CC
export MPIF90=ftn
# Needed for numpy and scipy
export LAPACK=$CRAY_LIBSCI_PREFIX_DIR/lib/libsci_gnu.so
export BLAS=$CRAY_LIBSCI_PREFIX_DIR/lib/libsci_gnu.so
# PYTHONPATH is set by Cray python and not helpful here!
unset PYTHONPATH

# Set main to be working directory
# Create this in /tmp so we don't have issues with the lustre filesystem
mkdir -p /tmp/$USER
cd /tmp/$USER
export FIREDRAKE_INSTALL_DIR=`pwd`

# Set the PyOP2 compiler to the Cray wrapper
# This currently requires a branch of PyOP2 to work correctly
export PYOP2_BACKEND_COMPILER=cc
export PYOP2_CFLAGS=-fno-tree-loop-vectorize

tar -xzf $LOCAL_BIN/$VENV_NAME.tar.gz -C /tmp/$USER
tar -xzf $LOCAL_BIN/petsc.tar.gz -C /tmp/$USER
tar -xzf $LOCAL_BIN/cache_$VENV_NAME.tar.gz -C /tmp/$USER

source $FIREDRAKE_INSTALL_DIR/$VENV_NAME/bin/activate

# Single OpenMP thread only
export OMP_NUM_THREADS=1

# A home directory is required for some functionality
export HOME=$WORK
# Return to original directory
cd -
