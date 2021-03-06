\name{svc}

\docType{methods}

\alias{svc}
\alias{svc,missing-method}
\alias{svc,list-method}
\alias{svc,SpatVector-method}
\alias{[<-,SpatVectorCollection,numeric,missing-method}
\alias{[,SpatVectorCollection,numeric,missing-method}
\alias{[[,SpatVectorCollection,numeric,missing-method}



\title{Create a SpatVectorCollection}

\description{
Methods to create a SpatVectorCollection. This is an object to hold "sub-datasets", each a SpatVector, perhaps of different geometry type. 
}

\usage{
\S4method{svc}{missing}(x, ...) 

\S4method{svc}{SpatVector}(x, ...) 

\S4method{svc}{list}(x, ...) 
}

\arguments{
\item{x}{SpatVector, or list of SpatVector objects, or missing}
\item{...}{additional arguments. Can be other \code{SpatVector} objects if \code{x} is a \code{SpatVector}} 
}


\value{
SpatVectorCollection
}

\examples{
f <- system.file("ex/lux.shp", package="terra")
v <- vect(f)
x <- svc()
x <- svc(v, v[1:3,], as.lines(v[3:5,]), as.points(v))
length(x)
x

# extract
x[3]

# replace
x[2] <- as.lines(v[1,])


}


\keyword{methods}
\keyword{spatial}

