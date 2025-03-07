#' 2d rectangles.
#'
#' @section Aesthetics:
#' \Sexpr[results=rd,stage=build]{ggplot2:::rd_aesthetics("geom", "rect")}
#'
#' @inheritParams geom_point
#' @export
#' @examples
#' df <- data.frame(
#'   x = sample(10, 20, replace = TRUE),
#'   y = sample(10, 20, replace = TRUE)
#' )
#' ggplot(df, aes(xmin = x, xmax = x + 1, ymin = y, ymax = y + 2)) +
#' geom_rect()
geom_rect <- function (mapping = NULL, data = NULL, stat = "identity",
  position = "identity", show_guide = NA, inherit.aes = TRUE, ...)
{
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomRect,
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
GeomRect <- ggproto("GeomRect", Geom,
  default_aes = aes(colour = NA, fill = "grey20", size = 0.5, linetype = 1,
    alpha = NA),

  required_aes = c("xmin", "xmax", "ymin", "ymax"),

  draw = function(self, data, scales, coordinates, ...) {
    if (!coordinates$is_linear()) {
      aesthetics <- setdiff(
        names(data), c("x", "y", "xmin", "xmax", "ymin", "ymax")
      )

      polys <- plyr::alply(data, 1, function(row) {
        poly <- rect_to_poly(row$xmin, row$xmax, row$ymin, row$ymax)
        aes <- as.data.frame(row[aesthetics],
          stringsAsFactors = FALSE)[rep(1,5), ]

        GeomPolygon$draw(cbind(poly, aes), scales, coordinates)
      })

      ggname("bar", do.call("grobTree", polys))
    } else {
      coords <- coordinates$transform(data, scales)
      ggname("geom_rect", rectGrob(
        coords$xmin, coords$ymax,
        width = coords$xmax - coords$xmin,
        height = coords$ymax - coords$ymin,
        default.units = "native",
        just = c("left", "top"),
        gp = gpar(
          col = coords$colour,
          fill = alpha(coords$fill, coords$alpha),
          lwd = coords$size * .pt,
          lty = coords$linetype,
          lineend = "butt"
        )
      ))
    }
  },

  draw_groups = function(self, ...) self$draw(...),

  draw_key = draw_key_polygon
)


# Convert rectangle to polygon
# Useful for non-Cartesian coordinate systems where it's easy to work purely in terms of locations, rather than locations and dimensions.
#
# @keyword internal
rect_to_poly <- function(xmin, xmax, ymin, ymax) {
  data.frame(
    y = c(ymax, ymax, ymin, ymin, ymax),
    x = c(xmin, xmax, xmax, xmin, xmin)
  )
}
