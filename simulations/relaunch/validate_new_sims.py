from pathlib import Path
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
jobDirsNew = list(relaunchBatchPath.glob('job*'))

# Parse rand seed from old/new
randSeedDictNew = {}
for jobDirNew in jobDirsNew:

    masterPath = jobDirNew / 'output/runfolder0/M_MASTER.txt'

    masterDict = utils_parse.parseMaster(masterPath)

    randSeedDictNew[masterDict['RNGSeed']] = jobDirNew


randSeedDictOld = {}
for k, v in relaunchDict.items():
    
    # jobDirOld = simOutputPath / k

    randSeed = v['params']['RNGSeed']

    randSeedDictOld[randSeed] = k

# Find matches
matchPathDict = {}
for k, v in randSeedDictNew.items():

    if k in randSeedDictOld:

        matchPathDict[v] = randSeedDictOld[k]


print("PROP MATCH OUT OF TOTAL:")
print(str(len(matchPathDict) / len(randSeedDictOld)))

diffDict = {}
for jobDirNew, jobStrOld in matchPathDict.items():

    diffDict[jobStrOld] = {}

    jobDirOld = simOutputPath / jobStrOld
    oldJobData = relaunchDict[jobStrOld]

    jobDirOldFull = jobDirOld / 'output/runfolder0'
    jobDirNewFull = jobDirNew / 'output/runfolder0'

    # List all files
    filepathsOld = list(jobDirOldFull.iterdir())
    filepathsNew = list(jobDirNewFull.iterdir())

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

        thisFilenameOld = jobDirOldFull / thisFilename
        thisFilenameNew = jobDirNewFull / thisFilename

        matchBool = filecmp.cmp(thisFilenameOld, thisFilenameNew)
        diffDict[jobStrOld][thisFilename] = matchBool

utils_parse.writeDictToJson(diffDict, "check.json")
