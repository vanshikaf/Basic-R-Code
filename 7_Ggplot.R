############################################################
#' Ec294A Lab R Focus Session Notes 
#' Week 7
#' - ggplot2
############################################################
# install.packages("ggplot2")
library("ggplot2", lib.loc="X:/Rlibs")
#' grammar of graphics helps map data to visual representations in a 
#' consistent concise way 
mpg # tutorial data frame from ggplot2 package
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))
# engine size (displ) and fuel efficiency (hwy)
#' ggplot() begins the plot,  creates a 'blank' coordinate system 
#' to which you  add layers, first arg is dataset
ggplot(data = mpg) # not very interesting 
#' complete graph by adding layers 
#' geom_point, which we just used, adds a layer of points
#' geom_point is the geom function to make a scatterplot 
g <- ggplot(data = mpg)
g + geom_point(mapping = aes(x = displ, y = hwy))
# efficiency and # of cylinders
g + geom_point(mapping = aes(x = hwy, y = cyl))
# class (categorical), drivetrain (categorical)
g + geom_point(aes(x = class, y = drv)) # poor choice of viz
#' wouldn't typically use the above syntax, but isolating the parts demonstrates
#' 'coordinate system' and 'layer'
#' BASIC TEMPLATE FOR GRAPH
#' ggplot(data = <DATA>) +
#'   <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))
########## MAPPINGS / AESTHETICS  #########
# what's a mapping?
# you can add a third variable to a 2d scatterplot by mapping it 
# to an 'aesthetic': visual property of the objects in the plot
# aesthetics examples: color, size, shape, transparency
# aes() associates the name of the aesthetic with a variable 
# aes collects all aesthetic mappings, passes collection to layer
ggplot(data = mpg) +
  geom_point(mapping = aes(
    x = displ, 
    y = hwy, 
    color = class))
# notice that x and y variables are the most basic 'aesthetics'
# location is a visual property 
# ggplot assigns levels of aesthetic e.g. color, automatically 
# note: from now, drop explicit names: "data" and "mapping" labels 
# for arguments
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy, color = year))
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy, color = cty))
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy, size = class)) 
# not advised
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy, alpha = class))
# alpha aesthetic controls transparency
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy, shape = class)) 
# 6 max shapes, lost SUV
# ggplot creates labels, legends, and levels (specific colors, shapes) 
# automatically, if you want more control, use argument
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy), color = "blue")
# note difference in syntax
# when setting aesthetics manually arguments are outside aes() call
# manually setting: colors as character strings, size as mm, shapes
# as coded numbers for shape/color/fill
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy), shape = 2)
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy), size = 1)
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy, shape = class)) +
  scale_shape_manual(values=c(1, 2, 3, 4, 5, 6, 7))
# we can add additional variable with aesthestics as above, 
# or we can use facets
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy, color = drv))
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy)) +
  facet_wrap(~ drv, nrow = 1)
# first arg of facet_wrap is a discrete var from dataset as formula 
f <- ~ drv
class(f) # formula object
# why formula? consistent with facet_grid
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy, color = drv))
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy)) + 
  facet_grid(drv ~ cyl) 
# facet vs aesthetic 
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy, color = class))
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy)) +
  facet_wrap(~ class, nrow = 2)
########## GEOMS #########
# geom is the geometrical object a plot uses to represent data
# ex. bar, line, boxplot. scatter=point 
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy))
ggplot(mpg) +
  geom_smooth(aes(x = displ, y = hwy))
ggplot(mpg) +
  geom_smooth(aes(x = displ, y = hwy, linetype = drv))
# available aesthetics depend on geoms 
ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy)) + 
  geom_smooth(aes(x = displ, y = hwy, linetype = drv))
# colors are usually easier than shapes in exploration phase
ggplot(mpg) +
  geom_point(
    mapping = aes(x = displ, y = hwy, color = drv)) + 
  geom_smooth(
    mapping = aes(x = displ, y = hwy, color = drv))
# can simplify syntax
ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point() + 
  geom_smooth()
# mappings can be local to a layer (e.g. geom) or global to plot
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) + 
  geom_smooth()
# statistical layers
diamonds # 54,000 diamonds, plot, carat, color, clarity, cut 
ggplot(diamonds) +
  geom_bar(aes(x = cut))
# note: the y-axis var is not a variable in diamonds
# some graphs use raw values (scatterplots), others calculate new
# values to plot
# bar charts, histograms bin your data and plot bin counts
# smoothers fit a model to data
# boxplots computer summary of the distribution
# to do these things, you need a "statistical transformation", stat()
?geom_bar
# geom_bar uses stat_count
# see "computed variables", two new variables 
table(diamonds$cut)
ggplot(diamonds) +
  stat_count(aes(x = cut))
