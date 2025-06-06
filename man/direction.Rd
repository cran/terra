\name{direction}

\alias{direction}
\alias{direction,SpatRaster-method}

\title{Direction}

\description{
The direction (azimuth) to or from the nearest cell that is not \code{NA}. The direction is expressed in radians, unless you use argument \code{degrees=TRUE}. 
}

\usage{
\S4method{direction}{SpatRaster}(x, from=FALSE, degrees=FALSE, method="cosine", filename="", ...) 
}

\arguments{
\item{x}{SpatRaster}
\item{from}{Logical. Default is \code{FALSE}. If \code{TRUE}, the direction from (instead of to)  the nearest cell that is not \code{NA} is returned}
\item{degrees}{Logical. If \code{FALSE} (the default) the unit of direction is radians.}
\item{method}{character. Should be "geo", or "cosine". With "geo" the most precise but slower geodesic method of Karney (2003) is used. The "cosine" method is faster but less precise}  
\item{filename}{Character. Output filename (optional)}
\item{...}{Additional arguments as for \code{\link{writeRaster}}}
}


\value{SpatRaster}


\seealso{
\code{\link[terra]{distance}}
}


\examples{
r <- rast(ncol=36,nrow=18, crs="+proj=merc")
values(r) <- NA
r[306] <- 1
b <- direction(r, degrees=TRUE) 
plot(b)

crs(r) <- "+proj=longlat"
b <- direction(r) 
plot(b)

}

\keyword{spatial}
