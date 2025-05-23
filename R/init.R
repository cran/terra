# Author: Robert J. Hijmans
# Date :  May 2019
# Version 1.0
# License GPL v3


setMethod("init", signature(x="SpatRaster"),
	function(x, fun, ..., filename="", overwrite=FALSE, wopt=list()) {
		x <- rast(x)
		if (is.character(fun)) {
			opt <- spatOptions(filename, overwrite=overwrite, wopt=wopt)
			x <- rast(x, 1)
			fun <- fun[1]
			if (fun %in% c("x", "y", "xy", "row", "col", "cell", "chess")) {
				x@pntr <- x@pntr$initf(fun, TRUE, opt)
				messages(x, "init")
			} else if (is.na(fun)) {
				x@pntr <- x@pntr$initv(as.numeric(NA), opt)
				messages(x, "init")
			} else {
				error("init", "unknown function")
			}
		} else if (is.numeric(fun) || is.logical(fun)) {
			if (is.matrix(fun) && (ncol(fun) == ncol(x))) {
				fun <- as.vector(t(fun))
			}
			opt <- spatOptions(filename, overwrite=overwrite, wopt=wopt)
			x@pntr <- x@pntr$initv(fun, opt)
			messages(x, "init")
		} else {
			nc <- ncol(x) * nlyr(x)
			b <- writeStart(x, filename, sources=sources(x), wopt=wopt)
			for (i in 1:b$n) {
				n <- b$nrows[i] * nc;
				r <- fun(n, ...)
				if (length(r) != n) {
					error("init","the number of values returned by 'fun' is not correct")
				}
				writeValues(x, r, b$row[i], b$nrows[i])
			}
			writeStop(x)
		}
	}
)