# can use "geom_bar" (a geom) and stat_count(a stat) interchangebly
# every geom has a default stat, every stat has a default geom
# can use geoms without worrying about the statistical transformation
# vars surrounded by double dot are returned by a stat transformation
# of the original data set. 
ggplot(diamonds) +
  geom_bar(
    aes(x = cut, y = ..prop.., group = 1)
  )
ggplot(diamonds) +
  geom_bar(aes(x = cut, color = cut))
ggplot(diamonds) +
  geom_bar(aes(x = cut, fill = cut))
ggplot(diamonds) +
  geom_bar(aes(x = cut, fill = clarity))
# Another example of geom/stat 
d <- ggplot(diamonds,
            aes(x=carat, y=price))
d
d + geom_point() 
?geom_point # stat is "identity" 
d + geom_point(aes(color = clarity)) 
d + geom_point(aes(color = carat)) 
############### Geoms 
#' geometric shape of the elements of the plot
#'   (summarized nicely by simple visuals)
#' e.g. 
#' basic: point, line, bar
#' composites: boxplot, pointrange 
#' statistic: histogram, smooth, density
############### Statistics
#  values represented in the plot are often stat transf of data
# for example: 
# - point: identity statistic
# - bar: mean, or median statistic
# - histogram: binned count
p <- ggplot(diamonds, aes(x=price))
# another ex: geom_histogram and stat_bin can be used interchangebly
p + geom_histogram()
p + stat_bin()
p + stat_bin(geom="area")
p + stat_bin(geom="point")
p + stat_bin(geom="line")
p + geom_histogram(aes(fill = clarity))
p + geom_histogram(aes(y = ..density..))
# recall ..<x>.. refers to computed variables created by stat()
# Some stats create new variables that you can then refer to in the geom
?geom_histogram
# see "Computed variables"
# - count, density, ncount, ndensity
p <- ggplot(diamonds, aes(x=price)) + geom_histogram()
p + geom_histogram(aes(fill = ..count..))
p + geom_histogram(aes(y = ..density..))  # scaled to integrate to 1
p + geom_histogram(aes(y = ..ncount..))
p + geom_histogram(aes(y = ..ndensity..)) # scaled to max of 1
table(mpg$class) # types of cars in the data 
ggplot(mpg, aes(class, hwy)) +
  stat_summary(fun.y = mean, geom = "bar")
ggplot(mpg, aes(class, hwy)) +
  geom_boxplot()
# back to geom_bar...
ggplot(diamonds) +
  geom_bar(aes(x = cut, fill = clarity))
# now each color reps a cut/clarity combo 
# stacked bars due to default position adjustment in position argument 
####### POSITIONS #########
ggplot(diamonds, aes(x = cut, fill = clarity)) +
  geom_bar(position = "stack")
ggplot(diamonds, aes(x = cut, fill = clarity)) +
  geom_bar(alpha = 1/5, position = "identity")
ggplot(diamonds) +
  geom_bar(aes(x = cut, fill = clarity), position = "fill")
ggplot(diamonds) +
  geom_bar(aes(x = cut, fill = clarity), position = "dodge")
# 126 points, but 234 observations. overplotting. solve w/ jitter
ggplot(data = mpg) +
  geom_point(
    aes(x = displ, y = hwy)
  )
# use jitter position 
ggplot(data = mpg) +
  geom_point(
    aes(x = displ, y = hwy),
    position = "jitter"
  )
# adds some randomness. geom_jitter is another way of calling
ggplot(data = mpg) +
  geom_jitter(
    aes(x = displ, y = hwy)
  )
###### COORDINATE SYSTEMS ############
# Cartesian x, y most common
# polar for pie charts
ggplot(mpg, aes(x = class, y = hwy)) + 
  geom_boxplot()
ggplot(mpg, aes(x = class, y = hwy)) + 
  geom_boxplot() +
  coord_flip()
ggplot(mpg, aes(x = class)) + 
  geom_bar() 
ggplot(mpg, aes(x = class)) + 
  geom_bar() +
  coord_polar()
ggplot(mpg, aes(x = class, fill = class)) + 
  geom_bar() +
  coord_polar() # prettier? less printable, it's ok for exploration 
ggplot(mpg, aes(x = cty, y = hwy)) + 
  geom_point() +
  geom_abline() + 
  coord_fixed() 
