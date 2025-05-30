\name{metags}

\alias{metags}
\alias{metags,SpatRaster-method}
\alias{metags,SpatRasterDataset-method}
\alias{metags,SpatRasterCollection-method}
\alias{metags<-}
\alias{metags<-,SpatRaster-method}
\alias{metags<-,SpatRasterDataset-method}
\alias{metags<-,SpatRasterCollection-method}

  
\title{Set or get metadata}

\description{
You can set arbitrary metadata to (layers of) a SpatRaster using "name=value", or "domain:name=value" tags or a two (name, value) or three column (name, value, domain) matrix or data.frame. 
}

\usage{
\S4method{metags}{SpatRaster}(x, layer=NULL, domain="")<-value

\S4method{metags}{SpatRaster}(x, layer=NULL, name=NULL)

\S4method{metags}{SpatRasterDataset}(x, dataset=NULL)<-value

\S4method{metags}{SpatRasterDataset}(x, dataset=NULL, name=NULL)

}

\arguments{
\item{x}{SpatRaster}
\item{layer}{NULL, positive integer or character. If the value is NULL, the tags assigned or returned are for the SpatRaster. Otherwise for the layer number(s) or name(s)}
\item{domain}{character. Only used if not specified by \code{value}. Use "" for the default domain. Depending on the file format used this may the only domain supported when writing files}
\item{name}{character}
\item{value}{character of "name=value" or two-column (name, value) or three-column (name, value, domain) matrix or data.frame}
\item{dataset}{NULL, positive integer or character. If the value is NULL, the tags assigned or returned are for the SpatRasterDataset/SpatRasterCollection. Otherwise for the datset number(s) or name(s)}
}

\value{
SpatRaster (\code{metags<-}), or data.frame
}

\examples{
r <- rast(ncol=5, nrow=5)
m <- cbind(c("one", "two", "three"), c("ABC", "123", "hello"))
metags(r) <- m
metags(r)

metags(r) <- c("another_tag=another_value", "one more=this value")
metags(r)

metags(r) <- cbind("test", "this", "mydomain")
metags(r)

metags(r, name="two")

# remove a tag
metags(r) <- cbind("one", "")
metags(r) <- "two="
metags(r)

# remove all tags
metags(r) <- NULL
metags(r)
}

\keyword{spatial}

