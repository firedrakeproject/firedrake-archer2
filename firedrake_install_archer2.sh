#!/bin/bash

##################################################
# Script for installing Firedrake on Archer2     #
# Written by Jack Betteridge February 2021       #
#                                                #
##################################################

### User Settings ###

# Give the venv a name
export NEW_VENV_NAME=firedrake
# Root of your _work_ directory on Archer2
export WORK=/work/e682/e682/jbetteri
# A location on your PATH where helper scripts can be placed
export LOCAL_BIN=$WORK/local/bin

### You shouldn't need to modify anything below here ###

# Clear everything
module purge
module load /work/y07/shared/archer2-modules/modulefiles-cse/epcc-setup-env

# Compiler
module load gcc/10.2.0
module load cmake/3.18.4
module load cpe-gnu
module load craype
module load craype-x86-rome

# Interconnect
module load libfabric
module load craype-network-ofi
module load xpmem
#~ module load /work/e682/e682/jbetteri/local/modulefiles/jack-dsmml
# Module broken!
module load cray-dsmml/0.1.3
# Because the module file is incomplete we must manually add:
#~ export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/opt/cray/pe/dsmml/0.1.2/dsmml/lib/pkgconfig

# Python and MPICH
module load cray-python/3.8.5.0
module load cray-mpich/8.1.3
# Symbols are missing from the 8.1.3 Cray MPICH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CRAY_MPICH_BASEDIR/gnu/9.1/lib

# Scientific libraries
module load cray-libsci/20.10.1.2
# Try the system science libs:
module load cray-hdf5-parallel/1.12.0.2
module load cray-netcdf-hdf5parallel/4.7.4.2
module load cray-parallel-netcdf/1.12.1.2
module load metis/5.1.0
module load parmetis/4.0.3
module load scotch/6.0.10
module load mumps/5.2.1
module load superlu-dist/6.1.1
module load hypre/2.18.0

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

# Create directory in /tmp so we don't have issues with the lustre filesystem
PREV_DIR=`pwd`
mkdir -p /tmp/$USER
cd /tmp/$USER
FIREDRAKE_INSTALL_DIR=`pwd`
# hdf5/h5py/netcdf difficult to install, help as much as possible
# by providing these paths
#~ export HDF5_DIR=$MAIN/$NEW_VENV_NAME/src/petsc/default
#~ export HDF5_MPI=ON
#~ export NETCDF4_DIR=$MAIN/$NEW_VENV_NAME/src/petsc/default

# Grab the Firedrake install script (currently in a branch)
#~ curl -O https://raw.githubusercontent.com/firedrakeproject/firedrake/master/scripts/firedrake-install

# Add the following options to build PETSc
export PETSC_CONFIGURE_OPTIONS="--with-mpi-dir=$CRAY_MPICH_BASEDIR/gnu/9.1/ \
    --with-hdf5-dir=$HDF5_DIR \
    --with-netcdf-dir=$NETCDF_DIR \
    --with-pnetcdf-dir=$PNETCDF_DIR \
    --with-metis-pkg-config=$METIS_DIR/lib/pkgconfig \
    --with-parmetis-pkg-config=$PARMETIS_DIR/lib/pkgconfig \
    --with-scotch-pkg-config=$SCOTCH_DIR/lib/pkgconfig \
    --with-ptscotch-pkg-config=$SCOTCH_DIR/lib/pkgconfig \
    --with-mumps-pkg-config=$MUMPS_DIR/lib/pkgconfig \
    --with-superlu_dist-pkg-config=$SUPERLU_DIST_DIR/lib/pkgconfig \
    --with-hypre-pkg-config=$HYPRE_DIR/lib/pkgconfig \
    --with-scalapack-lib=$CRAY_LIBSCI_PREFIX_DIR/lib/libsci_gnu.so \
    --with-x=0 --with-make-np=8 \
    --COPTFLAGS='-O3 -march=native -mtune=native' \
    --CXXOPTFLAGS='-O3 -march=native -mtune=native' \
    --FOPTFLAGS='-O3 -march=native -mtune=native'"

