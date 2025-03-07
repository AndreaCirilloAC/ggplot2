% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/geom-path-step.r
\name{geom_step}
\alias{geom_step}
\title{Connect observations by stairs.}
\usage{
geom_step(mapping = NULL, data = NULL, stat = "identity",
  position = "identity", direction = "hv", show_guide = NA,
  inherit.aes = TRUE, ...)
}
\arguments{
\item{mapping}{The aesthetic mapping, usually constructed with
\code{\link{aes}} or \code{\link{aes_string}}. Only needs to be set
at the layer level if you are overriding the plot defaults.}

\item{data}{A data frame. If specified, overrides the default data frame
defined at the top level of the plot.}

\item{stat}{The statistical transformation to use on the data for this
layer, as a string.}

\item{position}{Postion adjustment, either as a string, or the result of
a call to a position adjustment function.}

\item{direction}{direction of stairs: 'vh' for vertical then horizontal, or
'hv' for horizontal then vertical}

\item{show_guide}{logical. Should this layer be included in the legends?
\code{NA}, the default, includes if any aesthetics are mapped.
\code{FALSE} never includes, and \code{TRUE} always includes.}

\item{inherit.aes}{If \code{FALSE}, overrides the default aesthetics,
rather than combining with them. This is most useful for helper functions
that define both data and aesthetics and shouldn't inherit behaviour from
the default plot specification, e.g. \code{\link{borders}}.}

\item{...}{other arguments passed on to \code{\link{layer}}. There are
  three types of arguments you can use here:

  \itemize{
  \item Aesthetics: to set an aesthetic to a fixed value, like
     \code{color = "red"} or \code{size = 3}.
  \item Other arguments to the layer, for example you override the
    default \code{stat} associated with the layer.
  \item Other arguments passed on to the stat.
  }}
}
\description{
Connect observations by stairs.
}
\section{Aesthetics}{

\Sexpr[results=rd,stage=build]{ggplot2:::rd_aesthetics("geom", "step")}
}
\examples{
# Simple quantiles/ECDF from examples(plot)
set.seed(1492)
df <- data.frame(
  x = sort(rnorm(47))
)
ggplot(df, aes(seq_along(x), x)) + geom_step()

# Steps go horizontally, then vertically (default)
ggplot(df, aes(seq_along(x), x)) + geom_step(direction = "hv")
plot(df$x, type = "s")
# Steps go vertically, then horizontally
ggplot(df, aes(seq_along(x), x)) + geom_step(direction = "vh")
plot(df$x, type = "S")

# Also works with other aesthetics
df <- data.frame(
  x = sort(rnorm(50)),
  trt = sample(c("a", "b"), 50, rep = TRUE)
)
ggplot(df, aes(seq_along(x), x)) + geom_step(aes(colour = trt))
}

