# GBR_JCU_Bathymetry-gbr100
 The GBR100 dataset is updated every couple of years with new bathymetry readings making it more accurate. This repository contains the script used to prepare the GBR100 dataset for web delivery on the eAtlas. 

This script takes the original Floating point geotiff available from
https://www.deepreef.org/bathymetry/65-3dgbr-bathy.html and prepares
it for web delivery. Using GDAL commands we add internal tiling, 
which speeds up rendering when only looking at a patch of the dataset,
and pyrimidal overviews (progressively lower resolution versions of
the dataset) that speed up rendering on zoomable maps.
We also derive a hillshading layer from the dataset.
This script downloads the original data and its metadata. It then 
extract this data and creates the derived products.

## Setup requirements
This script needs to run in a Windows command prompt with gdal commands in the path.
The set up needed for this script is to install OSGeo4W. (https://trac.osgeo.org/osgeo4w/),
ensuring that GDAL is installed as a module.
This should be run from the C:\OSGeo4W64\OSGeo4W.bat commannd line window 
to ensure the paths are setup for the gdal commands.
Once the OSGeo4W command line window is running using cd {path to this script}
