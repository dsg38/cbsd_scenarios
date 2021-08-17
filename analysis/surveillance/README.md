`pass_criteria.R`

- Hacky. Based on output file from box plot arrival times, work out which sims meet a given critera
- E.g. criteria = sims that arrive in NGA at least 5 years before sim ends (so can analyse 5 years worth of infection)

`process_rasters.R`

- Based on above set of sims, crop the inf rasters to be as small as possible to speed up computation / allow local processing etc.

`crop_host.R`

- Crop the host landscape to same extent

`convert_num_fields.R`

- Convert the cropped inf rasters to inf num field rasters, using the above cropped host landscape

`extract_survey.R`

- Gen sf df of the survey locations. E.g. NGA 2017 survey structure

`gen_survey_structure.R`

- Based on the survey points and raster extent/resolution, work out how many surveys per raster cell index.
- HACK: Currently, at this step, I also check to see if the number of surveys in a given cell exceed the number of host (fields) in that cell. If so, for now, I just drop these survey points. In the future, I will modify the host landscape so there is enough host for all survey points. 

`sample.R`



`analysis.R`
