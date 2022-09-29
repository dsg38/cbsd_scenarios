from paramiko import SSHClient
from scp import SCPClient
import pandas as pd
from pathlib import Path

ssh = SSHClient()
ssh.load_system_host_keys()
ssh.connect(hostname='login-e-14.hpc.cam.ac.uk',
            username='dsg38',
            password='d1XL7KsNGRKX') # WARNING: DON'T LEAVE PASSWORD HARDCODED HERE

scp = SCPClient(ssh.get_transport())

dpcDf = pd.read_csv('./data/dpcDfInit.csv')
outDir = Path('./inf_rasters/raw/')

rootRemote = Path('/rds/project/rds-GzjXVr9dEIE/epidem-userspaces/dsg38/cbsd_scenarios/surveillance_optimisation/2022_09_29_cog_roads/inf_rasters/raw/')

for i, row in dpcDf.iterrows():

    scenario = row['scenario']
    batch = row['batch']
    job = row['job']
    rasterYear = row['raster_year']
    yearStandardised = row['year_standardised']

    outPath = rootRemote / (job + '-' + str(yearStandardised) + '.tif')

    print(i)
    print(outPath)

    thisJobPathLocal = Path('./inf_rasters/raw') / (job + '-' + str(yearStandardised) + '.tif')

    scp.get(outPath, thisJobPathLocal, recursive=True)

    # breakpoint()


scp.close()
