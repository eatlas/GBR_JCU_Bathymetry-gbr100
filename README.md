# GBR_JCU_Bathymetry-gbr100
The gbr100 dataset is a Digital Elevation Model of the Great Barrier Reef and Coral Sea with a grid resolution of ~100m. The gbr100 dataset is updated every couple of years with new bathymetry readings making it more accurate. This repository contains the script used to prepare the gbr100 dataset for web delivery on the eAtlas. More metadata about this dataset can be found here: [Project 3DGBR: gbr100 High-resolution Bathymetry for the Great Barrier Reef and Coral Sea (JCU)](https://eatlas.org.au/data/uuid/200aba6b-6fb6-443e-b84b-86b0bbdb53ac).

This script takes the original Floating point geotiff available from https://www.deepreef.org/bathymetry/65-3dgbr-bathy.html and prepares it for web delivery. Using GDAL commands we add internal tiling, which speeds up rendering when only looking at a patch of the dataset, and pyrimidal overviews (progressively lower resolution versions of the dataset) that speed up rendering on zoomable maps. We also derive a hillshading layer from the dataset. This script downloads the original data and its metadata. It then extract this data and creates the derived products.

This script is restartable and so that if it gets interrupted it will skip sections that it has already completed. This approach was used because download and processing the gbr100 dataset can take 30 min.

## Step 1 - Setup requirements
This script needs to run in a Windows command prompt with gdal commands in the path. The set up needed for this script is to install [OSGeo4W](https://trac.osgeo.org/osgeo4w/),
ensuring that GDAL is installed as a module. This should be run from the C:\OSGeo4W64\OSGeo4W.bat commannd line window to ensure the paths are setup for the gdal commands.
Once the OSGeo4W command line window is running using cd {path to this script} before running the Processing.bat script.

## Step 2 - Run Processing.bat
This script will download the gbr100 dataset from the JCU website, along with metadata reports. The current script is written to download version 6 of the dataset. To update to a new version modify the URL download paths in Processing.bat. The script then unzips the downloads and converts the data to a GeoTiff that is optimised for performance (internal tiling and overviews), using GDAL commandline tools. This script also generates a hillshading version of the dataset. The generated final products are saved in the 'public' folder.

## Step 3 - Publishing on eAtlas
These steps outline the basic process of publishing the gbr100 on the eAtlas. 
1. Both `GBR_JCU_Bathymetry-gbr100_v6-2020.tif` and `GBR_JCU_Bathymetry-gbr100_v6-2020_hillshade-jpeg.tif` should be setup as map layers in the eAtlas GeoServer. They should be copied to the `eAtlas GeoServer/data/ongoing/GBR_JCU_Bathymetry-gbr100` folder using Pydio, then setup as spatial layers in GeoServer, following the same style setting as previous versions of this dataset. 
2. The files should also be setup as shared data downloads in `File for download (eAtlas)/ongoing/GBR_JCU_Bathymetry-gbr100` workspace.
3. The [eAtlas gbr100 metadata record](eatlas.org.au/data/uuid/200aba6b-6fb6-443e-b84b-86b0bbdb53ac) should be updated to a new interactive map and to the new data downloads.


