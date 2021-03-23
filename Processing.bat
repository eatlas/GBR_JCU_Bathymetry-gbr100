::  Copyright 2021 Eric Lawrey - Australian Institute of Marine Science
::
::  Licensed under the Apache License, Version 2.0 (the "License");
::  you may not use this file except in compliance with the License.
::  You may obtain a copy of the License at
::
::    http://www.apache.org/licenses/LICENSE-2.0
::
::  Unless required by applicable law or agreed to in writing, software
::  distributed under the License is distributed on an "AS IS" BASIS,
::  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
::  See the License for the specific language governing permissions and
::  limitations under the License.

:: This script takes the original Floating point geotiff available from
:: https://www.deepreef.org/bathymetry/65-3dgbr-bathy.html and prepares
:: it for web delivery. Using GDAL commands we add internal tiling, 
:: which speeds up rendering when only looking at a patch of the dataset,
:: and pyrimidal overviews (progressively lower resolution versions of
:: the dataset) that speed up rendering on zoomable maps.
:: We also derive a hillshading layer from the dataset.
:: This script downloads the original data and its metadata. It then 
:: extract this data and creates the derived products.

:: This script needs to run in a Windows command prompt with gdal commands in the path.
:: The set up needed for this script is to install OSGeo4W. (https://trac.osgeo.org/osgeo4w/),
:: ensuring that GDAL is installed as a module.
:: This should be run from the C:\OSGeo4W64\OSGeo4W.bat commannd line window 
:: to ensure the paths are setup for the gdal commands.
:: Once the OSGeo4W command line window is running using cd {path to this script}

:: This script assumes that the files are organised in the following structure.
:: 
:: |	processing.bat				(This script)
:: +--- derived						(Where the generated files will go)
:: +--- original
:: |	|	gbr100_v6_gtif.zip		(Original download of dataset)
:: |
:: \----tmp						(This is created at the start of the script and deleted at the end)
::		\---gbr100_v6_gtif
::			|	gbr100_10nov.tif	(Zip extract of original\gbr100_v6_gtif.zip)
:: This script assumes that the original zip file has already been unzipped into the
:: working folder.
::
:: This GeoTiff was then prepared for loading into the GeoServer with this script.
:: This added tiling and overviews to the raster.
@echo off
:: Path to downloaded zip file
set ORIG=original
set ORIG_ZIP=gbr100_v6_gtif.zip
set WORKING=temp
set OUT=public



:: ------------- Download the source files ---------------
if not exist %ORIG% mkdir %ORIG%

:: curl options:
::   -C -	Resume download. This prevents having to redownload each time the script run
::   -k		Skip worrying about valid certificates for the https connections. This was failing without this.
:: gbr100 Dataset
curl -C - -k https://ftt.jcu.edu.au/deepreef/3dgbr/gtif/gbr100_v6_gtif.zip --output %ORIG%/%ORIG_ZIP%

:: Metadata document
curl -C - -k https://www.deepreef.org/images/stories/bathymetry/3dgbr/Metadata_gbr100_V6_DEM.pdf --output %ORIG%/Metadata_gbr100_V6_DEM.pdf

:: Original report on gbr100 outlining methods
curl -C - -k https://www.deepreef.org/images/stories/publications/reports/Project3DGBRFinal_RRRC2010.pdf --output %ORIG%/Project3DGBRFinal_RRRC2010.pdf


:: ------------ Extract the original data -----------------
:: Setup directories if they don't already exist
if not exist %WORKING% mkdir %WORKING%

if not exist "%WORKING%\gbr100_v6_gtif\gbr100_10nov.tif" (
	:: Extract the zip file to the working directory. This should work on Win10 build 17063
	:: https://superuser.com/questions/1314420/how-to-unzip-a-file-using-the-cmd
	:: options -xvf Extract, verbose, file. -C change to directory before extraction
	echo "Extracting the original data from zip file"
	tar -xvf %ORIG%\%ORIG_ZIP% -C %WORKING%
) else ( 
	echo "Skipping unzipping as extract already exists"
)

:: ------------- Generate final products -------------------

if not exist %OUT% mkdir %OUT%


:: Name of the GeoTiff in the zip file
set ORIG_TIF=gbr100_10nov.tif

:: Name of the final GeoTiff and hillshading (without the extension)
set OUT_TIF=GBR_JCU_Bathymetry-gbr100_v6-2020


echo "Making web ready bathymetry"
if not exist %OUT%\%OUT_TIF%.tif (
	:: Add internal tiling to the imagery (arranging the data into 256x256 block). This 
	:: helps with extracting sections of the data, which speeds up rendering a small
	:: section of the data, such as when the user is zoomed into a section of the data.
	gdal_translate -co "COMPRESS=LZW" -co "TILED=YES" -a_nodata none ^
  %WORKING%\gbr100_v6_gtif\gbr100_10nov.tif %OUT%\%OUT_TIF%.tif
	:: Add progressively lower resolution overview images. This speeds up rendering
	:: when zoomed out.
	gdaladdo -r average %OUT%\%OUT_TIF%.tif 2 4 8 16 32 64 128
) else (
	echo "Skipping generation of output as it already exists"
)

if not exist %OUT%\%OUT_TIF%_hillshade.tif (
	echo "Making lossless hillshading"
	gdaldem hillshade -z 0.0001 -compute_edges -of GTiff -co "COMPRESS=LZW" -co "TILED=YES" %OUT%\%OUT_TIF%.tif %OUT%\%OUT_TIF%_hillshade.tif
) else (
	echo "Skipping hillshading as it already exists"
)

if not exist %OUT%\%OUT_TIF%_hillshade-jpeg.tif (
	echo "Make JPEG hillshading"
	gdal_translate -co "COMPRESS=JPEG" -co "JPEG_QUALITY=95" -co "TILED=YES" -a_nodata none %OUT%\%OUT_TIF%_hillshade.tif %OUT%\%OUT_TIF%_hillshade-jpeg.tif
	gdaladdo -r average %OUT%\%OUT_TIF%_hillshade-jpeg.tif 2 4 8 16 32 64 128
) else (
	echo "Skipping jpeg hillshading as it already exists"
)

:: ------------- Clean up the temp directory ---------------
:: Deleted the extract from the original data to save on space
echo "Deleting temp directory"
rmdir /S %WORKING%