#' Hollow bar with middle indicated by horizontal line.
#'
#' @section Aesthetics:
#' \Sexpr[results=rd,stage=build]{ggplot2:::rd_aesthetics("geom", "crossbar")}
#'
#' @inheritParams geom_point
#' @param fatten a multiplicate factor to fatten middle bar by
#' @seealso \code{\link{geom_errorbar}} for error bars,
#' \code{\link{geom_pointrange}} and \code{\link{geom_linerange}} for other
#' ways of showing mean + error, \code{\link{stat_summary}} to compute
#' errors from the data, \code{\link{geom_smooth}} for the continuous analog.
#' @export
#' @examples
#' # See geom_linerange for examples
geom_crossbar <- function(mapping = NULL, data = NULL, stat = "identity",
  position = "identity", fatten = 2.5, show_guide = NA, inherit.aes = TRUE, ...)
{
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomCrossbar,
    position = position,
    show_guide = show_guide,
    inherit.aes = inherit.aes,
    geom_params = list(fatten = fatten),
    params = list(...)
  )
}

#' @rdname ggplot2-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomCrossbar <- ggproto("GeomCrossbar", Geom,
  reparameterise = function(df, params) {
    GeomErrorbar$reparameterise(df, params)
  },

  default_aes = aes(colour = "black", fill = NA, size = 0.5, linetype = 1,
    alpha = NA),

  required_aes = c("x", "y", "ymin", "ymax"),

  draw_key = draw_key_crossbar,

  draw = function(self, data, scales, coordinates, fatten = 2.5, width = NULL, ...) {
    middle <- transform(data, x = xmin, xend = xmax, yend = y, size = size * fatten, alpha = NA)

    has_notch <- !is.null(data$ynotchlower) && !is.null(data$ynotchupper) &&
      !is.na(data$ynotchlower) && !is.na(data$ynotchupper)

    if (has_notch) {
      if (data$ynotchlower < data$ymin  ||  data$ynotchupper > data$ymax)
        message("notch went outside hinges. Try setting notch=FALSE.")

      notchindent <- (1 - data$notchwidth) * (data$xmax - data$xmin) / 2

      middle$x <- middle$x + notchindent
      middle$xend <- middle$xend - notchindent

      box <- data.frame(
        x = c(
          data$xmin, data$xmin, data$xmin + notchindent, data$xmin, data$xmin,
          data$xmax, data$xmax, data$xmax - notchindent, data$xmax, data$xmax,
          data$xmin
        ),
        y = c(
          data$ymax, data$ynotchupper, data$y, data$ynotchlower, data$ymin,
          data$ymin, data$ynotchlower, data$y, data$ynotchupper, data$ymax,
          data$ymax
        ),
        alpha = data$alpha,
        colour = data$colour,
        size = data$size,
        linetype = data$linetype, fill = data$fill,
        group = seq_len(nrow(data)),
        stringsAsFactors = FALSE
      )
    } else {
      # No notch
      box <- data.frame(
        x = c(data$xmin, data$xmin, data$xmax, data$xmax, data$xmin),
        y = c(data$ymax, data$ymin, data$ymin, data$ymax, data$ymax),
        alpha = data$alpha,
        colour = data$colour,
        size = data$size,
        linetype = data$linetype,
        fill = data$fill,
        group = seq_len(nrow(data)), # each bar forms it's own group
        stringsAsFactors = FALSE
      )
    }

    ggname("geom_crossbar", gTree(children = gList(
      GeomPolygon$draw(box, scales, coordinates, ...),
      GeomSegment$draw(middle, scales, coordinates, ...)
    )))
  }
)
