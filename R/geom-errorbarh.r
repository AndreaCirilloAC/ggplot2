#' Horizontal error bars
#'
#' @section Aesthetics:
#' \Sexpr[results=rd,stage=build]{ggplot2:::rd_aesthetics("geom", "errorbarh")}
#'
#' @seealso \code{\link{geom_errorbar}}: vertical error bars
#' @inheritParams geom_point
#' @export
#' @examples
#' df <- data.frame(
#'   trt = factor(c(1, 1, 2, 2)),
#'   resp = c(1, 5, 3, 4),
#'   group = factor(c(1, 2, 1, 2)),
#'   se = c(0.1, 0.3, 0.3, 0.2)
#' )
#'
#' # Define the top and bottom of the errorbars
#'
#' p <- ggplot(df, aes(resp, trt, colour = group))
#' p + geom_point() +
#'   geom_errorbarh(aes(xmax = resp + se, xmin = resp - se))
#' p + geom_point() +
#'   geom_errorbarh(aes(xmax = resp + se, xmin = resp - se, height = .2))
geom_errorbarh <- function (mapping = NULL, data = NULL, stat = "identity",
  position = "identity", show_guide = NA, inherit.aes = TRUE, ...)
{
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomErrorbarh,
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
GeomErrorbarh <- ggproto("GeomErrorbarh", Geom,
  default_aes = aes(colour = "black", size = 0.5, linetype = 1, height = 0.5,
    alpha = NA),

  draw_key = draw_key_path,

  required_aes = c("x", "xmin", "xmax", "y"),

  reparameterise = function(df, params) {
    df$height <- df$height %||%
      params$height %||% (resolution(df$y, FALSE) * 0.9)

    transform(df,
      ymin = y - height / 2, ymax = y + height / 2, height = NULL
    )
  },

  draw = function(data, scales, coordinates, height = NULL, ...) {
    GeomPath$draw(data.frame(
      x = as.vector(rbind(data$xmax, data$xmax, NA, data$xmax, data$xmin, NA, data$xmin, data$xmin)),
      y = as.vector(rbind(data$ymin, data$ymax, NA, data$y,    data$y,    NA, data$ymin, data$ymax)),
      colour = rep(data$colour, each = 8),
      alpha = rep(data$alpha, each = 8),
      size = rep(data$size, each = 8),
      linetype = rep(data$linetype, each = 8),
      group = rep(1:(nrow(data)), each = 8),
      stringsAsFactors = FALSE,
      row.names = 1:(nrow(data) * 8)
    ), scales, coordinates, ...)
  }
)
