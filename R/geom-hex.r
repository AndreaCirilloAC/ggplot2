#' Hexagon bining.
#'
#' @section Aesthetics:
#' \Sexpr[results=rd,stage=build]{ggplot2:::rd_aesthetics("geom", "hex")}
#'
#' @export
#' @inheritParams geom_point
#' @examples
#' # See ?stat_binhex for examples
geom_hex <- function (mapping = NULL, data = NULL, stat = "binhex",
  position = "identity", show_guide = NA, inherit.aes = TRUE, ...)
{
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomHex,
    position = position,
    show_guide = show_guide,
    inherit.aes = inherit.aes,
    params = list(...)
  )
}


#' @rdname ggplot2-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomHex <- ggproto("GeomHex", Geom,
  draw = function(self, data, scales, coordinates, ...) {
    coord <- coordinates$transform(data, scales)
    ggname("geom_hex", hexGrob(
      coord$x, coord$y, colour = coord$colour,
      fill = alpha(coord$fill, coord$alpha)
    ))
  },

  required_aes = c("x", "y"),

  default_aes = aes(colour = NA, fill = "grey50", size = 0.5, alpha = NA),

  draw_key = draw_key_polygon
)


# Draw hexagon grob
# Modified from code by Nicholas Lewin-Koh and Martin Maechler
#
# @param x positions of hex centres
# @param y positions
# @param vector of hex sizes
# @param border colour
# @param fill colour
# @keyword internal
hexGrob <- function(x, y, size = rep(1, length(x)), colour = "grey50", fill = "grey90") {
  stopifnot(length(y) == length(x))

  dx <- resolution(x, FALSE)
  dy <- resolution(y, FALSE) / sqrt(3) / 2 * 1.15

  hexC <- hexbin::hexcoords(dx, dy, n = 1)

  n <- length(x)

  polygonGrob(
    x = rep.int(hexC$x, n) * rep(size, each = 6) + rep(x, each = 6),
    y = rep.int(hexC$y, n) * rep(size, each = 6) + rep(y, each = 6),
    default.units = "native",
    id.lengths = rep(6, n), gp = gpar(col = colour, fill = fill)
  )
}
