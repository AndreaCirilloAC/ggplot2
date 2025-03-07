#' Contours from a 2d density estimate.
#'
#' Perform a 2D kernel density estimation using kde2d and display the
#' results with contours.
#'
#' This can be useful for dealing with overplotting.
#'
#' @section Aesthetics:
#' \Sexpr[results=rd,stage=build]{ggplot2:::rd_aesthetics("geom", "density2d")}
#'
#' @seealso \code{\link{geom_contour}} for contour drawing geom,
#'  \code{\link{stat_sum}} for another way of dealing with overplotting
#' @inheritParams geom_point
#' @inheritParams geom_path
#' @export
#' @examples
#' # See stat_density2d for examples
geom_density2d <- function (mapping = NULL, data = NULL, stat = "density2d",
  position = "identity", lineend = "butt", linejoin = "round", linemitre = 1,
  na.rm = FALSE, show_guide = NA, inherit.aes = TRUE, ...)
{
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomDensity2d,
    position = position,
    show_guide = show_guide,
    inherit.aes = inherit.aes,
    geom_params = list(
      lineend = lineend,
      linejoin = linejoin,
      linemitre = linemitre,
      na.rm = na.rm
    ),
    params = list(...)
  )
}


#' @rdname ggplot2-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomDensity2d <- ggproto("GeomDensity2d", GeomPath,
  default_aes = aes(colour="#3366FF", size = 0.5, linetype = 1, alpha = NA)
)
