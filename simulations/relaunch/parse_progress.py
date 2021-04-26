from pathlib import Path
import utils_parse

batchPathListStr = [
    '../sim_output/2021_03_26_cross_continental/2021_03_26_batch_0',
    '../sim_output/2021_03_26_cross_continental/2021_03_29_batch_0',
]

# ---------------------------------
batchPathList = [Path(x) for x in batchPathListStr]

restartDict = {}
for batchDfPath in batchPathList:

    thisRestartDict = utils_parse.buildRestartDict(
        batchDfPath=batchDfPath
    )

    restartDict = {**restartDict, **thisRestartDict}


utils_parse.writeDictToJson(restartDict, "stuff.json")
