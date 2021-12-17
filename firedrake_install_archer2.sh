#!/bin/bash

##################################################
# Script for installing Firedrake on Archer2     #
# Written by Jack Betteridge February 2021       #
# Updated by Koki Sagiyama September 2021        #
# Updated by Joe Wallwork December 2021          #
#                                                #
##################################################

### For standard usage, you shouldn't need to modify anything in this script ###

# A location on your PATH where helper scripts can be placed
export LOCAL_BIN=$FIREDRAKE_DIR/local/bin
mkdir -p $LOCAL_BIN

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

### Install PETSc ###
export PETSC_DIR=/tmp/$USER/petsc
export PETSC_ARCH=default
mkdir -p /tmp/$USER
cd /tmp/$USER
export EIGEN_DIR=/tmp/$USER/3.3.3.tar.gz
if [ ! -f $EIGEN_DIR ]; then
    wget https://github.com/eigenteam/eigen-git-mirror/archive/3.3.3.tar.gz
fi
if [ ! -d ./petsc ]; then
    git clone https://github.com/firedrakeproject/petsc.git
fi
export COPTFLAGS="-O3 -march=native -mtune=native"
export CXXOPTFLAGS="-O3 -march=native -mtune=native"
export FOPTFLAGS="-O3 -march=native -mtune=native"
export PETSC_CONFIGURE_OPTIONS="--with-mpi-dir=$CRAY_MPICH_BASEDIR/gnu/9.1/ \
    --with-hdf5-dir=$HDF5_DIR \
    --with-netcdf-dir=$NETCDF_DIR \
    --with-pnetcdf-dir=$PNETCDF_DIR \
    --download-metis \
    --download-parmetis \
    --with-metis \
    --with-parmetis \
    --with-metis-pkg-config=$METIS_DIR/lib/pkgconfig \
    --with-parmetis-pkg-config=$PARMETIS_DIR/lib/pkgconfig \
    --with-scotch \
    --with-scotch-pkg-config=$SCOTCH_DIR/lib/pkgconfig \
    --with-ptscotch \
    --with-ptscotch-pkg-config=$PTSCOTCH_PKG_CONFIG_DIR \
    --with-ptscotch-include=$SCOTCH_DIR/include \
    --with-ptscotch-lib=$SCOTCH_DIR/lib/libptscotch_gnu_mpi.a \
    --with-mumps-pkg-config=$MUMPS_DIR/lib/pkgconfig \
    --with-superlu_dist \
    --with-superlu_dist-pkg-config=$SUPERLU_DIST_DIR/lib/pkgconfig \
    --with-hypre \
    --with-hypre-pkg-config=$HYPRE_DIR/lib/pkgconfig \
    --with-mumps \
    --with-mumps-pkg-config=$MUMPS_DIR/lib/pkgconfig \
    --with-scalapack-lib=$CRAY_LIBSCI_PREFIX_DIR/lib/libsci_gnu.so \
    --with-x=0 --with-make-np=8 \
    --COPTFLAGS=$COPTFLAGS \
    --CXXOPTFLAGS=$CXXOPTFLAGS \
    --FOPTFLAGS=$FOPTFLAGS \
    --with-cc=$MPICC \
    --with-cxx=$MPICXX \
    --with-fc=$MPIF90 \
    --with-fortran-bindings=0 \
    --with-mpiexec=/usr/bin/srun \
    --with-zlib \
    --with-c2html=0 \
    --with-shared-libraries=1 \
    --with-debugging=0 \
    --with-cxx-dialect=C++11 \
    --download-chaco \
    --download-eigen=$EIGEN_DIR \
    --download-hwloc \
    --download-ml \
    --download-pastix \
    --download-suitesparse \
    --with-mpi-dir=$CRAY_MPICH_BASEDIR/gnu/9.1/ \
    --with-hdf5-dir=$HDF5_DIR \
    --with-netcdf-dir=$NETCDF_DIR \
    --with-pnetcdf-dir=$PNETCDF_DIR \
    --with-x=0 \
    --with-make-np=8"

cd petsc
# Add remote repo and checkout your branch if desired:
# git remote add foo https://github.com/...
# git fetch foo
# git checkout your/petsc/branch
./configure $PETSC_CONFIGURE_OPTIONS
make all

### Install Firedrake ###
# Create directory in /tmp so we don't have issues with the lustre filesystem
FIREDRAKE_INSTALL_DIR=/tmp/$USER
mkdir -p $FIREDRAKE_INSTALL_DIR
cd $FIREDRAKE_INSTALL_DIR
if [ ! -f $FIREDRAKE_INSTALL_DIR/firedrake-install ]; then
    curl -O https://raw.githubusercontent.com/firedrakeproject/firedrake/master/scripts/firedrake-install
fi

# Install firedrake with the following options
export VENV_NAME=firedrake
export FIREDRAKE_INSTALL_OPTIONS="--honour-petsc-dir \
    --mpicc=$MPICC \
    --mpicxx=$MPICXX \
    --mpif90=$MPIF90 \
    --mpiexec=/usr/bin/srun \
    --no-package-manager \
    --disable-ssh \
    --remove-build-files \
    --venv-name $VENV_NAME \
    --cache-dir $FIREDRAKE_INSTALL_DIR/.cache_$VENV_NAME \
    --package-branch PyOP2 JDBetteridge/isambard_fix "

python firedrake-install $FIREDRAKE_INSTALL_OPTIONS

# Now tarball the venv and cache so that it can be used on compute nodes
mkdir -p $FIREDRAKE_INSTALL_DIR/.cache_$VENV_NAME
touch $FIREDRAKE_INSTALL_DIR/.cache_$VENV_NAME/foo

tar -czvf $LOCAL_BIN/$VENV_NAME.tar.gz $VENV_NAME
tar -czvf $LOCAL_BIN/petsc.tar.gz petsc
tar -czvf $LOCAL_BIN/cache_$VENV_NAME.tar.gz .cache_$VENV_NAME