############################
#' ANOTHER TEMPLATE
#' 
#' ggplot(data = <DATA>) +
#'   <GEOM_FUNCTION>(
#'   mapping = aes(<MAPPINGS>),
#'   stat = <STAT>,
#'   position = <POSITION>
#'   ) +
#'   <COORDINATE_FUNCTION> +
#'   <FACET FUNCTION> 
#'   
#' You rarely specify all of these because defaults exist for
#' everything except data/mappings/geom (basic template from above)
ggplot(mpg,
       aes(x = displ, y = hwy)) +
  layer(
    geom = "point", 
    stat = "identity", 
    position = "identity"
  )
# same as, with defaults called in geom_point() 
ggplot(mpg,
       aes(x = displ, y = hwy)) +
  geom_point()
?geom_point
ggplot(diamonds, aes(x=cut, y=depth)) + geom_point()
# why would you use stat vs geom
ggplot(diamonds, aes(x=cut, y=depth)) + 
  stat_summary(
    fun.ymin = min,
    fun.ymax = max,
    fun.y = median
  )
ggplot(mpg, aes(x = hwy)) + 
  geom_histogram() 
ggplot(diamonds) +
  geom_histogram(aes(x=price))
# examples ====================
p <- ggplot(
  data = mpg,
  aes(x = hwy)
) + 
  geom_histogram()
p
# geom: bar
# stat: bin
p <- ggplot(
  data = mpg, 
  aes(x = displ, 
      y = hwy)
)
p <- p + geom_point(aes(color = class))
p
# geom: point
# stat: identity
########### Factors in plots  
ggplot(diamonds,
       aes(x=cut, y=price)) +
  geom_boxplot() # ordered the way you want 
levels(diamonds$cut)
levels(diamonds$cut) <- rev(levels(diamonds$cut)) # can reverse
ggplot(diamonds, aes(x=cut, y=price)) +
    geom_boxplot()
levels(diamonds$cut) <- rev(levels(diamonds$cut))
levels(diamonds$cut) # back to original
 ######### OTHER PARAMETERS
# parameters modify geom and stat defaults 
ggplot(mpg, aes(x=displ, y=hwy)) + 
  geom_point() + 
  stat_smooth(method = lm) # add line from linear model
ggplot(mpg, aes(x=displ, y=hwy)) + 
  geom_point() + 
  stat_smooth(method = loess) # locally weighted 
ggplot(mpg, aes(x=displ, y=hwy)) + 
  geom_point() + 
  stat_smooth() # locally weighted is default
# most common ggplot typos. match parens, + at the end of a line
p <- ggplot(diamonds, aes(x=carat,y=price))
p + geom_point()
# what will each do?
p + geom_point(aes(color = "green")) # oops, messed syntax
# args to aes are variables, previous syntax created new variable
p + geom_point(color = "green") # default colors pretty ugly
############# THEMES ######
library(ggthemes) # themes 
g <- ggplot(diamonds, aes(x = carat, y = price)) +
  geom_point(aes(color = color)) # color is a var in our data
g
g + theme_economist() + scale_color_economist()
g + theme_excel() + scale_color_excel()
g + theme_wsj()
g + theme_tufte()
economics # another dataset from ggplot2 
# http://ggplot2.tidyverse.org/reference/economics.html
g <- ggplot(economics, aes(x=date)) + 
  geom_line(aes(y=psavert)) + 
  labs(title="Personal Savings Rate", 
       subtitle="Data from 'Economics' Dataset in ggplot2", 
       caption="Source: U.S. Bureau of Economic Analysis",
       y="Percent")
g
g + theme_economist() + scale_color_economist()
g + theme_excel() + scale_color_excel()
g + theme_wsj()
g + theme_tufte()
######### MORE EXAMPLES, DATA EXPLORATION #####
load("../data/org_example.RData")
# if you didn't save org_example in your data directory,
# reload it, either from a local .csv or spearot's website
# mydata <- read.dta(file = "https://people.ucsc.edu/~aspearot/Econ_217/org_example.dta")
# note, these examples may take some time to render depending
# on your system's speed, take a sample to save some time 
g <- ggplot(
  sample_n(mydata, 40000), 
  aes(
    x = age, 
    y = rw,
    color = educ
  )
) + geom_point(alpha = 0.2)
g
?stat_smooth
g + stat_smooth(
  aes(color = educ)
)
g + stat_smooth(
  aes(color = as.factor(female))
)
library(dplyr) # sometimes we manipulate data for graphing purposes
ggplot(
  data = (
    mydata %>%
      mutate(
        sex = as.factor(ifelse(female, "Female", "Male"))
      )
  ),
  aes(
    x = age, 
    y = rw,
    group = interaction(sex, educ),
    color = interaction(sex, educ)
  )
) + stat_smooth(span = 1) # larger spans produce smoother lines
