#' @param binwidth Bin width to use. Defaults to 1/30 of the range of the
#'   data
#' @param breaks Actual breaks to use.  Overrides bin width and origin
#' @param origin Origin of first bin
#' @param width Width of bars when used with categorical data
#' @param right If \code{TRUE}, right-closed, left-open, if \code{FALSE},
#'   the default, right-open, left-closed.
#' @param drop If TRUE, remove all bins with zero counts
#' @return New data frame with additional columns:
#'   \item{count}{number of points in bin}
#'   \item{density}{density of points in bin, scaled to integrate to 1}
#'   \item{ncount}{count, scaled to maximum of 1}
#'   \item{ndensity}{density, scaled to maximum of 1}
#' @export
#' @rdname geom_histogram
stat_bin <- function (mapping = NULL, data = NULL, geom = "bar",
  position = "stack", width = 0.9, drop = FALSE, right = FALSE,
  binwidth = NULL, origin = NULL, breaks = NULL, show_guide = NA,
  inherit.aes = TRUE, ...)
{
  layer(
    data = data,
    mapping = mapping,
    stat = StatBin,
    geom = geom,
    position = position,
    show_guide = show_guide,
    inherit.aes = inherit.aes,
    stat_params = list(
      width = width,
      drop = drop,
      right = right,
      binwidth = binwidth,
      origin = origin,
      breaks = breaks
    ),
    params = list(...)
  )
}

#' @rdname ggplot2-ggproto
#' @format NULL
#' @usage NULL
#' @export
StatBin <- ggproto("StatBin", Stat,
  informed = FALSE,

  calculate_groups = function(self, super, data, ...) {
    if (!is.null(data$y) || !is.null(match.call()$y)) {
      stop("May not have y aesthetic when binning", call. = FALSE)
    }

    self$informed <- FALSE
    super$calculate_groups(self, data, ...)
  },

  calculate = function(self, data, scales, binwidth = NULL, origin = NULL,
                       breaks = NULL, width = 0.9, drop = FALSE,
                       right = FALSE, ...)
  {
    range <- scale_dimension(scales$x, c(0, 0))

    if (is.null(breaks) && is.null(binwidth) && !is.integer(data$x) && !self$informed) {
      message("stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.")
      self$informed <- TRUE
    }

    bin(data$x, data$weight, binwidth = binwidth, origin = origin,
        breaks = breaks, range = range, width = width, drop = drop,
        right = right)
  },

  default_aes = aes(y = ..count..),
  required_aes = c("x")
)

bin <- function(x, weight=NULL, binwidth=NULL, origin=NULL, breaks=NULL, range=NULL, width=0.9, drop = FALSE, right = FALSE) {

  if (length(stats::na.omit(x)) == 0) return(data.frame())
  if (is.null(weight))  weight <- rep(1, length(x))
  weight[is.na(weight)] <- 0

  if (is.null(range))    range <- range(x, na.rm = TRUE, finite=TRUE)
  if (is.null(binwidth)) binwidth <- diff(range) / 30

  if (is.integer(x)) {
    bins <- x
    x <- sort(unique(bins))
    width <- width
  } else if (diff(range) == 0) {
    width <- width
    bins <- x
  } else { # if (is.numeric(x))
    if (is.null(breaks)) {
      if (is.null(origin)) {
        breaks <- fullseq(range, binwidth, pad = TRUE)
      } else {
        breaks <- seq(origin, max(range) + binwidth, binwidth)
      }
    }

    # Adapt break fuzziness from base::hist - this protects from floating
    # point rounding errors
    diddle <- 1e-07 * stats::median(diff(breaks))
    if (right) {
      fuzz <- c(-diddle, rep.int(diddle, length(breaks) - 1))
    } else {
      fuzz <- c(rep.int(-diddle, length(breaks) - 1), diddle)
    }
    fuzzybreaks <- sort(breaks) + fuzz

    bins <- cut(x, fuzzybreaks, include.lowest=TRUE, right = right)
    left <- breaks[-length(breaks)]
    right <- breaks[-1]
    x <- (left + right)/2
    width <- diff(breaks)
  }

  results <- data.frame(
    count = as.numeric(tapply(weight, bins, sum, na.rm=TRUE)),
    x = x,
    width = width
  )

  if (sum(results$count, na.rm = TRUE) == 0) {
    return(results)
  }

  res <- within(results, {
    count[is.na(count)] <- 0
    density <- count / width / sum(abs(count), na.rm=TRUE)
    ncount <- count / max(abs(count), na.rm=TRUE)
    ndensity <- density / max(abs(density), na.rm=TRUE)
  })
  if (drop) res <- subset(res, count > 0)
  res
}
