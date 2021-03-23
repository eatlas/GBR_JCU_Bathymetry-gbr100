# GBR_JCU_Bathymetry-gbr100
The gbr100 dataset is a Digital Elevation Model of the Great Barrier Reef and Coral Sea with a grid resolution of ~100m. The gbr100 dataset is updated every couple of years with new bathymetry readings making it more accurate. This repository contains the script used to prepare the gbr100 dataset for web delivery on the eAtlas. More metadata about this dataset can be found here: [Project 3DGBR: gbr100 High-resolution Bathymetry for the Great Barrier Reef and Coral Sea (JCU)](https://eatlas.org.au/data/uuid/200aba6b-6fb6-443e-b84b-86b0bbdb53ac).

This script takes the original Floating point geotiff available from https://www.deepreef.org/bathymetry/65-3dgbr-bathy.html and prepares it for web delivery. Using GDAL commands we add internal tiling, which speeds up rendering when only looking at a patch of the dataset, and pyrimidal overviews (progressively lower resolution versions of the dataset) that speed up rendering on zoomable maps. We also derive a hillshading layer from the dataset. This script downloads the original data and its metadata. It then extract this data and creates the derived products.

This script is restartable and so that if it gets interrupted it will skip sections that it has already completed. This approach was used because download and processing the gbr100 dataset can take 30 min.

## Setup requirements
This script needs to run in a Windows command prompt with gdal commands in the path. The set up needed for this script is to install [OSGeo4W](https://trac.osgeo.org/osgeo4w/),
ensuring that GDAL is installed as a module. This should be run from the C:\OSGeo4W64\OSGeo4W.bat commannd line window to ensure the paths are setup for the gdal commands.
Once the OSGeo4W command line window is running using cd {path to this script} before running the Processing.bat script.

