from pathlib import Path
import utils_parse
import natsort
import utils_parse
import filecmp

relaunchJsonPathStr = './relaunch_specs/2021_03_26_cross_continental_0.json'
relaunchBatchPathStr = '../sim_output/2021_03_26_cross_continental/2021_04_26_batch_0'

simOutputPath = Path('../sim_output')

# ---------------------------------------------------------

filenamesEssential = {
    'M_MASTER.txt'
}


relaunchDict = utils_parse.readJsonToDict(relaunchJsonPathStr)
relaunchBatchPath = Path(relaunchBatchPathStr)

# NB: These should be ordered same as dict
jobDirsNew = natsort.natsorted(list(relaunchBatchPath.glob('job*')))

relaunchKeys = list(relaunchDict.keys())

diffDict = {}
for i in range(len(relaunchKeys)):

    relaunchKey = relaunchKeys[i]
    diffDict[relaunchKey] = {}

    print(relaunchKey)

    oldJobData = relaunchDict[relaunchKey]
    jobDirNew: Path = jobDirsNew[i] / 'output/runfolder0'

    jobDirOld: Path = simOutputPath / relaunchKey / 'output/runfolder0'

    # List all files
    filepathsOld = list(jobDirOld.iterdir())
    filepathsNew = list(jobDirNew.iterdir())

    filenamesOld = set([x.name for x in filepathsOld])
    filenamesNew = set([x.name for x in filepathsNew])

    filenamesMatch = filenamesOld.intersection(filenamesNew)

    # Check essential filenames present
    happyBool = filenamesEssential.issubset(filenamesMatch)
    if not happyBool:
        raise Exception("essentialFilesMissing")

    # For each matching file, diff and report
    for thisFilename in sorted(list(filenamesMatch)):

        print(thisFilename)

        thisFilenameOld = jobDirOld / thisFilename
        thisFilenameNew = jobDirNew / thisFilename

        matchBool = filecmp.cmp(thisFilenameOld, thisFilenameNew)
        diffDict[relaunchKey][thisFilename] = matchBool

utils_parse.writeDictToJson(diffDict, "check.py")
