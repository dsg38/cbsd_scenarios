import pandas as pd
from pathlib import Path
import shutil
import sys

year = 1
batchDir = Path('../../../../simulations/sim_output/2022_11_25_direct_intro_NGA_weighted/2022_11_25_batch_0/')
outDir = Path('./raw')

# ----------------------------------------

rasterPathList = list(batchDir.rglob('O_0_L_0_INFECTIOUS_' + str(year) + '.000000.tif'))
outDir.mkdir(exist_ok=True, parents=True)

for i, rasterPath in enumerate(rasterPathList):

    print(i)

    # print(rasterPath)

    job = rasterPath.parts[-4]

    if not rasterPath.exists():
        print(rasterPath)
        raise Exception("Path missing")

    outPath = outDir / (job + '-' + str(year) + '.tif')

    # print(outPath)

    shutil.copy(rasterPath, outPath)

