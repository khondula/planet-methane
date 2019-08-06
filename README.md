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

* downloaded analytic surface reflectance images in **data** folder (n = 320)
* downloaded unusable data masks in **metadata/download_udm** folder

#### Steps

* applies UDM to images with function `apply_udm_mask`, saved in * **udm_masked_imgs**
* calculates new layers: NDVI, NDWI, Hue, Saturation, Value, Chroma, Lum, Hue2

*table with metrics, definition, function/package*

#### Outputs

* **imgs_for_analysis** (n = 285) - 12 band rasters saved as geotifs with 20 digit IDs corresponding to first 20 digits of Planet ID. Excludes images with metadata issues (test quality, greater than 10% cloud cover, or visible clouds). 

## 02-prep-training

#### Inputs

#### Steps

#### Outputs

## 03-extract-vals

#### Inputs

#### Steps

#### Outputs

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
