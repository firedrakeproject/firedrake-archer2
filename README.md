## Building Firedrake on Archer2

Please follow the following to build and test Firedrake on Archer2.

1.  Pick your work directory (e.g., `/work/your_account/shared`), set `WORK` environment variable, and `cd` to `$WORK`:
    ```bash
    export WORK=/your/work/dir
    mkdir -p $WORK
    cd $WORK
    ```
2.  Pick Firedrake install directory (e.g., `$WORK/firedrake`) and set `$FIREDRAKE_DIR` environment variable:
    ```bash
    export FIREDRAKE_DIR=/your/firedrake/install/dir
    ```
3.  Clone this repository in `$FIREDRAKE_DIR`:
    ```bash
    git clone https://github.com/firedrakeproject/firedrake-archer2.git $FIREDRAKE_DIR
    ```
4.  Build Firedrake by running:
    ```bash
    bash $FIREDRAKE_DIR/firedrake_install_archer2.sh
    ```
    This will take about 30 minutes.
5.  To test installation, move `$FIREDRAKE_DIR/job.slurm` and `$FIREDRAKE_DIR/example.py` to the current directory.
    In `job.slurm`, change the account name to your own account name and the FIREDRAKE_DIR environment variable to `$FIREDRAKE_DIR` and then submit the job:
    ```bash
    mv $FIREDRAKE_DIR/job.slurm job.slurm
    mv $FIREDRAKE_DIR/example.py example.py
    # Change account name and FIREDRAKE_DIR environment variable in job.slurm.
    sbatch job.slurm
    ```
