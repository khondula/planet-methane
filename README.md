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
* NWI water class data (ponds and lakes) from within AOI, generated from **HU8_02060005_Wetlands.shp** filtered to ponds and lake, then cropped using AOI

#### Steps

#### Outputs

## 03-extract-vals

#### Inputs

* masked layer files from the folder **imgs_for_analysis**
* training polygons from **polygons/training_polygons_v2.shp**, trainclass column specifies water or upland
* topographic depressions from **polygons/mvdeps_buff20_inNLCD.shp**

#### Steps

`extract_allbands` function - 

* reads in image file, training polygons, and topographic depressions
* make data frame of all values with cell ids using `tabularaster::as_tibble`
* extract values with polygon IDs using `velox`

#### Outputs

* in **results/masked-allbands-extract_spIDs**
* in **results/masked-allbands-extract_cellids**

## 04-train-RF

#### Inputs

#### Steps

#### Outputs

## 05-daily-time-series

#### Inputs

#### Steps

#### Outputs

## 06-methane-model

#### Inputs

#### Steps

#### Outputs
