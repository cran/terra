
# version 1.3-4

## new

- `na.omit,SpatVector-method` to remove empty geometries and/or attribute records that have an `NA`
- new method `src` to create a `SpatRasterCollection` (a loose collection of tiles). 
- `merge` and `mosaic` now have methods for a `SpatRasterCollection`. To avoid the (inefficient) use of `do.call`. See issue [#210](https://github.com/rspatial/terra/issues/210) by Matthew Talluto.
- `activeCat` and `activeCat<-` to get or set the "active" category if there are multiple categories (raster attributes)
- `as.numeric` and `catalyze` to transfer categories to numeric cell values
- summarize methods such as `range` and `mean` for (the attributes of) a `SpatVector`
- new method `shade`, to compute hill shading

## enhancements

- additional arguments (such as `na.rm`) are now used by `rasterize` with point geometries. Suggested by Jakub Nowosad  [#209](https://github.com/rspatial/terra/issues/209)
- improved handling (and documentation) of `gstat` models by `interpolate`. See issue [#208](https://github.com/rspatial/terra/issues/208) by Jakub Nowosad.
- new argument `cpkgs` to `predict` to list the packages that need to be exported to the cores if argument `cores` is larger than one. `?predict` now shows different approaches to parallelize `predict` (based on examples in issue [#178](
https://github.com/rspatial/terra/issues/178) raised by by Matthew Coghill).
- `freq` now returns labels for categorical layers
- `adjacent` now has a `pairs` argument. Requested by Kenneth Blake Vernon in issue [#239](https://github.com/rspatial/terra/issues/239) 
- `adjacent` now also takes a matrix to specify adjacent cells
- `mean` and other summarize methods now take a `filename` argument and disallow non-recognized named arguments. See issue [#238](https://github.com/rspatial/terra/issues/238) by Jessica Nephin
- The raster attribute table of ESRI-GRID integer data, or from an ESRI `vat.dbf` file is now ignored if it only has the counts of the values. See issue [#234]( https://github.com/rspatial/terra/issues/234) by Jullee
- time attributes are no longer lost when doing raster operations. Suggested by Mauricio Zambrano-Bigiarini in [#246]( https://github.com/rspatial/terra/issues/246)
- resample (and project) no longer ignore `gdal=""` write options and use BIGTIFF if necessary (suggested by Ani Ghosh)
- new argument `layer` in the `extract-SpatRaster,SpatVector` method to extract values for a single layers specified for each geometry (see this [question](https://gis.stackexchange.com/a/401591/8993)).

## bug fixes 

- better handling of paths with "special" characters (e.g., Chinese) for GeoTiff but still fails for NetCDF (see issue [#233](https://github.com/rspatial/terra/issues/223) by Dongdong Kong)
- `extract` with points and `cells=TRUE` or `xy=TRUE` gave garbled output
- `as.character,SpatRaster-method` (called by `wrap`) did not capture the layer names. Reported by Pascal Title [#213](https://github.com/rspatial/terra/issues/213)
- `focal` mirrored the weight matrix, thus affecting the results when using an asymmetrical weight matrix. Reported by Sebastiano Trevisani
- `terra::terraOptions` now works without attaching the package (issue [#229](https://github.com/rspatial/terra/issues/229) reported by Karl Dunkle Werner)
- `app` with `ncores > 0` and a function that returns multiple layers now works (issue [#240](https://github.com/rspatial/terra/issues/240) reported by BastienFR.
- `autocor` (local) can now handle `NA`s. Reported by Jakub Nowosad [#245](https://github.com/rspatial/terra/issues/245).
- `mask` with a SpatVector and a large (out of memory) multi-layer SpatRaster only worked for the first layer. Reported by Monika Tomaszewska.



# version 1.2-10

## new

- `as.lines` method for SpatRaster
- `as.polygons` method for SpatVector lines
- `autocor,numeric-method` has new methods `mean`, to compute the local mean, and `locmor`, for the local Moran's *I* 
- `sharedPaths` method for SpatVector (lines and polygons)
- `RGB2col` method to reduce a three-layer RGB SpatRaster to a single layer SpatRaster with a color-table (with <= 256 colors)
- `split` methods for SpatVector and SpatRaster



## enhancements

- `rast(Raster*)` now takes the crs from the Raster object, not from the file it may point to. Suggested by Floris Vanderhaeghe [#200](https://github.com/rspatial/terra/issues/200)
- `convhull` has a new argument `by=""` to make convex hulls for sub-sets of a SpatVector.
- faster processing of large in memory rasters. See issue [#206](https://github.com/rspatial/terra/issues/206) by Krzysztof Dyba.


## bug fixes

- `extract` with multiple layers could return a data.frame where the values were not in the correct order (by row instead of by column)
- `crop` works again with `sf` objects. Reported by Sebastian Brinkmann [#201] (https://github.com/rspatial/terra/issues/201)
- `vect,sf-method` now also works for lines, and should be faster
- `vect,character` crashed R if a file had empty geometries. Reported by consumere [#202](https://github.com/rspatial/terra/issues/202)
- `extract(points, bilinear=TRUE, cells=TRUE)` now works. Reported by fab4app [#203](https://github.com/rspatial/terra/issues/203)
- `zonal` now works for `min` and `max`. Reported by Jakub Nowosad  [#207](https://github.com/rspatial/terra/issues/207)


## name changes

To avoid name conflicts with the `spatstat` package

- `area,SpatRaster-method(x, sum=FALSE)` -> `cellSize(x)`
- `area,SpatRaster/SpatVector-method(x, sum=TRUE)` -> `expanse(x)`
- `convexhull` -> `convHull`
- `perimeter` -> `perim`
- `tiles` -> `makeTiles`
- `coords` -> `crds`


# version 1.2-5

## new

- `trim` has a new argument `value` that allows trimming rows and columns with other values than the default `NA`
- `rapp` has a new argument `clamp` that allows clamping start and end values to `1:nlyr(x)`, avoiding that all values are considered `NA`
- `spatSample,SpatRaster-method` has new arguments `as.points` and `values`. Getting values, cells and coordinates is no longer mutually exclusive. In response to [#191](https://github.com/rspatial/terra/issues/191). Requested by Agustin Lobo
- `area,SpatRaster-method` has a new argument `mask=FALSE`
- `classify` can now take a single number to request that many cuts
- `mosaic` and `merge` now warn and resample if rasters are not aligned
- `extract` has a new argument `exact` to get the fraction covered for each cell

## bug fixes

- `flip(x, direction="vertical")` no longer reverses the order of the layers
- `extract` did not work for horizontal or vertical lines as their extent was considered invalid. Reported by Monika Tomaszewska
- `autocor` did not handle NA values [#192](https://github.com/rspatial/terra/issues/192). Reported by Laurence Hawker
- `nearest` now works for angular coordinates
- The unit of `slope` in `terrain` was not correct (the tangent was returned instead of the slope) [#196](https://github.com/rspatial/terra/issues/196). Reported by Sven Alder
- `quantile` now works for rasters that have cells that are all `NA`. Reported by Jerry Nelson

## name changes

To avoid name conflicts with tidyverse 

with deprecation warning:

- separate -> segregate
- expand -> extend
- near -> nearby
- pack -> wrap 

without deprecation warning:

- transpose -> trans
- collapse -> tighten 
- fill -> fillHoles
- select -> sel


# version 1.1-17

## major changes 

- `c,SpatVector-method` now returns a list. `rbind` is used to append SpatVector objects
- overhaul of handling of factors. `rats` has been removed, and `levels` and `cats` have changed


# version 1.1-4

- No news recorded for this version and earlier versions
