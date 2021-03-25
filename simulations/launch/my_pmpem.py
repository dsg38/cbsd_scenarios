#!/usr/bin/python3
import time
import pmpem.mngr, pmpem.utils, pmpem.landscape
from pmpem.pmpemopts import PmpemOpts
import subprocess
import pathlib
import sys

## Sets the parameters of the MPEM model.
def setmodelparameters(x=None):

    # Generate the PMPEM parameters
    opts=PmpemOpts(0)
    opts.setParamsToDefault()
    
    # --------------------------
    # DEFAULT PARAMS
    # NB: THESE ARE OVERWRITTEN BY PARAM FILE VALUES BY LOOP AT THE BOTTOM
    # --------------------------
    opts.changempemparams('MaxHosts', 1000)

    opts.changempemparams('Kernel_0_Type', "PowerLaw")
    opts.changempemparams('Kernel_0_Range', 500)
    opts.changempemparams('Kernel_0_Parameter', 1)
    opts.changempemparams('Kernel_0_WithinCellProportion', 1)
    opts.changempemparams('Kernel_0_VirtualSporulationTransition', 1)
    opts.changempemparams('Kernel_0_VirtualSporulationTransitionByRange', 7)

    opts.changempemparams('Model', 'SIRS')
    opts.changempemparams('Rate_0_Sporulation', 1)
    opts.changempemparams('Rate_0_ItoR', 0)
    opts.changempemparams('Rate_0_RtoS', 0)

    opts.changempemparams('WeatherEnable', 1)
    opts.changempemparams('WeatherFileName', 'P_WeatherSwitchTimes.txt')

    opts.changempemparams('DPCTimeFirst', 0)
    opts.changempemparams('DPCFrequency', 0.25)

    opts.changempemparams('BatchEnable', 0)
    opts.changempemparams('BatchRuns', 1)

    surveyTimingJson = '{"2005":"2004_raster_total.asc","2006":"2005_raster_total.asc","2007":"2006_raster_total.asc","2008":"2007_raster_total.asc","2009":"2008_raster_total.asc","2010":"2009_raster_total.asc","2011":"2010_raster_total.asc","2012":"2011_raster_total.asc","2013":"2012_raster_total.asc","2014":"2013_raster_total.asc","2015":"2014_raster_total.asc","2016":"2015_raster_total.asc","2017":"2016_raster_total.asc","2018":"2017_raster_total.asc","2019":"2018_raster_total.asc"}'
    opts.changempemparams('ManagementSurveillanceTimesAndFiles', surveyTimingJson)
    opts.changempemparams('ManagementDetectionProbability', 0.85)

    opts.changempemparams('RasterDisable_ALL', 1)
    opts.changempemparams('RasterFirst', 0)
    opts.changempemparams('RasterEnable_0_INFECTIOUS', 1)

    # --------------------------
    # DANGER: OVERWRITE PARAMS BASED ON PARAMS FILE
    # This allows for arbitrarily many columns in the parameters file, 
    # and that the settings here will override any above
    # --------------------------
    for colName, colValue in x.items():
        opts.changempemparams(colName, colValue)

    return opts


def processonerun(folder):

    print("MADE IT TO processonerun")
    print("folder:")
    print(folder)

    results = pmpem.utils.getparamsandsummarystats(folder)

    # Build abs path
    thisFileDir = pathlib.Path(__file__).parent.absolute()
    folderPathAbsolute = str(thisFileDir / folder)

    print("thisFileDir")
    print(thisFileDir)

    print("folderPathAbsolute")
    print(folderPathAbsolute)

    print("SUBPROCESS CMD:")
    
    cmd = [
        '/rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_scenarios/simulations/launch/my_pmpem_fix_tif.sh',
        folderPathAbsolute
    ]

    print(cmd)

    subprocess.call(cmd)

    print("MADE IT PAST SUBPROCESS")

    return 1

def processallruns(outputpath, runfolders):
    pmpem.utils.combineresultsfiles(outputpath, runfolders)
    return 1

def calcCheckpointTimeSecs(time_str):
    """Get Seconds from time."""
    h, m, s = time_str.split(':')
    numSecs =  int(h) * 3600 + int(m) * 60 + int(s)

    if numSecs > (6*60*60):
        # If run time is more than 6 hours, checkpoint -1 hour 
        chksecs = numSecs - (60*60)
    else:
        # If runtime less than 6 hours, checkpoint 25% early
        chksecs =  int(round(numSecs * 0.75))
    
    return(chksecs)


def parseCheckpointTime():

    # Get all cmd line args
    args = sys.argv

    # chksecs = None

    # # If specified in cmd args
    # if '--chksecs' in args:

    #     print("chksecs from cmd args")

    #     for i in range(len(args)):
    #         if args[i] == '--chksecs':
    #             chksecs = int(args[i+1])
    # else:

    print("chksecs auto")

    # Extract runtimerequest
    runtimerequest = None
    for i in range(len(args)):
        if args[i] == '--runtimerequest':
            runtimerequest = args[i+1]

    assert(runtimerequest != None)

    print("runtimerequest:")
    print(runtimerequest)

    # Calc chksecs
    chksecs = calcCheckpointTimeSecs(runtimerequest)

    assert(chksecs != None)

    print("chksecs:")
    print(chksecs)

    return(chksecs)


if __name__ ==  '__main__':
    start = time.time()

    chksecs = parseCheckpointTime()

    ###########################################################################
    # Initialise the object with reference to the functions that
    # generate the run folders and the generation of simulation parameters
    mngr = pmpem.mngr.mngr( outputpath='output',
    						genfoldersfunc=None,
    						setmodelparametersfunc=setmodelparameters,
    						processonerunfunc=processonerun,
    						processallrunsfunc=processallruns)

    ############################################################################
    # Do the runs and process the results
    mngr.runoperation(nbatchrunscatofftime=7200, chksecs=chksecs)

    end = time.time()
    print("Simulations execution time: ", end - start, " seconds.")
