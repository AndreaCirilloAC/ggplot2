#' Map projections.
#'
#' This coordinate system provides the full range of map projections available
#' in the mapproj package.
#'
#' This is still experimental, and if you have any advice to offer regarding
#' a better (or more correct) way to do this, please let me know
#'
#' @export
#' @param projection projection to use, see
#'    \code{\link[mapproj]{mapproject}} for list
#' @param ... other arguments passed on to
#'   \code{\link[mapproj]{mapproject}}
#' @param orientation projection orientation, which defaults to
#'  \code{c(90, 0, mean(range(x)))}.  This is not optimal for many
#'  projections, so you will have to supply your own. See
#'  \code{\link[mapproj]{mapproject}} for more information.
#' @param xlim manually specific x limits (in degrees of lontitude)
#' @param ylim manually specific y limits (in degrees of latitude)
#' @export
#' @examples
#' if (require("maps")) {
#' # Create a lat-long dataframe from the maps package
#' nz <- map_data("nz")
#' nzmap <- ggplot(nz, aes(x=long, y=lat, group=group)) +
#'   geom_polygon(fill="white", colour="black")
#'
#' # Use cartesian coordinates
#' nzmap
#' # With default mercator projection
#' nzmap + coord_map()
#' # Other projections
#' nzmap + coord_map("cylindrical")
#' nzmap + coord_map("azequalarea",orientation=c(-36.92,174.6,0))
#'
#' states <- map_data("state")
#' usamap <- ggplot(states, aes(x=long, y=lat, group=group)) +
#'   geom_polygon(fill="white", colour="black")
#'
#' # Use cartesian coordinates
#' usamap
#' # With mercator projection
#' usamap + coord_map()
#' # See ?mapproject for coordinate systems and their parameters
#' usamap + coord_map("gilbert")
#' usamap + coord_map("lagrange")
#'
#' # For most projections, you'll need to set the orientation yourself
#' # as the automatic selection done by mapproject is not available to
#' # ggplot
#' usamap + coord_map("orthographic")
#' usamap + coord_map("stereographic")
#' usamap + coord_map("conic", lat0 = 30)
#' usamap + coord_map("bonne", lat0 = 50)
#'
#' # World map, using geom_path instead of geom_polygon
#' world <- map_data("world")
#' worldmap <- ggplot(world, aes(x=long, y=lat, group=group)) +
#'   geom_path() +
#'   scale_y_continuous(breaks=(-2:2) * 30) +
#'   scale_x_continuous(breaks=(-4:4) * 45)
#'
#' # Orthographic projection with default orientation (looking down at North pole)
#' worldmap + coord_map("ortho")
#' # Looking up up at South Pole
#' worldmap + coord_map("ortho", orientation=c(-90, 0, 0))
#' # Centered on New York (currently has issues with closing polygons)
#' worldmap + coord_map("ortho", orientation=c(41, -74, 0))
#' }
coord_map <- function(projection="mercator", ..., orientation = NULL, xlim = NULL, ylim = NULL) {
  ggproto(NULL, CoordMap,
    projection = projection,
    orientation = orientation,
    limits = list(x = xlim, y = ylim),
    params = list(...)
  )
}


