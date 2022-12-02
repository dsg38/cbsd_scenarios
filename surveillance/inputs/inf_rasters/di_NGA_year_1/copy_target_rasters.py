import pandas as pd
from pathlib import Path
import shutil
import sys

year = 1
batchDir = Path('../../../../simulations/sim_output/2022_11_25_direct_intro_NGA_weighted/2022_11_25_batch_0/')
outDir = Path('./raw')

# ----------------------------------------

outDir.mkdir(exist_ok=True, parents=True)

for i in range(250):

    print(i)

    job = 'job' + str(i)

    rasterPath = batchDir / job / 'output/runfolder0/O_0_L_0_INFECTIOUS_1.000000.tif'

    if not rasterPath.exists():
        print(rasterPath)
        raise Exception("Path missing")

    outPath = outDir / (job + '.tif')

    shutil.copy(rasterPath, outPath)

