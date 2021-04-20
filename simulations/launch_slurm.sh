#!/bin/bash
#! Name of the job:
#SBATCH -J davids_stuff
#! Project name for Gilligan group,use SL2 for paying queue:
#SBATCH -A GILLIGAN-SL2-CPU
#! Output filename:
#SBATCH --output=davids_stuff_%A_%a.out 
#! Errors filename:
#SBATCH --error=davids_stuff_%A_%a.err 

#! How many whole nodes should be allocated?
#SBATCH --nodes=1
#! How many tasks will there be in total?
#SBATCH --ntasks=1
#! How many many cores will be allocated per task? 
#SBATCH --cpus-per-task=1 
#! Estimated runtime (job is force-stopped after if exceeded):
#SBATCH --time=12:00:00
#! Estimated memory needed (job is force-stopped if exceeded):
#SBATCH --mem=5980mb
#! Submit a job array with index values between 0 and n e.g. 0-100
#SBATCH --array=0-20

#! This is the partition name. This will request for a node with 6GB RAM for each task
#SBATCH -p skylake

#! mail alert at start,end and abortion of execution
#SBATCH --mail-type=ALL

#! Modify the environment seen by the application. For this example we need the default modules.
. /etc/profile.d/modules.sh                # This line enables the module command
module purge                               # Removes all modules still loaded
module load rhel7/default-peta4            # REQUIRED - loads the basic environment
module load use.own                        # This line loads the own module list
module load /rds/project/cag1/rds-cag1-general/epidem-modules/epidem.modules         # This line loads the Epidemiology group module list
module load pmpem
module load gcc
module load R-with-libraries

Rscript UTIL_fix_tif.R
