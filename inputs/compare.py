from pathlib import Path
import filecmp 

newDir = Path('./inputs_scenarios/2021_03_17_cross_continental_TEST/survey_poly_index')
# otherDir = Path('../inputs_scenarios/2021_03_17_cross_continental/index/')
otherDir = Path('./inputs_scenarios/2021_03_17_cross_continental/index')

localPaths = list(newDir.glob('*'))

count = 0
for thisLocalPath in localPaths:

    # print(thisLocalPath.name)

    otherPath = otherDir / thisLocalPath.name

    x = filecmp.cmp(thisLocalPath, otherPath)

    if not x:
        print("SHITTTTTTTTTTTTTTTTTTTTTT")

    # print(x)
    # breakpoint()

    count += 1


print("num files: " +  str(count))
