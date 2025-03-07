#' @export
Coord <- ggproto("Coord",

  aspect = function(ranges) NULL,

  labels = function(scale_details) scale_details,

  render_fg = function(scale_details, theme) element_render(theme, "panel.border"),

  render_bg = function(scale_details, theme) {
    x.major <- if(length(scale_details$x.major) > 0) unit(scale_details$x.major, "native")
    x.minor <- if(length(scale_details$x.minor) > 0) unit(scale_details$x.minor, "native")
    y.major <- if(length(scale_details$y.major) > 0) unit(scale_details$y.major, "native")
    y.minor <- if(length(scale_details$y.minor) > 0) unit(scale_details$y.minor, "native")

    guide_grid(theme, x.minor, x.major, y.minor, y.major)
  },

  render_axis_h = function(scale_details, theme) {
    guide_axis(scale_details$x.major, scale_details$x.labels, "bottom", theme)
  },

  render_axis_v = function(scale_details, theme) {
    guide_axis(scale_details$y.major, scale_details$y.labels, "left", theme)
  },

  range = function(scale_details) {
    return(list(x = scale_details$x.range, y = scale_details$y.range))
  },

  train = function(scale_details) NULL,

  transform = function(data, range) NULL,

  distance = function(x, y, scale_details) NULL,

  is_linear = function() FALSE,

  # Set the default expand values for the scale, if NA
  expand_defaults = function(scale_details, aesthetic = NULL) {
    # Expand the same regardless of whether it's x or y

    # @kohske TODO:
    # Here intentionally verbose. These constants may be held by coord as, say,
    # coord$default.expand <- list(discrete = ..., continuous = ...)
    #
    # @kohske
    # Now scale itself is not changed.
    # This function only returns expanded (numeric) limits
    discrete <- c(0, 0.6)
    continuous <-  c(0.05, 0)
    expand_default(scale_details, discrete, continuous)
  }
)

#' Is this object a coordinate system?
#'
#' @export is.Coord
#' @keywords internal
is.Coord <- function(x) inherits(x, "Coord")


# This is a utility function used by Coord$expand_defaults, to expand a single scale
expand_default <- function(scale, discrete = c(0, 0), continuous = c(0, 0)) {
  # Default expand values for discrete and continuous scales
  if (is.waive(scale$expand)) {
    if (inherits(scale, "discrete")) discrete
    else if (inherits(scale, "continuous")) continuous
  } else {
    return(scale$expand)
  }
}
