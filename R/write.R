
setMethod("writeStart", signature(x="SpatRaster", filename="character"), 
	function(x, filename="", overwrite=FALSE, ...) {
		opt <- spatOptions(filename, overwrite, ...)
		ok <- x@ptr$writeStart(opt)
		messages(x, "writeStart")
		b <- x@ptr$getBlockSize(4, opt$memfrac)
		b$row <- b$row + 1
		b
	}
)


setMethod("writeStop", signature(x="SpatRaster"), 
	function(x) {
		success <- x@ptr$writeStop()
		messages(x, "writeStop")
		f <- sources(x)$source
		if (f != "") {
			x <- rast(f)
		}
		return(x)
	} 
)

setMethod("writeValues", signature(x="SpatRaster", v="vector"), 
	function(x, v, start, nrows) {
		#wstart <- start[1]-1
		#nrows <- start[2]
		#if (is.na(nrows)) {
		#	nrows <- length(v) / (ncol(x) * nlyr(x))
		#}
		success <- x@ptr$writeValues(v, start-1, nrows, 0, ncol(x))
		messages(x, "writeValues")
		invisible(success)
	}
)


setMethod("writeRaster", signature(x="SpatRaster", filename="character"), 
function(x, filename="", overwrite=FALSE, ...) {
	filename <- trimws(filename)
	stopifnot(filename != "")
	if (tools::file_ext(filename) %in% c("nc", "cdf") || isTRUE(list(...)$filetype=="netCDF")) {
		warn("consider writeCDF to write ncdf files")
	}
	opt <- spatOptions(filename, overwrite, ...)
	x@ptr <- x@ptr$writeRaster(opt)
	x <- messages(x, "writeRaster")
	invisible(rast(filename))
}
)


setMethod("writeVector", signature(x="SpatVector", filename="character"), 
function(x, filename, overwrite=FALSE, ...) {
	filename <- trimws(filename)
	if (filename == "") {
		error("writeVector", "provide a filename")
	}
	lyrname <- gsub(".shp", "", basename(filename))
	success <- x@ptr$write(filename, lyrname, "ESRI Shapefile", overwrite[1])
	messages(x, "writeVector")
	invisible(TRUE)
}
)

