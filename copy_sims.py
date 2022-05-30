import pandas as pd
import natsort
import shutil
from pathlib import Path

oldBatch = Path("./simulations/sim_output/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/")
newBatch = Path("./simulations/sim_output/2022_05_16_cross_continental_endemic/2022_05_26_temp/")

progDf = pd.read_csv("./simulations/sim_output/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/progress.csv")

# Pull out complete
doneDf = progDf[(progDf['numRastersTif'] == 51)]

doneJobs = list(natsort.natsorted(doneDf['jobName']))[0:1000]

i = 0
for thisJob in doneJobs:

    oldDir = oldBatch / thisJob
    newDir = newBatch / thisJob

    if not newDir.exists():
        print(newDir)
        print(i)

        shutil.copytree(src=oldDir, dst=newDir, dirs_exist_ok=True)

        i += 1

# x = [x.replace('job', '') for x in doneJobs]

# with open("text.txt", 'w') as file:
#     file.write(','.join(x))
