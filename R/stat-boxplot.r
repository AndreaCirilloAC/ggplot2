#' @rdname geom_boxplot
#' @param coef length of the whiskers as multiple of IQR.  Defaults to 1.5
#' @param na.rm If \code{FALSE} (the default), removes missing values with
#'    a warning.  If \code{TRUE} silently removes missing values.
#' @inheritParams stat_identity
#' @return A data frame with additional columns:
#'   \item{width}{width of boxplot}
#'   \item{ymin}{lower whisker = smallest observation greater than or equal to lower hinge - 1.5 * IQR}
#'   \item{lower}{lower hinge, 25\% quantile}
#'   \item{notchlower}{lower edge of notch = median - 1.58 * IQR / sqrt(n)}
#'   \item{middle}{median, 50\% quantile}
#'   \item{notchupper}{upper edge of notch = median + 1.58 * IQR / sqrt(n)}
#'   \item{upper}{upper hinge, 75\% quantile}
#'   \item{ymax}{upper whisker = largest observation less than or equal to upper hinge + 1.5 * IQR}
#' @export
stat_boxplot <- function(mapping = NULL, data = NULL, geom = "boxplot",
  position = "dodge", na.rm = FALSE, coef = 1.5, show_guide = NA,
  inherit.aes = TRUE, ...)
{
  layer(
    data = data,
    mapping = mapping,
    stat = StatBoxplot,
    geom = geom,
    position = position,
    show_guide = show_guide,
    inherit.aes = inherit.aes,
    stat_params = list(
      na.rm = na.rm,
      coef = coef
    ),
    params = list(...)
  )
}


#' @rdname ggplot2-ggproto
#' @format NULL
#' @usage NULL
#' @export
StatBoxplot <- ggproto("StatBoxplot", Stat,
  required_aes = c("x", "y"),

  calculate_groups = function(self, super, data, na.rm = FALSE, width = NULL,
    ...)
  {
    data <- remove_missing(data, na.rm, c("x", "y", "weight"), name="stat_boxplot",
      finite = TRUE)
    data$weight <- data$weight %||% 1
    width <- width %||%  resolution(data$x) * 0.75

    super$calculate_groups(self, data, na.rm = na.rm, width = width, ...)
  },

  calculate = function(data, scales, width = NULL, na.rm = FALSE, coef = 1.5, ...) {
    qs <- c(0, 0.25, 0.5, 0.75, 1)
    if (length(unique(data$weight)) != 1) {
      mod <- quantreg::rq(y ~ 1, weights = weight, data = data, tau = qs)
      stats <- as.numeric(stats::coef(mod))
    } else {
      stats <- as.numeric(stats::quantile(data$y, qs))
    }
    names(stats) <- c("ymin", "lower", "middle", "upper", "ymax")
    iqr <- diff(stats[c(2, 4)])

    outliers <- data$y < (stats[2] - coef * iqr) | data$y > (stats[4] + coef * iqr)
    if (any(outliers)) {
      stats[c(1, 5)] <- range(c(stats[2:4], data$y[!outliers]), na.rm = TRUE)
    }

    if (length(unique(data$x)) > 1)
      width <- diff(range(data$x)) * 0.9

    df <- as.data.frame(as.list(stats))
    df$outliers <- list(data$y[outliers])

    if (is.null(data$weight)) {
      n <- sum(!is.na(data$y))
    } else {
      # Sum up weights for non-NA positions of y and weight
      n <- sum(data$weight[!is.na(data$y) & !is.na(data$weight)])
    }

    df$notchupper <- df$middle + 1.58 * iqr / sqrt(n)
    df$notchlower <- df$middle - 1.58 * iqr / sqrt(n)

    df$x <- if (is.factor(data$x)) data$x[1] else mean(range(data$x))
    df$width <- width
    df$relvarwidth <- sqrt(n)
    df
  }
)
