#' Quick plot
#'
#' \code{qplot} is the basic plotting function in the ggplot2 package,
#' designed to be familiar if you're used to \code{\link{plot}}
#' from the base package. It is a convenient wrapper for creating
#' a number of different types of plots using a consistent
#' calling scheme. See \url{http://ggplot2.org/book/qplot.pdf}
#' for the chapter in the \code{ggplot2} book which describes the usage
#' of \code{qplot} in detail.
#'
#' @param x x values
#' @param y y values
#' @param ... other aesthetics passed for each layer
#' @param data data frame to use (optional).  If not specified, will create
#'   one, extracting vectors from the current environment.
#' @param facets faceting formula to use.  Picks \code{\link{facet_wrap}} or
#'   \code{\link{facet_grid}} depending on whether the formula is one sided
#'   or two-sided
#' @param margins whether or not margins will be displayed
#' @param geom character vector specifying geom to use.  Defaults to
#'  "point" if x and y are specified, and "histogram" if only x is specified.
#' @param stat,position DEPRECATED.
#' @param xlim limits for x axis
#' @param ylim limits for y axis
#' @param log which variables to log transform ("x", "y", or "xy")
#' @param main character vector or expression for plot title
#' @param xlab character vector or expression for x axis label
#' @param ylab character vector or expression for y axis label
#' @param asp the y/x aspect ratio
#' @aliases qplot quickplot
#' @export qplot quickplot
#' @examples
#' \donttest{
#' # Use data from data.frame
#' qplot(mpg, wt, data = mtcars)
#' qplot(mpg, wt, data = mtcars, colour = cyl)
#' qplot(mpg, wt, data = mtcars, size = cyl)
#' qplot(mpg, wt, data = mtcars, facets = vs ~ am)
#'
#' qplot(1:10, rnorm(10), colour = runif(10))
#' qplot(1:10, letters[1:10])
#' mod <- lm(mpg ~ wt, data=mtcars)
#' qplot(resid(mod), fitted(mod))
#' qplot(resid(mod), fitted(mod), facets = . ~ vs)
#'
#' f <- function() {
#'    a <- 1:10
#'    b <- a ^ 2
#'    qplot(a, b)
#' }
#' f()
#'
#' # qplot will attempt to guess what geom you want depending on the input
#' # both x and y supplied = scatterplot
#' qplot(mpg, wt, data = mtcars)
#' # just x supplied = histogram
#' qplot(mpg, data = mtcars)
#' # just y supplied = scatterplot, with x = seq_along(y)
#' qplot(y = mpg, data = mtcars)
#'
#' # Use different geoms
#' qplot(mpg, wt, data = mtcars, geom = "path")
#' qplot(factor(cyl), wt, data = mtcars, geom = c("boxplot", "jitter"))
#' qplot(mpg, data = mtcars, geom = "dotplot")
#' }
qplot <- function(x, y = NULL, ..., data, facets = NULL, margins=FALSE,
  geom = "auto", xlim = c(NA, NA),
  ylim = c(NA, NA), log = "", main = NULL, xlab = deparse(substitute(x)),
  ylab = deparse(substitute(y)), asp = NA, stat = NULL, position = NULL) {

  if (!missing(stat)) warning("`stat` is deprecated", call. = FALSE)
  if (!missing(position)) warning("`position` is deprecated", call. = FALSE)
  if (!is.character(geom)) stop("`geom` must be a character vector", call. = FALSE)

  argnames <- names(as.list(match.call(expand.dots=FALSE)[-1]))
  arguments <- as.list(match.call()[-1])

  aesthetics <- compact(arguments[.all_aesthetics])
  aesthetics <- aesthetics[!is.constant(aesthetics)]
  aes_names <- names(aesthetics)
  aesthetics <- rename_aes(aesthetics)
  class(aesthetics) <- "uneval"

  if (missing(data)) {
    # If data not explicitly specified, will be pulled from workspace
    data <- data.frame()

    # Faceting variables must be in a data frame, so pull those out
    facetvars <- all.vars(facets)
    facetvars <- facetvars[facetvars != "."]
    names(facetvars) <- facetvars
    facetsdf <- as.data.frame(lapply(facetvars, get))
    if (nrow(facetsdf)) data <- facetsdf
  }

  # Work out plot data, and modify aesthetics, if necessary
  if ("auto" %in% geom) {
    if ("sample" %in% aes_names) {
      geom[geom == "auto"] <- "qq"
    } else if (missing(y)) {
      geom[geom == "auto"] <- "histogram"
      if (missing(ylab)) ylab <- "count"
    } else {
      if (missing(x)) {
        aesthetics$x <- bquote(seq_along(.(y)), aesthetics)
      }
      geom[geom == "auto"] <- "point"
    }
  }

  env <- parent.frame()
  p <- ggplot(data, aesthetics, environment = env)

  if (is.null(facets)) {
    p <- p + facet_null()
  } else if (is.formula(facets) && length(facets) == 2) {
    p <- p + facet_wrap(facets)
  } else {
    p <- p + facet_grid(facets = deparse(facets), margins = margins)
  }

  if (!is.null(main)) p <- p + ggtitle(main)

  # Add geoms/statistics
  for (g in geom) {
    # Arguments are unevaluated because some are aesthetics. Need to evaluate
    # params - can't do in correct env because that's lost (no lazyeval)
    # so do the best we can by evaluating in parent frame.
    params <- arguments[setdiff(names(arguments), c(aes_names, argnames))]
    params <- lapply(params, eval, parent.frame(1))

    p <- p + do.call(paste0("geom_", g), params)
  }

  logv <- function(var) var %in% strsplit(log, "")[[1]]

  if (logv("x")) p <- p + scale_x_log10()
  if (logv("y")) p <- p + scale_y_log10()

  if (!is.na(asp)) p <- p + theme(aspect.ratio = asp)

  if (!missing(xlab)) p <- p + xlab(xlab)
  if (!missing(ylab)) p <- p + ylab(ylab)

  if (!missing(xlim)) p <- p + xlim(xlim)
  if (!missing(ylim)) p <- p + ylim(ylim)

  p
}
quickplot <- qplot

# is.constant
is.constant <- function(x) {
  is_I_call <- function(x) is.call(x) && identical(x[[1]], quote(I))
  vapply(x, is_I_call, logical(1))
}
