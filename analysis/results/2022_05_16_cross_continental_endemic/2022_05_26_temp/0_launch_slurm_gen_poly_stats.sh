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
#SBATCH --time=01:00:00
#! Estimated memory needed (job is force-stopped if exceeded):
#SBATCH --mem=3420mb
#! Submit a job array with index values between 0 and n e.g. 0-100
#SBATCH --array=0,2,3,4,5,7,9,10,12,14,15,16,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,35,36,38,39,40,41,42,43,47,48,50,52,55,56,57,58,60,61,63,64,65,66,67,68,69,71,72,73,74,75,76,77,79,81,82,83,84,85,86,87,88,90,91,93,94,95,97,98,99,101,102,103,104,105,106,107,108,110,112,113,114,115,117,119,121,122,123,124,126,127,128,129,130,131,132,134,135,136,137,138,139,140,141,142,145,146,147,148,149,150,151,152,153,156,159,161,162,164,165,166,168,169,171,172,173,174,175,176,177,178,179,180,181,182,184,185,187,188,189,190,191,192,194,198,199,200,201,202,203,204,205,206,207,208,209,211,212,213,215,218,219,220,221,222,223,224,225,230,231,232,235,238,239,241,242,243,244,245,246,247,248,251,253,254,255,256,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,281,282,283,284,285,287,288,290,291,293,294,295,296,298,299,301,303,304,305,306,307,308,311,312,314,315,316,317,318,319,320,322,325,327,328,329,332,333,335,336,337,338,339,340,341,343,344,345,347,348,350,351,352,354,355,356,357,358,360,364,365,366,367,368,369,370,372,373,374,375,376,377,378,379,380,381,382,383,384,385,387,388,389,391,392,393,395,396,397,398,399,401,403,404,405,407,408,409,410,411,412,413,414,415,416,417,418,420,422,424,426,427,428,429,431,432,433,434,435,436,437,438,439,440,441,442,443,449,450,451,452,453,455,456,457,458,459,460,461,462,463,464,465,468,470,472,474,475,476,477,478,481,485,486,489,491,493,495,496,497,498

#! This is the partition name. This will request for a node with 6GB RAM for each task
#SBATCH -p cclake

#! mail alert at start,end and abortion of execution
#SBATCH --mail-type=ALL

#! Modify the environment seen by the application. For this example we need the default modules.
. /etc/profile.d/modules.sh                # This line enables the module command
module purge                               # Removes all modules still loaded
module load rhel7/default-peta4            # REQUIRED - loads the basic environment
module load use.own                        # This line loads the own module list
module load /rds/project/cag1/rds-cag1-general/epidem-modules/epidem.modules         # Loads Epidemiology group module list
module load miniconda3/4.9.2

# Conda set up
# >>> conda initialize >>>
# Contents within this block are managed by 'conda init' !!
__conda_setup="$('/rds/project/cag1/rds-cag1-general/epidem-programs/miniconda3/4.9.2/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/rds/project/cag1/rds-cag1-general/epidem-programs/miniconda3/4.9.2/etc/profile.d/conda.sh" ]; then
        . "/rds/project/cag1/rds-cag1-general/epidem-programs/miniconda3/4.9.2/etc/profile.d/conda.sh"
    else
        export PATH="/rds/project/cag1/rds-cag1-general/epidem-programs/miniconda3/4.9.2/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# --------------------------------------------------------

# SET THIS CORRECTLY PER PROJECT
conda activate /rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/conda_env_default/dsg38

# Run stuff
Rscript ../../../package_inf_rasters/gen_poly_stats.R ./config/config_inf_polys.json $SLURM_ARRAY_TASK_ID

