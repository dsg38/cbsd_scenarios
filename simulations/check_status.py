import pathlib
import pandas as pd

infRasterPaths = pathlib.Path('sim_output/2021_03_17_cross_continental/2021_03_18_batch_0').rglob('O_0_L_0_INFECTIOUS_*')

progressDict = {}
for thisPathPath in infRasterPaths:

    thisPath = str(thisPathPath)

    thisJob = [x for x in thisPath.split('/') if 'job' in x][0]
    fileName = thisPath.split('/')[-1]
    thisYear = int(fileName.split('_')[-1].replace('.000000.tif', ''))

    if thisJob in progressDict:
        progressDict[thisJob].add(thisYear)
    else:
        progressDict[thisJob] = set([thisYear])

    
maxDict = {}
for jobKey, yearSet in progressDict.items():

    maxDict[jobKey] = max(yearSet)

    # breakpoint()

df = pd.DataFrame.from_dict(maxDict, orient='index', columns=['year'])

df.to_csv('progress.csv')

# thisPath = "sim_output/2021_03_17_cross_continental/2021_03_18_batch_0/job0/output/runfolder0/O_0_L_0_INFECTIOUS_2021.000000.tif"

