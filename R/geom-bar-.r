#' Bars, rectangles with bases on x-axis
#'
#' The bar geom is used to produce 1d area plots: bar charts for categorical
#' x, and histograms for continuous y.  stat_bin explains the details of
#' these summaries in more detail.  In particular, you can use the
#' \code{weight} aesthetic to create weighted histograms and barcharts where
#' the height of the bar no longer represent a count of observations, but a
#' sum over some other variable.  See the examples for a practical
#' example.
#'
#' The heights of the bars commonly represent one of two things: either a
#' count of cases in each group, or the values in a column of the data frame.
#' By default, \code{geom_bar} uses \code{stat="bin"}. This makes the height
#' of each bar equal to the number of cases in each group, and it is
#' incompatible with mapping values to the \code{y} aesthetic. If you want
#' the heights of the bars to represent values in the data, use
#' \code{stat="identity"} and map a value to the \code{y} aesthetic.
#'
#' By default, multiple x's occuring in the same place will be stacked a top
#' one another by position_stack.  If you want them to be dodged from
#' side-to-side, see \code{\link{position_dodge}}. Finally,
#' \code{\link{position_fill}} shows relative propotions at each x by stacking
#' the bars and then stretching or squashing to the same height.
#'
#' Sometimes, bar charts are used not as a distributional summary, but
#' instead of a dotplot.  Generally, it's preferable to use a dotplot (see
#' \code{geom_point}) as it has a better data-ink ratio.  However, if you do
#' want to create this type of plot, you can set y to the value you have
#' calculated, and use \code{stat='identity'}
#'
#' A bar chart maps the height of the bar to a variable, and so the base of
#' the bar must always been shown to produce a valid visual comparison.
#' Naomi Robbins has a nice
#' \href{http://www.b-eye-network.com/view/index.php?cid=2468}{article on this topic}.
#' This is the reason it doesn't make sense to use a log-scaled y axis with a bar chart
#'
#' @section Aesthetics:
#' \Sexpr[results=rd,stage=build]{ggplot2:::rd_aesthetics("geom", "bar")}
#'
#' @seealso \code{\link{stat_bin}} for more details of the binning algorithm,
#'   \code{\link{position_dodge}} for creating side-by-side barcharts,
#'   \code{\link{position_stack}} for more info on stacking,
#' @export
#' @inheritParams geom_point
#' @examples
#' \donttest{
#' # Generate data
#' g <- ggplot(mtcars, aes(factor(cyl)))
#'
#' # By default, uses stat = "bin", which gives the count in each category
#' g + geom_bar()
#' g + geom_bar(width = 0.5)
#' g + geom_bar() +
#'   coord_flip()
#' g + geom_bar(fill = "white", colour = "darkgreen")
#'
#' # When the data contains y values in a column, use stat = "identity"
#' library(plyr)
#' # Calculate the mean mpg for each level of cyl
#' mm <- ddply(mtcars, "cyl", summarise, mmpg = mean(mpg))
#' ggplot(mm, aes(factor(cyl), mmpg)) +
#'   geom_bar(stat = "identity")
#'
#' # Stacked bar charts
#' g <- ggplot(mtcars, aes(factor(cyl)))
#' g + geom_bar(aes(fill = factor(vs)))
#' g + geom_bar(aes(fill = factor(gear)))
#'
#' # Stacked bar charts are easy in ggplot2, but not effective visually,
#' # particularly when there are many different things being stacked
#' ggplot(diamonds, aes(clarity, fill = cut)) +
#'   geom_bar()
#' ggplot(diamonds, aes(color, fill = cut)) +
#'   geom_bar() +
#'   coord_flip()
#'
#' # Faceting is a good alternative:
#' ggplot(diamonds, aes(clarity)) +
#'   geom_bar() +
#'   facet_wrap(~ cut)
#' # If the x axis is ordered, using a line instead of bars is another
#' # possibility:
#' ggplot(diamonds, aes(clarity)) +
#'   geom_freqpoly(aes(group = cut, colour = cut))
#'
#' # Dodged bar charts
#' ggplot(diamonds, aes(clarity, fill = cut)) +
#'   geom_bar(position = "dodge")
#' # compare with
#' ggplot(diamonds, aes(cut, fill = cut)) +
#'   geom_bar() +
#'   facet_grid(. ~ clarity)
#'
#' # But again, probably better to use frequency polygons instead:
#' ggplot(diamonds, aes(clarity, colour = cut)) +
#'   geom_freqpoly(aes(group = cut))
#'
#' # Often we don't want the height of the bar to represent the
#' # count of observations, but the sum of some other variable.
#' # For example, the following plot shows the number of diamonds
#' # of each colour
#'
#' ggplot(diamonds) +
#'   geom_bar(aes(color))
#' # If, however, we want to see the total number of carats in each colour
#' # we need to weight by the carat variable
#' ggplot(diamonds) +
#'   geom_bar(aes(color, weight = carat)) +
#'   ylab("carat")
#'
#' # A bar chart used to display means
#' meanprice <- tapply(diamonds$price, diamonds$cut, mean)
#' cut <- factor(levels(diamonds$cut), levels = levels(diamonds$cut))
#' df <- data.frame(meanprice, cut)
#' g <- ggplot(df, aes(cut, meanprice))
#' g + geom_bar(stat = "identity")
#' g + geom_bar(stat = "identity", fill = "grey50")
#'
#' # Another stacked bar chart example
#' k <- ggplot(mpg, aes(x = manufacturer, fill = class))
#' k + geom_bar()
#' # Use scales to change aesthetics defaults
#' k + geom_bar() + scale_fill_brewer()
#' k + geom_bar() + scale_fill_grey()
#'
#' # To change plot order of class varible
#' # use factor() to change order of levels
#' mpg$class <- factor(mpg$class, levels = c("midsize", "minivan",
#' "suv", "compact", "2seater", "subcompact", "pickup"))
#' m <- ggplot(mpg, aes(x = manufacturer, fill = class))
#' m + geom_bar()
#' }
geom_bar <- function (mapping = NULL, data = NULL, stat = "bin",
  position = "stack", show_guide = NA, inherit.aes = TRUE, ...)
{
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomBar,
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
GeomBar <- ggproto("GeomBar", Geom,
  default_aes = aes(colour = NA, fill = "grey20", size = 0.5, linetype = 1,
                    weight = 1, alpha = NA),

  required_aes = c("x"),

  reparameterise = function(df, params) {
    df$width <- df$width %||%
      params$width %||% (resolution(df$x, FALSE) * 0.9)
    transform(df,
      ymin = pmin(y, 0), ymax = pmax(y, 0),
      xmin = x - width / 2, xmax = x + width / 2, width = NULL
    )
  },

  draw_groups = function(data, scales, coordinates, ...) {
    GeomRect$draw_groups(data, scales, coordinates, ...)
  },

  draw_key = draw_key_polygon
)
