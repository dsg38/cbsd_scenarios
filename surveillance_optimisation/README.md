# 0_gen_mask.R

Create a bool raster defining the spatial region in which the optimisation can place survey points. Or more specifically, 

# 1_preprocess_inf_rasters.R

Use the mask to zero out regions of the inf rasters outside allowed region. 

This script also adds up all these inf rasters and saves an xy dataframe of populated cell centroids and the corresponding sum inf prop value.

TODO: Why does this df need the sum value?


