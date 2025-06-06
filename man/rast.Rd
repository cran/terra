\name{rast}

\docType{methods}

\alias{rast}
\alias{rast,missing-method}
\alias{rast,character-method}
\alias{rast,SpatRaster-method}
\alias{rast,SpatRasterDataset-method}
\alias{rast,data.frame-method}
\alias{rast,matrix-method}
\alias{rast,array-method}
\alias{rast,list-method}
\alias{rast,SpatExtent-method}
\alias{rast,SpatVector-method}
\alias{rast,ANY-method}
\alias{rast,PackedSpatRaster-method}
\alias{rast,stars-method}
\alias{rast,stars_proxy-method}

\title{Create a SpatRaster}

\description{
Methods to create a SpatRaster. These objects can be created from scratch, from a filename, or from another object.

A SpatRaster represents a spatially referenced surface divided into three dimensional cells (rows, columns, and layers). 

When a SpatRaster is created from one or more files, it does not load the cell (pixel) values into memory (RAM). It only reads the parameters that describe the geometry of the SpatRaster, such as the number of rows and columns and the coordinate reference system. The actual values will be read when needed.

Note that there are operating system level limitations to the number of files that can be opened simultaneously. Using a SpatRaster of very many files (e.g. 10,000) may cause R to crash when you use it in a computation. In situations like that you may need to split up the task or combine data into fewer (multi-layer) files. Also note that the GTiff format used for temporary files cannot store more than 65,535 layers in a single file.
}

\usage{
\S4method{rast}{character}(x, subds=0, lyrs=NULL, drivers=NULL, opts=NULL, win=NULL, 
		snap="near", vsi=FALSE, raw=FALSE, noflip=FALSE, 
		guessCRS=TRUE, domains="", md=FALSE, dims=NULL)

\S4method{rast}{missing}(x, nrows=180, ncols=360, nlyrs=1, xmin=-180, xmax=180, ymin=-90,
		ymax=90, crs, extent, resolution, vals, names, time, units)

\S4method{rast}{SpatRaster}(x, nlyrs=nlyr(x), names, vals, keeptime=TRUE, 
		keepunits=FALSE, props=FALSE, tags=FALSE) 

\S4method{rast}{matrix}(x, type="", crs="", digits=6, extent=NULL)

\S4method{rast}{data.frame}(x, type="xyz", crs="", digits=6, extent=NULL)

\S4method{rast}{array}(x, crs="", extent=NULL)

\S4method{rast}{list}(x, warn=TRUE)

\S4method{rast}{SpatRasterDataset}(x)

\S4method{rast}{SpatVector}(x, type="", ...)
									  
\S4method{rast}{SpatExtent}(x, ...)
}

