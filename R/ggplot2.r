#' ggplot2.
#'
#' @name ggplot2
#' @docType package
#' @import scales grid gtable
#' @importFrom plyr defaults
#' @importFrom stats setNames
NULL

#' Prices of 50,000 round cut diamonds
#'
#' A dataset containing the prices and other attributes of almost 54,000
#'  diamonds. The variables are as follows:
#'
#' @format A data frame with 53940 rows and 10 variables:
#' \itemize{
#'   \item price: price in US dollars (\$326--\$18,823)
#'   \item carat: weight of the diamond (0.2--5.01)
#'   \item cut: quality of the cut (Fair, Good, Very Good, Premium, Ideal)
#'   \item color: diamond colour, from J (worst) to D (best)
#'   \item clarity: a measurement of how clear the diamond is
#'      (I1 (worst), SI1, SI2, VS1, VS2, VVS1, VVS2, IF (best))
#'   \item x: length in mm (0--10.74)
#'   \item y: width in mm (0--58.9)
#'   \item z: depth in mm (0--31.8)
#'   \item depth: total depth percentage = z / mean(x, y) = 2 * z / (x + y) (43--79)
#'   \item table: width of top of diamond relative to widest point (43--95)
#' }
"diamonds"


#' US economic time series.
#'
#' This dataset was produced from US economic time series data available from
#' \url{http://research.stlouisfed.org/fred2}.
#'
#' @format A data frame with 478 rows and 6 variables
#' \itemize{
#'   \item date.  Month of data collection
#'   \item psavert, personal savings rate,
#'     \url{http://research.stlouisfed.org/fred2/series/PSAVERT/}
#'   \item pce, personal consumption expenditures, in billions of dollars,
#'     \url{http://research.stlouisfed.org/fred2/series/PCE}
#'   \item unemploy, number of unemployed in thousands,
#'     \url{http://research.stlouisfed.org/fred2/series/UNEMPLOY}
#'   \item uempmed, median duration of unemployment, in week,
#'     \url{http://research.stlouisfed.org/fred2/series/UEMPMED}
#'   \item pop, total population, in thousands,
#'    \url{http://research.stlouisfed.org/fred2/series/POP}
#' }
#'
"economics"

#' Midwest demographics.
#'
#' Demographic information of midwest counties
#'
#' @format A data frame with 437 rows and 28 variables
#' \itemize{
#'  \item PID
#'  \item county
#'  \item state
#'  \item area
#'  \item poptotal.  Total population
#'  \item popdensity. Population density
#'  \item popwhite.  Number of whites.
#'  \item popblack.  Number of blacks.
#'  \item popamerindian.  Number of American Indians.
#'  \item popasian.  Number of Asians.
#'  \item popother.  Number of other races.
#'  \item percwhite.  Percent white.
#'  \item percblack.  Percent black.
#'  \item percamerindan.  Percent American Indian.
#'  \item percasian. Percent Asian.
#'  \item percother. Percent other races.
#'  \item popadults.  Number of adults.
#'  \item perchsd.
#'  \item percollege.  Percent college educated.
#'  \item percprof.  Percent profession.
#'  \item poppovertyknown.
#'  \item percpovertyknown
#'  \item percbelowpoverty
#'  \item percchildbelowpovert
#'  \item percadultpoverty
#'  \item percelderlypoverty
#'  \item inmetro.  In a metro area.
#'  \item category'
#' }
#'
"midwest"


#' Fuel economy data from 1999 and 2008 for 38 popular models of car
#'
#' This dataset contains a subset of the fuel economy data that the EPA makes
#' available on \url{http://fueleconomy.gov}. It contains only models which
#' had a new release every year between 1999 and 2008 - this was used as a
#' proxy for the popularity of the car.
#'
#' @format A data frame with 234 rows and 11 variables
#' \itemize{
#'   \item manufacturer.
#'   \item model.
#'   \item displ. engine displacement, in litres
#'   \item year.
#'   \item cyl. number of cylinders
#'   \item trans. type of transmission
#'   \item drv. f = front-wheel drive, r = rear wheel drive, 4 = 4wd
#'   \item cty. city miles per gallon
#'   \item hwy. highway miles per gallon
#'   \item fl.
#'   \item class.
#' }
"mpg"

#' An updated and expanded version of the mammals sleep dataset.
#'
#' This is an updated and expanded version of the mammals sleep dataset.
#' Updated sleep times and weights were taken from V. M. Savage and G. B.
#' West. A quantitative, theoretical framework for understanding mammalian
#' sleep. Proceedings of the National Academy of Sciences, 104 (3):1051-1056,
#' 2007.
#'
#' Additional variables order, conservation status and vore were added from
#' wikipedia.
#'
#' @format A data frame with 83 rows and 11 variables
#' \itemize{
#'   \item name. common name
#'   \item genus.
#'   \item vore. carnivore, omnivore or herbivore?
#'   \item order.
#'   \item conservation. the conservation status of the animal
#'   \item sleep\_total. total amount of sleep, in hours
#'   \item sleep\_rem. rem sleep, in hours
#'   \item sleep\_cycle. length of sleep cycle, in hours
#'   \item awake. amount of time spent awake, in hours
#'   \item brainwt. brain weight in kilograms
#'   \item bodywt. body weight in kilograms
#' }
"msleep"

#' Terms of 10 presidents from Eisenhower to Bush W.
#'
#' The names of each president, the start and end date of their term, and
#' their party of 10 US presidents from Eisenhower to Bush W.
#'
#' @format A data frame with 10 rows and 4 variables
"presidential"

#' Vector field of seal movements.
#'
#' This vector field was produced from the data described in Brillinger, D.R.,
#' Preisler, H.K., Ager, A.A. and Kie, J.G. "An exploratory data analysis
#' (EDA) of the paths of moving animals". J. Statistical Planning and
#' Inference 122 (2004), 43-63, using the methods of Brillinger, D.R.,
#' "Learning a potential function from a trajectory", Signal Processing
#' Letters. December (2007).
#'
#' @format A data frame with 1155 rows and 4 variables
#' @references \url{http://www.stat.berkeley.edu/~brill/Papers/jspifinal.pdf}
"seals"

#' 2d density estimate of Old Faithful data
#'
#' A 2d density estimate of the waiting and eruptions variables data
#' \link{faithful}.
#'
#' @format A data frame with 5,625 observations and 3 variables.
"faithfuld"
