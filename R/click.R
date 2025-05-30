# Author: Robert J. Hijmans
# Date : January 2009 - December 2011
# Version 1.0
# License GPL v3


#.getClicks <- function(...) {
#	res <- list()
#	while(TRUE) {
#		loc <- graphics::locator(1, ...)
#		if (is.null(loc)) break
#		res <- c(res, loc)
#	}
#	matrix(res, ncol=2, byrow=TRUE)
#}

RStudio_warning <- function() {
	if (.terra_environment$RStudio_warned) return()
	if (Sys.getenv("RSTUDIO_USER_IDENTITY") != "") {
		warn("'click', 'draw', and 'sel' may not work properly\nwith the default RStudio plotting window. See ?click")
	}
	.terra_environment$RStudio_warned <- TRUE
}


.getCellFromClick <- function(x, n, type, id, ...) {
	#loc <- graphics::locator(n, type, ...)
	#xyCoords <- cbind(x=loc$x, y=loc$y)
	xyCoords <- RS_locator(n, type, ...)
	if (id) {
		text(xyCoords, labels=1:n)
	}
	cells <- cellFromXY(x, xyCoords)
	cells <- unique(stats::na.omit(cells))
	if (length(cells) == 0 ) {
		error("click", "no valid cells selected")
	}
	cells
}



do_click <- function(type="p", id=FALSE, i=1, pch=20, ...) {
	p <- graphics::locator(1)
	if (is.null(p)) return(p) # ESC
	points(p$x, p$y, type=type, pch=pch, ...)
	if (id) {
		text(p$x, p$y, labels=i, pos=4, ...)
	}
	cbind(x=p$x, y=p$y)
}


setMethod("click", signature(x="missing"),
	function(x, n=10, id=FALSE, type="p", show=TRUE, ...) {
	
		RStudio_warning()
	
		#loc <- graphics::locator(n, type, ...)
		#cbind(x=loc$x, y=loc$y)
		n <- max(1, round(n))
		X <- NULL
		if (show) {
			on.exit(return(invisible(X)))
		} else {
			on.exit(return(X))
		}
		for (i in 1:n) {
			x <- do_click(type=type, id=id, i=i, ...)
			if (is.null(x)) break
			X <- rbind(X, x)
			if (show) {
				rownames(x) <- i
				print(x); 
				utils::flush.console()
			}
		}
	}
)


setMethod("click", signature(x="SpatRaster"),
	function(x, n=10, id=FALSE, xy=FALSE, cell=FALSE, type="p", show=TRUE, ...) {

	RStudio_warning()

	n <- max(round(n), 1)
	values <- NULL
	if (show) {
		on.exit(return(invisible(values)))
	} else {
		on.exit(return(values))
	}

	for (i in 1:n) {
		p <- do_click(type=type, id=id, i=i, ...)
		if (is.null(p)) break
		celln <- cellFromXY(x, p)
		if (is.na(celln)) next
		value <- x[celln]
		if (cell) {
			value <- data.frame(cell=celln, value)
		}
		if (xy) {
			p <- xyFromCell(x, celln)
			colnames(p) <- c("x", "y")
			value <- data.frame(p, value)
		}
		if (show) {
			rownames(value) <- i
			print(value)
			utils::flush.console()
		}
#		if (is.null(dim(value))) {
#			value <- matrix(value)
#			colnames(value) <- names(x)
#		}
		values <- rbind(values, value)
	}
})



setMethod("click", signature(x="SpatVector"),
	function(x, n=10, id=FALSE, xy=FALSE, type="p", show=TRUE, ...) {

		RStudio_warning()

		n <- max(round(n), 1)
		values <- xys <- NULL
		if (show) {
			on.exit(return(invisible(values)))
		} else {
			on.exit(return(values))
		}

		for (i in 1:n) {
			p <- do_click(type=type, id=id, i=i, ...)
			if (is.null(p)) break
			e <- extract(x, vect(p))
			if (xy) {
				e <- cbind(e[,1], x=p$x, y=p$y, e[,-1,drop=FALSE])
			}
			names(e)[1] <- "ID"
			if (show) {
				rownames(e) <- i
				if (!id) {
					print(e[,-1])
				} else {
					print(e)
				}
				utils::flush.console()
			}
			values <- rbind(values, e)
		}
	}
)


