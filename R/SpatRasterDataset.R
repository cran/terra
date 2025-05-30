
setMethod("length", signature(x="SpatRasterDataset"),
	function(x) {
		x@pntr$nsds()
	}
)


setMethod("sds", signature(x="character"),
	function(x, ids=0, opts=NULL, raw=FALSE, noflip=FALSE, guessCRS=TRUE, domains="") {

		if (length(x) > 1) {
			r <- lapply(x, rast, opts=opts, raw=raw)
			s <- sds(r)
			names(s) <- tools::file_path_sans_ext(basename(x))
			return(s)
		}

		x <- trimws(x[1])
		if (nchar(x) == 0) {
			error("sds", "provide valid file name(s)")
		}
		f <- .fullFilename(x)
		r <- methods::new("SpatRasterDataset")
		ids <- round(ids)-1
		if (ids[1] < 0) {
			useids <- FALSE
		} else {
			useids <- TRUE
		}
		if (is.null(opts)) opts <- ""[0]
		if (raw) opts <- c(opts, "so=false")
		
		domains <- clean_domains(domains)		
		r@pntr <- SpatRasterStack$new(f, ids, useids, opts, isTRUE(noflip), isTRUE(guessCRS), domains)
		messages(r, "sds")
	}
)

setMethod("sds", signature(x="missing"),
	function(x) {
		r <- methods::new("SpatRasterDataset")
		r@pntr <- SpatRasterStack$new()
		r
	}
)


setMethod("sds", signature(x="SpatRaster"),
	function(x, ...) {
		r <- methods::new("SpatRasterDataset")
		r@pntr <- SpatRasterStack$new()
		r@pntr$add(x@pntr, varnames(x)[1], longnames(x)[1], units(x)[1], FALSE)
		dots <- list(...)
		nms <- names(dots)
		if (is.null(nms)) nms = ""
		nms <- rep_len(nms, length(dots))
		for (i in seq_along(dots)) {
			if (inherits(dots[[i]], "SpatRaster")) {
				vname <- nms[i]
				if (vname == "") vname = varnames(dots[[i]])[1]
				r@pntr$add(dots[[i]]@pntr, vname, longnames(dots[[i]])[1], units(dots[[i]])[1], FALSE)
			}
		}
		messages(r, "sds")
	}
)

setMethod("sds", signature(x="list"),
	function(x) {
		r <- methods::new("SpatRasterDataset")
		r@pntr <- SpatRasterStack$new()
		nms <- names(x)
		if (is.null(nms)) nms <- rep("", length(x))
		for (i in seq_along(x)) {
			if (inherits(x[[i]], "SpatRaster")) {
				r@pntr$add(x[[i]]@pntr, nms[i], "", "", FALSE)
			} else if (inherits(x[[i]], "SpatRasterDataset")) {
				y <- as.list(x[[i]])
				ynms <- names(x[[i]])
				s <- sapply(y, function(j) r@pntr$add(j@pntr, ynms[j], "", "", FALSE))
			} else {
				name <- names(x[[i]])
				cls <- paste(class(x[[i]]), collapse=", ")
				error("sds", "list element", name, "is a: ", cls)
			}
		}
		messages(r, "sds")
	}
)


setMethod("sds", signature(x="array"),
	function(x, crs="", extent=NULL) {
		dims <- dim(x)
		if (length(dims) <= 3) {
			return(sds(rast(x, crs=crs, extent=extent)))
		}
		if (length(dims) > 4) {
			if (length(dims) == 5) {
				if (dims[5] == 1) {
					x <- x[,,,,1]
				} else {
					error("sds,array", "cannot handle an array with 5 dimensions")
				}
			} else {
				error("sds,array", "cannot handle an array with more than 4 dimensions")
			}
		}
		r <- lapply(1:dims[4], function(i) rast(x[,,,i], crs=crs, extent=extent))
		sds(r)
	}
)



setMethod("sds", signature(x="stars"),
	function(x) {
		s <- from_stars(x)
		if (inherits(s, "SpatRaster")) {
			sds(s)
		} else {
			s
		}
	}
)

setMethod("sds", signature(x="stars_proxy"),
	function(x) {
		s <- from_stars(x)
		if (inherits(s, "SpatRaster")) {
			sds(s)
		} else {
			s
		}
	}
)



