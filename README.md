---
title: "README"
output:
  html_document:
    toc: true
    toc_depth: 2
    keep_md: true
---

Processing PlanetScope Surface Reflectance data to develop a daily time series and then applying a methane model

## 01-process-images

#### Inputs

* downloaded analytic surface reflectance images in **data** folder (n = 325)
* downloaded unusable data masks in **metadata/download_udm** folder

#### Steps

* applies UDM to images with function `apply_udm_mask`, these intermediate files saved in **udm_masked_imgs**
* calculates new layers: NDVI, NDWI, Hue, Saturation, Value, Chroma, Lum, Hue2

*add in table with metrics, definition, function/package*

#### Outputs

* **imgs_for_analysis** (n = 299): 12 band rasters saved as geotifs with 20 digit IDs corresponding to first 20 digits of Planet ID. Excludes images with metadata issues (test quality, greater than 10% cloud cover, or visible clouds). 

## 02-prep-training

#### Inputs

* AOI shapefile from **polygons/AOI_union.shp**
* NLCD area with NWI and MVdeps masked, as raster from **ww_areas_maskNWImvdeps.tif**
* NWI polygons in **HU8_02060005_Wetlands.shp**

#### Steps

* filter NWI to wetland type ponds and lake, then cropped using AOI

#### Outputs

* upland training class
* water training class
* **results/nwi_inNLCD.csv** ?

## 03-extract-vals

#### Inputs

* masked layer files from the folder **imgs_for_analysis**
* training polygons from **polygons/training_polygons_v2.shp**, trainclass column specifies water or upland
* topographic depressions from **polygons/mvdeps_buff20_inNLCD.shp**

#### Steps

`extract_allbands` function

* reads in image file, training polygons, and topographic depressions
* make data frame of all values with cell ids using `tabularaster::as_tibble`
* extract values with polygon IDs using `velox`

`get_mvdeps_cellnos` function

* filters topographic depressions to a single polygon to use in query argument for `tabularatser::cellnumbers`, saves a separate csv file for each polygon in a folder for that image. 

#### Outputs

* in **results/masked-allbands-extract_spIDs**
* in **results/masked-allbands-extract_cellids**
* in **metadata/mvdeps_cellnos2/%imgID%/** - csv files for each depression with cellnumbers

## 04-train-RF

#### Inputs

* **results/masked-allbands-extract_spIDs**: training data for model, extracted in previous step
* **results/nwi_inNLCD.csv**
* **metadata/mvdeps_cellnos** - cell numbers for each polygon grouping

#### Steps

`run_rf_for_imgid`

* uses `img_id` argument to get appropriate file of training data, reads in using `data.table::fread`
* remove from training data: HUE, HUE2, VAL, upland5 (emergent herbaceous)
* filters training data to just polygons that are in NLCD categories of interest
* selects 2/3 of water data and an equal size selection of upland data, filters out any NAs
* parameter grid developed (mtry, splitrule, min.node.size)
* train using ranger with tuning grid, 1000 trees, save importance as permutation
* `if(predict_new_vals == TRUE)`, predictions for all mvdeps is done in this function (steps described below)

`predict_rf_for_img` - if there is a model to apply to image values

* mvdeps band data for given image ID read in from **masked-allbands-extract_cellids** folder using `data.table::fread`, and cell numbers from **metadata/mvdeps_cellnos** folder. In the cellnos file, ID_sp need to be left padded apparently. 
* These two files are joined into `img_extract_narm` and then used in `predict` with the RF model. 
* Predictions are added as a column to `img_extract_narm` and this data is saved in **results/rf_predicts_noEHW_pixels** folder.
* Then it is grouped by polygon and water/upland as `img_extract_predicts`, which is saved in **results/rf_predicts_noEHW**. 

#### Outputs

* **results/rf_meta/noEHW_v2** - not sure what this is
* **results/rf_model_files/noEHW_v2** - each model file (as %imgid%.rds) in this directory
* **results/rf_predicts_noEHW_pixels** - every cell predicted
* **results/rf_predicts_noEHW** - polygon level predictions for number of water and upland cells. 

## double-counting

*in progress*

* updates rf_predicts files with a column to filter out the predicted water cells that occur in more than one polygon. 
* cellindex and polygon IDs for the double counted cells to be filtered out are in **metadata/double_count_cells/%img_id%** with one file for each cell. 
* once all the cells for a given image are done, combine and then use to update rf predicts, save new files


## 05-daily-time-series

#### Inputs

* rf predictions in **results/rf_predicts_noEHW_v2**
* areas of topographic depressions in **metadata/mvdeps_buffered_area.csv**

#### Steps

* reads in rf predictions into one data frame

#### Outputs

## 06-methane-model

#### Inputs

#### Steps

#### Outputs