\arguments{
\item{x}{filename (character), missing, SpatRaster, SpatRasterDataset, SpatExtent, SpatVector, matrix, array, list of SpatRasters. For other types it will be attempted to create a SpatRaster via (`as(x, "SpatRaster")`}
\item{subds}{positive integer or character to select a sub-dataset. If zero or "", all sub-datasets are returned (if possible)}
\item{lyrs}{positive integer or character to select a subset of layers (a.k.a. "bands"). If \code{x} has multiple filenames, the same layer numbers are selected from each of the files, unless numbers larger than the number of layers of the first data source are included}
\item{drivers}{character. GDAL drivers to consider}
\item{opts}{character. GDAL dataset open options}
\item{win}{SpatExtent to set a \code{\link{window}} (area of interest)}
\item{snap}{character. One of "near", "in", or "out", to indicate how the extent of \code{\link{window}} should be "snapped" to \code{x}}
\item{vsi}{logical. If \code{TRUE}, "\\vsicurl\\" is prepended to filenames that start with "http". There are many  \href{https://gdal.org/en/stable/user/virtual_file_systems.html}{VSI configuration options} that can be set with \code{\link{setGDALconfig}}}
\item{raw}{logical. If \code{TRUE}, scale and offset values are ignored. See \code{\link{scoff}} to get these parameters}
\item{noflip}{logical. If \code{TRUE}, a raster (e.g. JPEG image) that is not georeferenced and that GDAL assigns a flipped extent to (\code{ymax < ymin}), is not considered flipped. This avoids the need to \code{\link{flip}} the raster vertically}
\item{guessCRS}{logical. If \code{TRUE} and the the file does not specify a CRS but has an extent that is within longitude/latitude bounds, the longitude/latitude crs is assigned to the SpatRaster}
\item{domains}{character. Metadata domains to read (see \code{\link{metags}} to retrieve their values if there are any. "" is the default domain}
\item{md}{logical. If \code{TRUE}, the multi-dimensional GDAL interface is used under the hood for file reading. This interface can only be used for a few file formats (netCDF/HDF5) and can sometimes (not always) provide notably faster reading of data with many (time) steps in the third or higher dimension. Support for this is new and experimental (June 2025)}
\item{dims}{numeric. Specify the order of the dimensions to read atypical files. See \code{\link{ar_info}}. Only relevant if \code{md=TRUE}. Not used yet}
\item{nrows}{positive integer. Number of rows}
\item{ncols}{positive integer. Number of columns}
\item{nlyrs}{positive integer. Number of layers}
\item{xmin}{minimum x coordinate (left border)}
\item{xmax}{maximum x coordinate (right border)}
\item{ymin}{minimum y coordinate (bottom border)}
\item{ymax}{maximum y coordinate (top border)}
\item{crs}{character. Description of the Coordinate Reference System (map projection) in \code{PROJ.4}, \code{WKT} or \code{authority:code} notation. See \code{\link{crs}}. If this argument is missing, and the x coordinates are within -360 .. 360 and the y coordinates are within -90 .. 90, longitude/latitude is assigned}
\item{keeptime}{logical. If \code{FALSE} the time stamps are discarded}
\item{keepunits}{logical. If \code{FALSE} the layer units are discarded}
\item{props}{logical. If \code{TRUE} the properties (categories and color-table) are kept}
\item{tags}{logical. If \code{TRUE} the user specified metadata tags are kept (see \code{\link{metags}}).}
\item{extent}{object of class SpatExtent. If present, the arguments xmin, xmax, ymin and ymax are ignored}
\item{resolution}{numeric vector of length 1 or 2 to set the spatial resolution (see \code{\link{res}}). If this argument is used, arguments \code{ncols} and \code{nrows} are ignored }
\item{vals}{numeric. An optional vector with cell values (if fewer values are provided, these are recycled to reach the number of cells)}
\item{names}{character. An optional vector with layer names (must match the number of layers)}
\item{time}{time or date stamps for each layer}
\item{units}{character. units for each layer}
\item{type}{character. If the value is \code{"xyz"}, \code{x} must be a SpatVector with point geometry, or a matrix or data.frame with at least two columns, the first with \code{x} (or longitude) and the second with \code{y} (or latitude) coordinates that represent the centers of raster cells. The additional columns are the values associated with the raster cells. If the value is \code{"xylz"}, \code{x} must have four columns with the third representing the layer and the fourth the cell values. If the value is \code{""}, the resulting SpatRaster will have the same number of rows and columns as \code{x}. 
}
\item{digits}{integer to set the precision for detecting whether points are on a regular grid (a low number of digits is a low precision). Only used when \code{type="xyz"}}
\item{warn}{logical. If \code{TRUE}, a warnings about empty rasters may be emitted}
\item{...}{additional arguments passed on to the \code{rast,missing-method}}  
}


\value{
SpatRaster
}

\details{
Files are read with the GDAL library. GDAL guesses the file format from the name, and/or tries reading it with different "drivers" (see \code{\link{gdal}}) until it succeeds. In very few cases this may cause a file to be opened with the wrong driver, and some information may be lost. For example, when a netCDF file is opened with the HDF5 driver. You can avoid that by using argument \code{rast("filename.ncdf", drivers="NETCDF")}

These classes hold a C++ pointer to the data "reference class" and that creates some limitations. They cannot be recovered from a saved R session either or directly passed to nodes on a computer cluster. Generally, you should use \code{\link{writeRaster}} to save SpatRaster objects to disk (and pass a filename or cell values of cluster nodes). Also see \code{\link{wrap}}. 
}

\seealso{\code{\link{sds}} to create a SpatRasterDataset (SpatRasters with the same geometry representing different variables or higher dimension), \code{\link{sprc}} to create a SpatRasterCollection (to combine SpatRasters with different geometries), and \code{\link{vect}} for vector (points, lines, polygons) data}

\examples{
# Create a SpatRaster from scratch
x <- rast(nrows=108, ncols=21, xmin=0, xmax=10)

# Create a SpatRaster from a file
f <- system.file("ex/elev.tif", package="terra")
r <- rast(f)

# A file with multiple layers. This one is special as the layers are RGB color channels 
s <- rast(system.file("ex/logo.tif", package="terra"))

# remove the color channels
#plot(s)
#RGB(s) <- NULL
#plot(s)

# Create a skeleton with no associated cell values
rast(s)

# from a matrix 
m <- matrix(1:25, nrow=5, ncol=5)
rm <- rast(m)

# from a "xyz" data.frame
d <- as.data.frame(rm, xy=TRUE)
head(d)
rast(d, type="xyz")

}

\keyword{methods}
\keyword{spatial}

