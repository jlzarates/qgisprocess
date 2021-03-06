
#' Convert raster objects to/from QGIS inputs/outputs
#'
#' @param x A [raster::raster()] or [raster::brick()].
#' @param output The result from [qgis_run_algorithm()] or [qgis_output()].
#' @param ... Passed to [raster::raster()] or [raster::brick()].
#' @inheritParams as_qgis_argument
#'
#' @export
#'
as_qgis_argument.RasterLayer <- function(x, spec = qgis_argument_spec()) {
  as_qgis_argument_raster(x, spec)
}

#' @rdname as_qgis_argument.RasterLayer
#' @export
as_qgis_argument.RasterBrick <- function(x, spec = qgis_argument_spec()) {
  as_qgis_argument_raster(x, spec)
}

as_qgis_argument_raster <- function(x, spec = qgis_argument_spec()) {
  if (!isTRUE(spec$qgis_type %in% c("raster", "layer", "multilayer"))) {
    abort(glue("Can't convert '{ class(x)[1] }' object to QGIS type '{ spec$qgis_type }'"))
  }

  # try to use a filename if present
  if (x@file@name != ""){
    file_ext <- stringr::str_to_lower(tools::file_ext(x@file@name))
    if (file_ext %in% c("grd", "asc", "sdat", "rst", "nc", "tif", "tiff", "gtiff", "envi", "bil", "img")) {
      return(x@file@name)
    }
  }

  path <- qgis_tmp_raster()
  raster::writeRaster(x, path)
  structure(path, class = "qgis_tempfile_arg")
}

#' @rdname as_qgis_argument.RasterLayer
#' @export
qgis_as_raster <- function(output, ...) {
  UseMethod("qgis_as_raster")
}

#' @rdname as_qgis_argument.RasterLayer
#' @export
qgis_as_brick <- function(output, ...) {
  UseMethod("qgis_as_brick")
}

#' @rdname as_qgis_argument.RasterLayer
#' @export
qgis_as_raster.qgis_outputRaster <- function(output, ...) {
  raster::raster(unclass(output), ...)
}

#' @rdname as_qgis_argument.RasterLayer
#' @export
qgis_as_brick.qgis_outputRaster <- function(output, ...) {
  raster::brick(unclass(output), ...)
}

#' @rdname as_qgis_argument.RasterLayer
#' @export
qgis_as_raster.qgis_outputLayer <- function(output, ...) {
  raster::raster(unclass(output), ...)
}

#' @rdname as_qgis_argument.RasterLayer
#' @export
qgis_as_brick.qgis_outputLayer <- function(output, ...) {
  raster::brick(unclass(output), ...)
}

#' @rdname as_qgis_argument.RasterLayer
#' @export
qgis_as_raster.qgis_result <- function(output, ...) {
  # find the first raster output and read it
  for (result in output) {
    if (inherits(result, "qgis_outputRaster") || inherits(result, "qgis_outputLayer")) {
      return(raster::raster(unclass(result), ...))
    }
  }

  abort("Can't extract raster from result: zero outputs of type 'outputRaster' or 'outputLayer'.")
}

#' @rdname as_qgis_argument.RasterLayer
#' @export
qgis_as_brick.qgis_result <- function(output, ...) {
  # find the first rqster output and read it
  for (result in output) {
    if (inherits(result, "qgis_outputRaster") || inherits(result, "qgis_outputLayer")) {
      return(raster::brick(unclass(result), ...))
    }
  }

  abort("Can't extract brick from result: zero outputs of type 'outputRaster' or 'outputLayer'.")
}
