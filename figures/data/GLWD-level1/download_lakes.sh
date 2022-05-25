#!/bin/bash

mkdir ./raw_data

wget -O ./raw_data/8ark3lcpfw_GLWD_level1.zip https://files.worldwildlife.org/wwfcmsprod/files/Publication/file/8ark3lcpfw_GLWD_level1.zip

unzip ./raw_data/8ark3lcpfw_GLWD_level1.zip -d ./raw_data

rm ./raw_data/8ark3lcpfw_GLWD_level1.zip

Rscript build_lakes_gpkg.R
