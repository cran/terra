\name{c}

\docType{methods}

\alias{c}
\alias{c,SpatRaster-method}
\alias{c,SpatRasterDataset-method}
\alias{c,SpatVector-method}
\alias{c,SpatVectorCollection-method}

\title{Combine SpatRaster or SpatVector objects}

\description{
With \code{c} you can:

-- Combine \code{SpatRaster} objects. They must have the same extent and resolution. Also see \code{\link{add<-}}

-- Add a \code{SpatRaster} to a \code{SpatRasterDataset}

-- Append \code{SpatVector} objects. They must be of the same geometry type. See \code{\link{svc} for combining different geometry type objects in a SpatVectorCollection}

-- Add a \code{SpatVector} to a \code{SpatVectorCollection}
}

\seealso{\code{\link{collapse}}, \code{\link{add<-}}}


\usage{
\S4method{c}{SpatRaster}(x, ...)

\S4method{c}{SpatRasterDataset}(x, ...)

\S4method{c}{SpatVector}(x, ...)

\S4method{c}{SpatVectorCollection}(x, ...)
}

\arguments{
  \item{x}{SpatRaster, SpatVector, SpatRasterDataset or SpatVectorCollection}
  \item{...}{as for \code{x} (you can only combine raster with raster data and vector with vector data)}
}


\value{
Same class as \code{x}
}


\examples{
r <- rast(nrow=5, ncol=9)
values(r) <- 1:ncell(r)
x <- c(r, r*2, r*3)
}

\keyword{spatial}

