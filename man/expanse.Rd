\name{expanse}

\alias{area}
\alias{area,SpatRaster-method}
\alias{area,SpatVector-method}

\alias{expanse}
\alias{expanse,SpatRaster-method}
\alias{expanse,SpatVector-method}

  
\title{Get the expanse (area) of individual polygons or for all (summed) raster cells}

\description{
Compute the area covered by polygons or for all raster cells that are not \code{NA}. 

This method computes areas for longitude/latitude rasters, as the size of the cells is constant in degrees, but not in square meters. But it can also be important if the coordinate reference system is planar, but not equal-area. 

For vector data, the best way to compute area is to use the longitude/latitude CRS. This is contrary to (erroneous, but popular) belief that you should use a planar coordinate reference system. Where applicable, the transformation to lon/lat is done automatically, if \code{transform=TRUE}.

Note that it is important that polygon geometries are valid. If they are not valid, the computed area may be wrong. You can check for validity with \code{\link{is.valid}} and fix some problems with \code{\link{makeValid}}
}

\usage{
\S4method{expanse}{SpatRaster}(x, unit="m", transform=TRUE, byValue=FALSE,
			zones=NULL, wide=FALSE, usenames=FALSE)

\S4method{expanse}{SpatVector}(x, unit="m", transform=TRUE)
}

\arguments{
  \item{x}{SpatRaster or SpatVector}
  \item{unit}{character. Output unit of area. One of "m", "km", or "ha"}
  \item{transform}{logical. If \code{TRUE}, planar CRS are transformed to lon/lat for accuracy}
  \item{byValue}{logical. If \code{TRUE}, the area for each unique cell value is returned}
  \item{zones}{NULL or SpatRaster with the same geometry identifying zones in \code{x}}
  \item{wide}{logical. Should the results be in "wide" rather than "long" format?}
  \item{usenames}{logical. If \code{TRUE} layers are identified by their names instead of their numbers}
}  

\value{
\bold{SpatRaster}: \code{data.frame} with at least two columns ("layer" and "area") and possibly also "value" (if \code{byValue} is \code{TRUE}), and "zone" (if \code{zones} is \code{TRUE}). If \code{x} has no values, the total area of all cells is returned. Otherwise, the area of all cells that are not \code{NA} is returned. 

\bold{SpatVector}: numeric (one value for each (multi-) polygon geometry.
}

\seealso{
\code{\link{cellSize}} for a the size of individual cells of a raster, that can be summed with \code{\link{global}} or with \code{\link{zonal}} to get the area for different zones; \code{\link{surfArea}} for a raster with elevation values, taking into account the sloping nature of the surface.
}

\examples{

### SpatRaster 
r <- rast(nrows=18, ncols=36)
v <- 1:ncell(r)
v[200:400] <- NA
values(r) <- v

# summed area in km2
expanse(r, unit="km")

# all cells 
expanse(rast(r), unit="km")

r <- rast(ncols=90, nrows=45, ymin=-80, ymax=80)
m <- project(r, "+proj=merc")

expanse(m, unit="km")
expanse(m, unit="km", transform=FALSE)

m2 <- c(m, m)
values(m2) <- cbind(c(1,2,NA,NA), c(11:14))
expanse(m2, unit="km", byValue=TRUE, wide=TRUE)


v <- vect(system.file("ex/lux.shp", package="terra"))
r <- rast(system.file("ex/elev.tif", package="terra"))
r <- round((r-50)/100)
levels(r) <- data.frame(id=1:5, name=c("forest", "water", "urban", "crops", "grass"))
expanse(r, byValue=TRUE)

g <- rasterize(v, r, "NAME_1")
expanse(r, byValue=TRUE, zones=g, wide=TRUE)


### SpatVector
v <- vect(system.file("ex/lux.shp", package="terra"))

a <- expanse(v)
a
sum(a)
}

\keyword{methods}
\keyword{spatial}