CoordMap <- ggproto("CoordMap", Coord,

  transform = function(self, data, scale_details) {
    trans <- mproject(self, data$x, data$y, scale_details$orientation)
    out <- cunion(trans[c("x", "y")], data)

    out$x <- rescale(out$x, 0:1, scale_details$x.proj)
    out$y <- rescale(out$y, 0:1, scale_details$y.proj)
    out
  },

  distance = function(x, y, scale_details) {
    max_dist <- dist_central_angle(scale_details$x.range, scale_details$y.range)
    dist_central_angle(x, y) / max_dist
  },

  aspect = function(ranges) {
    diff(ranges$y.proj) / diff(ranges$x.proj)
  },

  train = function(self, scale_details) {

    # range in scale
    ranges <- list()
    for (n in c("x", "y")) {

      scale <- scale_details[[n]]
      limits <- self$limits[[n]]

      if (is.null(limits)) {
        expand <- self$expand_defaults(scale, n)
        range <- scale_dimension(scale, expand)
      } else {
        range <- range(scale_transform(scale, limits))
      }
      ranges[[n]] <- range
    }

    orientation <- self$orientation %||% c(90, 0, mean(ranges$x))

    # Increase chances of creating valid boundary region
    grid <- expand.grid(
      x = seq(ranges$x[1], ranges$x[2], length.out = 50),
      y = seq(ranges$y[1], ranges$y[2], length.out = 50)
    )

    ret <- list(x = list(), y = list())

    # range in map
    proj <- mproject(self, grid$x, grid$y, orientation)$range
    ret$x$proj <- proj[1:2]
    ret$y$proj <- proj[3:4]

    for (n in c("x", "y")) {
      out <- scale_break_info(scale_details[[n]], ranges[[n]])
      ret[[n]]$range <- out$range
      ret[[n]]$major <- out$major_source
      ret[[n]]$minor <- out$minor_source
      ret[[n]]$labels <- out$labels
    }

    details <- list(
      orientation = orientation,
      x.range = ret$x$range, y.range = ret$y$range,
      x.proj = ret$x$proj, y.proj = ret$y$proj,
      x.major = ret$x$major, x.minor = ret$x$minor, x.labels = ret$x$labels,
      y.major = ret$y$major, y.minor = ret$y$minor, y.labels = ret$y$labels
    )
    details
  },

  render_bg = function(self, scale_details, theme) {
    xrange <- expand_range(scale_details$x.range, 0.2)
    yrange <- expand_range(scale_details$y.range, 0.2)

    # Limit ranges so that lines don't wrap around globe
    xmid <- mean(xrange)
    ymid <- mean(yrange)
    xrange[xrange < xmid - 180] <- xmid - 180
    xrange[xrange > xmid + 180] <- xmid + 180
    yrange[yrange < ymid - 90] <- ymid - 90
    yrange[yrange > ymid + 90] <- ymid + 90

    xgrid <- with(scale_details, expand.grid(
      y = c(seq(yrange[1], yrange[2], length.out = 50), NA),
      x = x.major
    ))
    ygrid <- with(scale_details, expand.grid(
      x = c(seq(xrange[1], xrange[2], length.out = 50), NA),
      y = y.major
    ))

    xlines <- self$transform(xgrid, scale_details)
    ylines <- self$transform(ygrid, scale_details)

    if (nrow(xlines) > 0) {
      grob.xlines <- element_render(
        theme, "panel.grid.major.x",
        xlines$x, xlines$y, default.units = "native"
      )
    } else {
      grob.xlines <- zeroGrob()
    }

    if (nrow(ylines) > 0) {
      grob.ylines <- element_render(
        theme, "panel.grid.major.y",
        ylines$x, ylines$y, default.units = "native"
      )
    } else {
      grob.ylines <- zeroGrob()
    }

    ggname("grill", grobTree(
      element_render(theme, "panel.background"),
      grob.xlines, grob.ylines
    ))
  },

  render_axis_h = function(self, scale_details, theme) {
    if (is.null(scale_details$x.major)) return(zeroGrob())

    x_intercept <- with(scale_details, data.frame(
      x = x.major,
      y = y.range[1]
    ))
    pos <- self$transform(x_intercept, scale_details)

    guide_axis(pos$x, scale_details$x.labels, "bottom", theme)
  },

  render_axis_v = function(self, scale_details, theme) {
    if (is.null(scale_details$y.major)) return(zeroGrob())

    x_intercept <- with(scale_details, data.frame(
      x = x.range[1],
      y = y.major
    ))
    pos <- self$transform(x_intercept, scale_details)

    guide_axis(pos$y, scale_details$y.labels, "left", theme)
  }
)


mproject <- function(coord, x, y, orientation) {
  suppressWarnings(mapproj::mapproject(x, y,
    projection = coord$projection,
    parameters  = coord$params,
    orientation = orientation
  ))
}