setMethod("c", signature(x="SpatRasterDataset"),
	function(x, ...) {

		x@pntr <- x@pntr$subset((1:x@pntr$nsds()) -1 ) # why? make a copy?

		dots <- list(...)
		nms <- names(dots)

		for (i in seq_along(dots)) {
			if (inherits(dots[[i]], "SpatRasterDataset")) {
				sdsnms <- names(dots[[i]])
				for (j in 1:(length(dots[[i]]))) {
					if (!x@pntr$add(dots[[i]][[j]]@pntr, sdsnms[j], "", "", FALSE)) {
						messages(x, "c")
					}
				}

			} else if (inherits(dots[[i]], "SpatRaster")) {
				if (is.null(nms)) error("c", "arguments must be named")
				if (!x@pntr$add(dots[[i]]@pntr, nms[i], "", "", FALSE)) {
					messages(x, "c")
				}
			} else {
				error("c", "arguments must be SpatRaster or SpatRasterDataset")
			}
		}
		messages(x, "c")
	}
)


setReplaceMethod("[", c("SpatRasterDataset", "numeric", "missing"),
	function(x, i, j, value) {
		if (any(!is.finite(i)) | any(i<1)) {
			error("`[`", "invalid index")
		}
		stopifnot(inherits(value, "SpatRaster"))
		i <- sort(i)
		for (j in i) {
			if (j == (length(x)+1)) {
				x@pntr$add(value@pntr, "", "", "", FALSE)
			} else {
				x@pntr$replace(j-1, value@pntr, FALSE)
			}
		}
		messages(x, "`[`")
	}
)


setMethod("[", c("SpatRasterDataset", "numeric", "missing"),
function(x, i, j, drop=TRUE) {
	i <- positive_indices(i, length(x), TRUE, "`[`(i)")

	if (drop && (length(i) == 1)) {
		tptr <- x@pntr$getsds(i-1)
		x <- rast()
		x@pntr <- tptr
	} else {
		x@pntr <- x@pntr$subset(i-1)
	}
	messages(x, "`[`")
})

setMethod("[", c("SpatRasterDataset", "numeric", "numeric"),
function(x, i, j, drop=TRUE) {
	i <- positive_indices(i, length(x))
	j <- positive_indices(j, min(nlyr(x)))	
	nd <- i
	if (drop) {
		out <- lapply(nd, function(k) x[k][[j]])
		out <- rast(out)
	} else {
		out <- sds()
		nms <- x@pntr$names
		for (k in nd) {
			r <- x[k][[j]]
			out@pntr$add(r@pntr, nms[k], "", "", FALSE)
		}
	}
	messages(out, "`[`")
})

setMethod("[", c("SpatRasterDataset", "numeric", "logical"),
function(x, i, j, drop=TRUE) {
	j <- positive_indices(j, min(nlyr(x)))
	`[`(x, i=i, j=j, drop=drop)
})

setMethod("[", c("SpatRasterDataset", "missing", "numeric"),
function(x, i, j, drop=TRUE) {
	`[`(x, i=1:x@pntr$nsds(), j=j, drop=drop)
})

setMethod("[", c("SpatRasterDataset", "missing", "logical"),
function(x, i, j, drop=TRUE) {
	j <- positive_indices(j, min(nlyr(x)))
	`[`(x, i=1:x@pntr$nsds(), j=j, drop=drop)
})


setMethod("[", c("SpatRasterDataset", "logical", "missing"),
function(x, i, j,drop=TRUE) {
	i <- positive_indices(j, length(x))
	x[i, drop=drop]
})

setMethod("[", c("SpatRasterDataset", "character", "missing"),
function(x, i, j, drop=TRUE) {
	i <- match(i, names(x))
	if (any(is.na(i))) {
		error("`[`", "unknown name(s) provided")
	}
	x[i, drop=drop]
})

setMethod("[[", c("SpatRasterDataset", "ANY", "ANY"),
function(x, i, j, drop=TRUE) {
	mi <- missing(i)
	mj <- missing(j)

	if ((mi) && (mj)) {
		`[`(x, drop=drop)
	} else if (mi) {
		`[`(x, j=j, drop=drop)
	} else if (mj) {
		`[`(x, i=i, drop=drop)
	} else {
		`[`(x, i=i, j=j, drop=drop)
	}
})


setMethod("$", c("SpatRasterDataset"),
function(x, name) {
	x[name,drop=TRUE]
})


setMethod("$", "SpatRasterDataset",
	function(x, name) {
		x[name]
	}
)


