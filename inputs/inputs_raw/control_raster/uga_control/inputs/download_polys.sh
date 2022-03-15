#!/bin/bash

# Data website: https://data.humdata.org/dataset/cod-ab-uga

wget https://data.humdata.org/dataset/6d6d1495-196b-49d0-86b9-dc9022cde8e7/resource/44ad260d-9313-47cb-92a7-72255242d017/download/uga_admbnda_ubos_20200824.gdb.zip

unzip uga_admbnda_ubos_20200824.gdb.zip

rm uga_admbnda_ubos_20200824.gdb.zip
