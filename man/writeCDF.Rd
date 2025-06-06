\name{writeCDF}

\alias{writeCDF}
\alias{writeCDF,SpatRasterDataset-method}
\alias{writeCDF,SpatRaster-method}

\title{Write raster data to a NetCDF file}

\description{
Write a SpatRaster or SpatRasterDataset to a NetCDF file. 

When using a SpatRasterDataset, the varname, longname, and unit should be set in the object (see examples).

Always use the \code{".nc"} or \code{".cdf"} file extension to assure that the file can be properly read again by GDAL

You can write multiple rasters (variables) that are two (x, y), three (x, y, z or x, y, time) or four dimensional (x, y, z, time).

See \code{\link{depth}} and \code{\link{time}} for specifying the axes of the thrid and/or fourth dimension(s).
}

\usage{
\S4method{writeCDF}{SpatRaster}(x, filename, varname, longname="", unit="", split=FALSE, ...)

\S4method{writeCDF}{SpatRasterDataset}(x, filename, overwrite=FALSE, timename="time", atts="", 
    gridmap="", prec="float", compression=NA, missval, tags=FALSE, ...)
}

\arguments{
  \item{x}{SpatRaster or SpatRasterDataset}
  \item{filename}{character. Output filename}
  \item{varname}{character. Name of the dataset}
  \item{longname}{character. Long name of the dataset}
  \item{unit}{character. Unit of the data}
  \item{split}{logical. If \code{TRUE} each layer of \code{x} is treated as a sub-dataset}
  \item{atts}{character. A vector of additional global attributes to write. The must be formatted like c("x=a value", "y=abc")}
  \item{gridmap}{character. The crs is always written to the file in standard formats. With this argument you can also write the format commonly used in netcdf files. Something like \code{c("grid_mapping_name=lambert_azimuthal_equal_area", "longitude_of_projection_origin=10", "latitude_of_projection_origin=52", "false_easting=4321000", "false_northing=3210000")}}
  \item{overwrite}{logical. If \code{TRUE}, \code{filename} is overwritten}
  \item{timename}{character. The name of the "time" dimension}
  \item{prec}{character. One of "double", "float", "integer", "short", "byte" or "char"}
  \item{compression}{Can be set to an integer between 1 (least compression) and 9 (most compression)}
  \item{missval}{numeric, the number used to indicate missing values}
  \item{tags}{logical. If \code{TRUE} the value returned by \code{\link{metags}} are written to the file as attributes}
  \item{...}{additional arguments passed on to the SpatRasterDataset method, and from there possibly to \code{\link[ncdf4]{ncvar_def}}}
}

\value{
SpatRaster or SpatDataSet
}

\seealso{
see \code{\link{writeRaster}} for writing other file formats
}

\examples{

f <- system.file("ex/elev.tif", package="terra")
r <- rast(f)
fname <- paste0(tempfile(), ".nc")
rr <- writeCDF(r, fname, overwrite=TRUE, varname="alt", 
      longname="elevation in m above sea level", unit="m")

a <- rast(ncols=5, nrows=5, nl=50)
values(a) <- 1:prod(dim(a))
time(a) <- as.Date("2020-12-31") + 1:nlyr(a)
aa <- writeCDF(a, fname, overwrite=TRUE, varname="power", 
      longname="my nice data", unit="U/Pa")

b <- sqrt(a)
s <- sds(a, b)
names(s) <- c("temp", "prec")
longnames(s) <- c("temperature (C)", "precipitation (mm)")
units(s) <- c("°C", "mm")
ss <- writeCDF(s, fname, overwrite=TRUE)

# four dimensional 
r1 <- rast(nrow=5, ncol=5, vals=1:100, nlyr=4)
depth(r1) <- c(0, 2, 0, 2)
time(r1) <- c(as.Date("2012-12-12") + c(1,1,2,2))
depthName(r1) <- "angle"

r2 <- rast(nrow=5, ncol=5, vals=1:150, nlyr=6)
depth(r2) <- c(10, 10, 20, 20, 30, 30)
time(r2) <- c(as.Date("2012-12-12") + c(1:2, 1:2, 1:2))
depthName(r2) <- "height"
depthUnit(r2) <- "cm"

s <- sds(r1, r2)
names(s) <- c("TH", "DBZH")
units(s) <- c("-", "Pa")
x <- writeCDF(s, filename = fname, overwrite=TRUE)
x[1]
time(x[1])
depth(x[1])

x[2]
time(x[2])
depth(x[2])

# for CRAN
file.remove(fname)
}

\keyword{ spatial }
\keyword{ methods }

