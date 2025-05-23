# Author: Robert J. Hijmans
# Date : June 2019
# Version 1.0
# License GPL v3

setMethod("merge", signature(x="SpatVector", y="data.frame"),
	function(x, y, ...) {
		v <- values(x)
		v$unique_nique_ique_que_e <- 1:nrow(v)
		m <- merge(v, y, ...)
		m <- m[order(m$unique_nique_ique_que_e), ]
		x <- x[stats::na.omit(m$unique_nique_ique_que_e), ]
		m$unique_nique_ique_que_e <- NULL
		if (nrow(m) > nrow(x)) {
			error("merge", "using 'all.y=TRUE' is not allowed. Should it be?")
		}
		values(x) <- m
		x
	}
)

setMethod("merge", signature(x="SpatVector", y="SpatVector"),
	function(x, y, ...) {
		merge(x, data.frame(y), ...)
	}
)


setMethod("merge", signature(x="SpatRasterCollection", "missing"),
	function(x, first=TRUE, na.rm=TRUE, algo=1, method=NULL, filename="", ...) {
		opt <- spatOptions(filename, ...)
		out <- rast()
		if (is.null(method)) method = ""
		out@pntr <- x@pntr$merge(first[1], na.rm, algo, method, opt)
		if (algo == 3) {
			messages(opt, "merge")
		}
		messages(x, "merge")
		messages(out, "merge")
	}
)

setMethod("merge", signature(x="SpatRaster", y="SpatRaster"),
	function(x, y, ..., first=TRUE, na.rm=TRUE, algo=1, method=NULL, filename="", overwrite=FALSE, wopt=list()) {
		rc <- sprc(x, y, ...)
		merge(rc, first=first, na.rm=na.rm, algo=algo, method=method, filename=filename, overwrite=overwrite, wopt=wopt)
	}
)



setMethod("mosaic", signature(x="SpatRaster", y="SpatRaster"),
	function(x, y, ..., fun="mean", filename="", overwrite=FALSE, wopt=list()) {
		fun <- .makeTextFun(fun)
		if (!inherits(fun, "character")) {
			error("mosaic", "function 'fun' is not valid")
		}
		opt <- spatOptions(filename, overwrite, wopt=wopt)
		rc <- sprc(x, y, ...)
		x@pntr <- rc@pntr$mosaic(fun, opt)
		messages(x, "mosaic")
	}
)

setMethod("mosaic", signature(x="SpatRasterCollection", "missing"),
	function(x, fun="mean", filename="", ...) {
		opt <- spatOptions(filename, ...)
		out <- rast()
		fun <- .makeTextFun(fun)
		if (!inherits(fun, "character")) {
			error("mosaic", "function 'fun' is not valid")
		}
		out@pntr <- x@pntr$mosaic(fun, opt)
		messages(out, "mosaic")
	}
)

