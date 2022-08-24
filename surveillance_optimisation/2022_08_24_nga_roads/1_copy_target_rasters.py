import pandas as pd
from pathlib import Path
import shutil

dpcDf = pd.read_csv('./data/dpcDf.csv')
outDir = Path('./inf_rasters/raw/')

outDir.mkdir(exist_ok=True, parents=True)

for i, row in dpcDf.iterrows():

    scenario = row['scenario']
    batch = row['batch']
    job = row['job']
    rasterYear = row['raster_year']
    yearStandardised = row['year_standardised']

    rasterPath = Path('../../simulations/sim_output') / scenario / batch / job / 'output/runfolder0' / ('O_0_L_0_INFECTIOUS_' + str(rasterYear) + '.000000.tif')

    if not rasterPath.exists():
        print(rasterPath)
        raise Exception("Path missing")

    outPath = outDir / (job + '-' + str(yearStandardised) + '.tif')

    print(i)
    print(outPath)

    shutil.copy(rasterPath, outPath)


