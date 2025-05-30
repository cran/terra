
.terra_environment <- new.env(parent=emptyenv())

.create_options <- function() {
	opt <- methods::new("SpatOptions")
	opt@pntr <- SpatOptions$new()
	# check=T does not exist in ancient R
	tmpdir <- try(tempdir(check = TRUE), silent=TRUE)
	opt@pntr$tempdir <- normalizePath(tempdir(), winslash="/")
	.terra_environment$options <- opt
	.terra_environment$devs <- NULL
	.terra_environment$RStudio_warned <- FALSE

	x <- options("terra_default")[[1]]
	if (!is.null(x)) {
		do.call(terraOptions, x)
	}

}

.option_names <- function() {
	c("progress", "progressbar", "tempdir", "memfrac", "memmax", "memmin", "datatype", "filetype", "filenames", "overwrite", "todisk", "names", "verbose", "NAflag", "statistics", "steps", "ncopies", "tolerance", "tmpfile", "threads", "scale", "offset", "parallel") #, "append")
}


.setOptions <- function(x, wopt) {

	nms <- names(wopt)
	g <- which(nms == "gdal")
	if (length(g) > 0) {
		gopt <- unlist(wopt[g])
		wopt <- wopt[-g]
		nms <- nms[-g]
		i <- grep("=", gopt)
		gopt <- gopt[i]
		gopt <- gsub(" ", "", gopt)
		x$gdal_options <- gopt
	}

	i <- which(nms == "metadata")
	if (length(i) > 0) {
		m <- try(parse_tags(wopt[[i]], "USER_TAGS"))
		if (!inherits(m, "try-error")) {
			if (NROW(m) > 0) {
				x$metadata <- apply(m, 1, function(i) paste(i, collapse="_#_"))
			}
		}
		wopt <- wopt[-i]
		nms <- nms[-i]
	}

	s <- nms %in% .option_names()

	if (any(!s)) {
		bad <- paste(nms[!s], collapse=",")
		error("write", "unknown option(s): ", bad)
	}



	if (any(s)) {
		nms <- nms[s]
		wopt <- wopt[s]
		i <- which(nms == "names")
		if (length(i) > 0) {
			namevs <- trimws(unlist(strsplit(as.character(wopt[[i]]), ",")))
			x[["names"]] <- namevs
			wopt <- wopt[-i]
			nms <- nms[-i]
		}
		if ("tempdir" %in% nms) {
			i <- which(nms == "tempdir")
			if (!dir.exists(wopt[[i]])) {
				warn("options", "you cannot set the tempdir to a path that does not exist")
				wopt <- wopt[-i]
				nms <- nms[-i]
			}
		}

		for (i in seq_along(nms)) {
			x[[nms[i]]] <- wopt[[i]]
		}
	}
	if (x$has_warning()) {
		warn("options", paste(x$getWarnings(), collapse="\n"))
	}
	if (x$has_error()) {
		error("options", x$getError())
	}
	x
}


defaultOptions <- function() {
	## work around onLoad problem
	if (is.null(.terra_environment$options)) .create_options()
	.terra_environment$options@pntr$deepcopy()
}

spatOptions <- function(filename="", overwrite=FALSE, ..., wopt=NULL) {

	wopt <- c(list(...), wopt)

	## work around onLoad problem
	if (is.null(.terra_environment$options)) .create_options()

	opt <- .terra_environment$options@pntr$deepcopy()
	opt$tmpfile <- paste0(gsub("^file", "", basename(tempfile())),  "_", Sys.getpid())
	filename <- .fullFilename(filename, mustExist=TRUE)
	if (!is.null(unlist(wopt))) {
		wopt$filenames <- filename
		wopt$overwrite <- overwrite[1]
		opt <- .setOptions(opt, wopt)
	} else {
		opt$filenames <- filename
		opt$overwrite <- overwrite[1]
	}
	#messages(opt)
	#opt$todisk <- TRUE
	opt
}

#..getOptions <- function() {
#	spatOptions("", TRUE, list())
#}

#..showOptions <- function(opt) {
#	cat("Options for package 'terra'\n")
#	cat("memfrac     :" , opt$memfrac, "\n")
#	cat("tempdir     :" , opt$tempdir, "\n")
#	cat("datatype    :" , opt$def_datatype, "\n")
#	cat("filetype    :" , opt$def_filetype, "\n")
#	cat("progress    :" , opt$progress, "\n")
#	cat("verbose     :" , opt$verbose, "\n")
#	if (opt$todisk) {
#		cat("todisk      :" , opt$todisk, "\n")
#	}
#}


.getOptions <- function() {
	opt <- spatOptions()
	nms <- names(opt)
	nms <- nms[!grepl("^\\.", nms)]
	nms <- nms[!(nms %in% c("initialize", "messages", "getClass", "finalize", "datatype_set", "tmpfile", "statistics", "gdal_options", "scale", "offset", "threads", "filenames", "NAflag"))]
	defnms <- grepl("^def_", nms)
	nms <- nms[!defnms]
	out <- sapply(nms, function(n) eval(parse(text=paste0("opt$", n))))
	out$memmin <- 8 * out$memmin / (1024^3)
	if (out$memmax > 0) {
		out$memmax <- 8 * out$memmax / (1024^3)
	} 
	out
}

.showOptions <- function(opt, print=TRUE) {
	out <- .getOptions()
	if (!print) return(out)
	nms <- c("memfrac", "tempdir", "datatype", "progress", "todisk", "verbose", "tolerance", "memmin", "memmax")
	p <- out[names(out) %in% nms]
	if (p$memmax <= 0) p$memmax <- NULL
	nms <- names(p)
	for (i in seq_along(nms)) {
		cat(paste0(substr(paste(nms[i], "         "), 1, 10), ": ", p[i], "\n"))
	}
	invisible(out)
}


.default_option_names <- function() {
	c("datatype", "filetype") #, "verbose")
}


terraOptions <- function(..., print=TRUE) {
	dots <- list(...)
	if (is.null(.terra_environment$options)) .create_options()
	opt <- .terra_environment$options@pntr

	nms <- names(dots)

	if (length(dots) == 0) {
		return(.showOptions(opt, print=print))
	}

	ok <- nms %in% .option_names()
	if (any(!ok)) {
		bad <- paste(nms[!ok], collapse=", ")
		warn("terraOptions<-", paste("unknown option(s):", bad))
		dots <- dots[ok]
		nms <- nms[ok]			
		if (length(dots) == 0) return(invisible())
	}

	if ("tempdir" %in% nms) {
		i <- which(nms == "tempdir")
		dots[i] <- path.expand(trimws(dots[i]))
		if (!dir.exists(dots[[i]])) {
			warn("options", "you cannot set the tempdir to a path that does not exist")
			dots <- dots[-i]
			nms <- nms[-i]
			if (length(dots) == 0) return(invisible())
		}
	}

	d <- nms %in% .default_option_names()
	dnms <- paste0("def_", nms)
	for (i in 1:length(nms)) {
		if (d[i]) {
			opt[[ dnms[i] ]] <- dots[[ i ]]
		} else {
			opt[[ nms[i] ]] <- dots[[ i ]]
		}
	}
		
	if ("memfrac" %in% nms) {
		if (dots$memfrac > 0.9) {
			warn("terraOptions", "memfrac > 0.9")
		}
	}
	.terra_environment$options@pntr <- opt
}

