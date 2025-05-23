# Author: Robert J. Hijmans
# Date :  June 2017
# Version 0.9
# License GPL v3


setMethod("dim", signature(x="SpatRaster"),
	function(x){ return(c(nrow(x), ncol(x), nlyr(x))) }
)

setMethod("dim", signature(x="SpatRasterDataset"),
	function(x) {
		c(x@pntr$nrow(), x@pntr$ncol())
	}
)

setMethod("dim", signature(x="SpatRasterCollection"),
	function(x) {
		m <- matrix(x@pntr$dims(), ncol=3)
		colnames(m) <- c("nrow", "ncol", "nlyr")
		m
	}
)

setMethod("nrow", signature(x="SpatRasterCollection"),
	function(x) {
		dim(x)[,1]
	}
)

setMethod("ncol", signature(x="SpatRasterCollection"),
	function(x) {
		dim(x)[,2]
	}
)

setMethod("nlyr", signature(x="SpatRasterCollection"),
	function(x) {
		dim(x)[,3]
	}
)


setMethod("nrow", signature(x="SpatRaster"),
	function(x){ return(x@pntr$nrow())}
)

setMethod("nrow", signature(x="SpatRasterDataset"),
	function(x){ return(x[1]@pntr$nrow())}
)

setMethod("nrow", signature(x="SpatVector"),
	function(x){ return(x@pntr$nrow())}
)

setMethod("ncol", signature(x="SpatRaster"),
	function(x){ return(x@pntr$ncol()) }
)

setMethod("ncol", signature(x="SpatRasterDataset"),
	function(x){ return(x[1]@pntr$ncol())}
)

setMethod("ncol", signature(x="SpatVector"),
	function(x){ return(x@pntr$ncol())}
)


setMethod("dim<-", signature(x="SpatRaster"),
	function(x, value) {

		if (length(value) == 1) {
			value <- c(value, ncol(x), nlyr(x))
		} else if (length(value) == 2) {
			value <- c(value, nlyr(x))
		} else if (length(value) > 3) {
			warn("dim<-", "value should have length 1, 2, or 3. Additional values ignored")
			value <- value[1:3]
		}
		value <- as.integer(pmax(round(value), c(1,1,1)))
		#here we lose all attributes
		rast(nrows=value[1], ncols=value[2], nlyrs=value[3], extent=ext(x), crs=crs(x))
	}
)



setMethod("ncell", signature(x="SpatRaster"),
	function(x) {
		return(as.numeric(ncol(x)) * nrow(x))
	}
)

setMethod("ncell", signature(x="SpatRasterDataset"),
	function(x) {
		ncell(x[1])
	}
)


setMethod("ncell", signature(x="ANY"),
	function(x) {
		NROW(x) * NCOL(x)
	}
)


setMethod("size", signature(x="SpatRaster"),
	function(x) {
		x@pntr$size()
	}
)


setMethod("nlyr", signature(x="SpatRaster"),
	function(x){
		return(x@pntr$nlyr() )
    }
)

setMethod("nlyr", signature(x="SpatRasterDataset"),
	function(x){
		return(x@pntr$nlyr() )
    }
)


setMethod("nsrc", signature(x="SpatRaster"),
	function(x){
		return(x@pntr$nsrc() )
    }
)

.nlyrBySource <- function(x) {
	x@pntr$nlyrBySource();
}


setMethod("ncol<-", signature("SpatRaster", "numeric"),
	function(x, value) {
		dim(x) <- c(nrow(x), value)
		return(x)
	}
)

setMethod("nrow<-", signature("SpatRaster", "numeric"),
	function(x, value) {
		dim(x) <- c(value, ncol(x))
		return(x)
	}
)

setMethod("nlyr<-", signature("SpatRaster", "numeric"),
	function(x, value) {
		dim(x) <- c(nrow(x), ncol(x), value)
		return(x)
	}
)


setMethod("res", signature(x="SpatRaster"),
function(x) {
		x@pntr$res
	}
)

setMethod("res", signature(x="SpatRasterDataset"),
function(x) {
		x@pntr$res()
	}
)

setMethod("res<-", signature(x="SpatRaster"),
	function(x, value) {
		if (length(value) == 1) {
			value <- c(value, value)
		} else if (length(value) > 2) {
			warn("res<-", "value should have length 1 or 2. Additional values ignored")
		}
		x@pntr <- x@pntr$set_resolution(value[1], value[2])
		messages(x, "resolution")
	}
)


setMethod("xres", signature(x="SpatRaster"),
function(x) {
		res(x)[1]
	}
)

setMethod("yres", signature(x="SpatRaster"),
function(x) {
		res(x)[2]
	}
)


setMethod("datatype", signature(x="SpatRaster"),
	function(x, bylyr=TRUE){
		d <- x@pntr$getDataType(FALSE, FALSE);
		if (bylyr) {
			d <- rep(d, sources(x, TRUE)$nlyr)
		}
		d
	}
)
