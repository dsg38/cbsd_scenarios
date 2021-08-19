import subprocess
from pathlib import Path

scenario = '2021_03_26_cross_continental'
batch = '2021_03_29_batch_0'
job = 'job133'

detection_year = 1

# ----------------------------------------------

detection_year_str = 'detection_year_' + str(detection_year)

topDir = Path('./outputs') / scenario / 'plots'

infRasterDir = topDir / 'inf_rasters'
infPropDir = topDir / 'inf_prop'
surveyDir = topDir / 'surveys'

infRasterPlotPaths = infRasterDir.glob(batch + '-' + job + '*')

for infRasterPlotPath in infRasterPlotPaths:

    plotName = infRasterPlotPath.name

    print(plotName)

    outPath = Path('./outputs/2021_03_26_cross_continental/plots/montage/') / detection_year_str / plotName

    outPath.parent.mkdir(parents=True, exist_ok=True)

    cmd = [
        'montage',
        surveyDir / plotName,
        './outputs/2021_03_26_cross_continental/plots/host/host.png',
        infRasterPlotPath,
        infPropDir / plotName,
        '-resize',
        'x1000',
        '-density',
        '600',
        '-tile',
        '2x2',
        '-geometry',
        '+5+5',
        '-border',
        '10',
        outPath
    ]

    subprocess.call(cmd)
