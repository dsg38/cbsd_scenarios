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

for thisJob in doneJobs:

    oldDir = oldBatch / thisJob
    newDir = newBatch / thisJob

    print(newDir)
    shutil.copytree(src=oldDir, dst=newDir, dirs_exist_ok=True)