setMethod("sprc", signature(x="missing"),
	function(x) {
		r <- methods::new("SpatRasterCollection")
		r@pntr <- SpatRasterCollection$new()
		r
	}
)


setMethod("sprc", signature(x="SpatRaster"),
	function(x, ...) {
		sprc(list(x, ...))
	}
)


setMethod("sprc", signature(x="list"),
	function(x) {
		n <- length(x)
		tptr <- SpatRasterCollection$new()
		if (n > 0) {
			for (i in 1:n) {
				if (inherits(x[[i]], "SpatRaster")) {
					tptr$add(x[[i]]@pntr, "")
				} else if (inherits(x[[i]], "SpatRasterCollection") | 
							inherits(x[[i]], "SpatRasterDataset")) {
					y <- as.list(x[[i]])
					s <- sapply(y, function(j) tptr$add(j@pntr, ""))
				} else {
					name <- names(x[[i]])
					cls <- paste(class(x[[i]]), collapse=", ")
					error("sprc", "list element", name, "is a: ", cls)
				}
			}
		}
		r <- new("SpatRasterCollection")
		r@pntr <- tptr
		if (length(r) == length(x)) names(r) <- names(x)
		r
	}
)

setMethod("sprc", signature(x="character"),
	function(x, ids=0, opts=NULL, raw=FALSE, noflip=FALSE, guessCRS=TRUE, domains="") {

		if (length(x) > 1) {
			r <- lapply(x, rast)
			s <- sprc(r)
			names(s) <- tools::file_path_sans_ext(basename(x))
			return(s)
		}

		x <- trimws(x[1])
		if (nchar(x) == 0) {
			error("sprc", "provide valid file name(s)")
		}
		f <- .fullFilename(x)
		r <- methods::new("SpatRasterCollection")
		ids <- round(ids)-1
		if (ids[1] < 0) {
			useids <- FALSE
		} else {
			useids <- TRUE
		}
		if (is.null(opts)) opts <- ""[0]
		if (raw) opts <- c(opts, "so=false")		
		
		domains <- clean_domains(domains)
		r@pntr <- SpatRasterCollection$new(f, ids, useids, opts, isTRUE(noflip), isTRUE(guessCRS), domains)
		messages(r, "sprc")
	}
)


setMethod("length", signature(x="SpatRasterCollection"),
	function(x) {
		x@pntr$length()
	}
)

setMethod("[", c("SpatRasterCollection", "numeric", "missing"),
function(x, i, j, ... ,drop=TRUE) {
	i <- positive_indices(i, length(x), TRUE, "`[`(i)")
	if (drop && (length(i) == 1)) {
		tptr <- x@pntr$x[[i]]
		x <- rast()
		x@pntr <- tptr
	} else {
		s <- x@pntr$x[i]
		tptr <- SpatRasterCollection$new()
		for (i in 1:length(s)) {
			tptr$add(s[[i]], "")
		}
		x@pntr <- tptr
	}
	messages(x, "`[`")
})


setMethod("add<-", signature("SpatRasterCollection", "SpatRaster"),
	function(x, value) {
		x@pntr$add(value@pntr, "")
		messages(x, "add")
	}
)


setMethod("add<-", signature("SpatRasterDataset", "SpatRaster"),
	function(x, value) {
		x@pntr$add(value@pntr, "")
		messages(x, "add")
	}
)


setMethod("c", signature(x="SpatRasterCollection"),
	function(x, ..., warn=TRUE) {
		y <- list(...)
		sprc(c(as.list(x), ...))
	}
)


setMethod("c", signature(x="SpatRasterCollection"),
	function(x, ...) {

		x@pntr <- x@pntr$deepcopy()

		dots <- list(...)
		nms <- names(dots)
		for (i in seq_along(dots)) {
			if (inherits(dots[[i]], "SpatRasterCollection") | inherits(dots[[i]], "SpatRasterDataset")) {
				sdsnms <- names(dots[[i]])
				for (j in 1:(length(dots[[i]]))) {
					x@pntr$add(dots[[i]][[j]]@pntr, sdsnms[j])
				}
			} else if (inherits(dots[[i]], "SpatRaster")) {
				if (is.null(nms)) { 
					name <- paste0("d", i)
				} else { 
					name <- nms[i] 
				}
				x@pntr$add(dots[[i]]@pntr, name)
			} else {
				error("c", "arguments must be SpatRaster, SpatRasterCollection, or SpatRasterDataset")
			}
		}
		messages(x, "c")
	}
)

