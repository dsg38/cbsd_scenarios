from pathlib import Path
import filecmp 

# newDir = Path('./inputs_scenarios/2021_03_17_cross_continental_TEST/survey_poly_index')
# otherDir = Path('./inputs_scenarios/2021_03_17_cross_continental/index')

newDir = Path('/home/dsg38/Documents/gilligan_lab/cbsd_scenarios/inputs/process_polys/FUCK/mask_stats/survey_data_C')
otherDir = Path('../../cbsd_landscape_model/summary_stats/mask_stats/survey_data_C')

localPaths = [x for x in list(newDir.iterdir()) if x.is_file()]

count = 0
for thisLocalPath in localPaths:

    # print(thisLocalPath.name)

    otherPath = otherDir / thisLocalPath.name

    if otherPath.exists():

        x = filecmp.cmp(thisLocalPath, otherPath)

        if not x:
            print("SHITTTTTTTTTTTTTTTTTTTTTT")

        # print(x)
        # breakpoint()

        count += 1


print("num files: " +  str(count))
