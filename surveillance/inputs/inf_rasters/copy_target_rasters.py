import pandas as pd
from pathlib import Path
import shutil
import sys

polyDfPath = Path(sys.argv[1])

outDir = polyDfPath.parent / 'raw'

polyDf = pd.read_csv(polyDfPath)

outDir.mkdir(exist_ok=True, parents=True)

for i, row in polyDf.iterrows():

    scenario = row['scenario']
    batch = row['batch']
    job = row['job']
    rasterYear = row['raster_year']
    yearStandardised = row['year_standardised']

    rasterPath = Path('../../../simulations/sim_output') / scenario / batch / job / 'output/runfolder0' / ('O_0_L_0_INFECTIOUS_' + str(rasterYear) + '.000000.tif')

    if not rasterPath.exists():
        print(rasterPath)
        raise Exception("Path missing")

    outPath = outDir / (job + '-' + str(yearStandardised) + '.tif')

    print(i)
    print(outPath)

    shutil.copy(rasterPath, outPath)