#     --with-shared-ld=$LINKER_X86_64 <-- Isn't set with GNU PE
export OVERRIDE_PETSC_CONFIGURE_OPTIONS="--with-cc=$MPICC \
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
    --download-eigen=/tmp/jbetteri/firedrake/src/eigen-3.3.3.tgz \
    --download-hwloc \
    --download-ml \
    --download-pastix \
    --download-suitesparse \
    --with-mpi-dir=$CRAY_MPICH_BASEDIR/gnu/9.1/ \
    --with-hdf5-dir=$HDF5_DIR \
    --with-netcdf-dir=$NETCDF_DIR \
    --with-pnetcdf-dir=$PNETCDF_DIR \
    --with-metis \
    --with-metis-pkg-config=$METIS_DIR/lib/pkgconfig \
    --with-parmetis \
    --with-parmetis-pkg-config=$PARMETIS_DIR/lib/pkgconfig \
    --with-scotch \
    --with-scotch-pkg-config=$SCOTCH_DIR/lib/pkgconfig \
    --with-ptscotch \
    --with-ptscotch-include=$SCOTCH_DIR/include \
    --with-ptscotch-lib=$SCOTCH_DIR/lib/libptscotch_gnu_mpi.a \
    --with-mumps \
    --with-mumps-pkg-config=$MUMPS_DIR/lib/pkgconfig \
    --with-superlu_dist \
    --with-superlu_dist-pkg-config=$SUPERLU_DIST_DIR/lib/pkgconfig \
    --with-hypre \
    --with-hypre-pkg-config=$HYPRE_DIR/lib/pkgconfig \
    --with-scalapack-lib=$CRAY_LIBSCI_PREFIX_DIR/lib/libsci_gnu.so \
    --with-x=0 \
    --with-make-np=8 \
    --COPTFLAGS='-O3 -march=native -mtune=native' \
    --CXXOPTFLAGS='-O3 -march=native -mtune=native' \
    --FOPTFLAGS='-O3 -march=native -mtune=native'"

#~ --CFLAGS=\"-I$CRAY_DSMML_DIR/include\" \
#~ --LDFLAGS=\"-Wl,-rpath,$CRAY_DSMML_DIR/lib -L$CRAY_DSMML_DIR/lib\"
#~ export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/opt/cray/pe/dsmml/0.1.2/dsmml/lib/pkgconfig

# Massive hack
# There is currently a permissions bug when cloning the petsc4py repo
# this hacky bash loop fixes the permissions when the repo is cloned
# and allows the installation to complete
#~ function hack {
    #~ ls -j 2> /dev/null
    #~ while [ $? -ne 0 ]
    #~ do
        #~ sleep 30s
        #~ chmod -R ug+rw $MAIN/$NEW_VENV_NAME/src/petsc4py/.git 2> /dev/null
    #~ done
    #~ echo WOOP!
#~ }
#~ hack &

# For an intreractive session:
# qsub -I -q arm-dev -l walltime=03:00:00

# Install firedrake with the following options
#~ --petsc-int-type int64
python firedrake-install \
    --mpicc=$MPICC \
    --mpicxx=$MPICXX \
    --mpif90=$MPIF90 \
    --mpiexec=/usr/bin/srun \
    --no-package-manager \
    --disable-ssh \
    --remove-build-files \
    --venv-name $NEW_VENV_NAME \
    --cache-dir $FIREDRAKE_INSTALL_DIR/.cache_$NEW_VENV_NAME

# Additional packages can be added to Firedrake upon a sucessful build
# using firedrake-update, see firedrake-update --help

# Now tarball the venv and cache so that it can be used on compute nodes
mkdir -p $FIREDRAKE_INSTALL_DIR/.cache_$NEW_VENV_NAME
touch $FIREDRAKE_INSTALL_DIR/.cache_$NEW_VENV_NAME/foo
tar -czvf $LOCAL_BIN/$NEW_VENV_NAME.tar.gz $NEW_VENV_NAME
tar -czvf $LOCAL_BIN/cache_$NEW_VENV_NAME.tar.gz .cache_$NEW_VENV_NAME

# Link to helper scripts
#~ ln -s $PREV_DIR/firedrake_activate.sh $LOCAL_BIN/firedrake_activate.sh
#~ ln -s $PREV_DIR/update_firedrake_cache.sh $LOCAL_BIN/update_firedrake_cache.sh
#~ ln -s $PREV_DIR/update_firedrake_tarball.sh $LOCAL_BIN/update_firedrake_tarball.sh
