##########################################################
#' Ec294A Lab R Focus Session Notes 
#' Week 1 
#' 
#' Anything after a hashtag is a comment and will not be evaluated
#' No multi-line commenting in R but an apostrophe after a hashtag
#' will automatically generate another hashtag in the next line
#'
#' - Installing R and RStudio on your personal machines 
#' - Accessing R and RStudio on the Social Sciences Stats Server
#' - Invoking R and RStudio
#' - Everything in R is an object
#' - Keyboard shortcuts: "alt"+"-" generates " <- ", use up arrow
#'      to cycle through previous commands in interactive mode, 
#'      use tab to autocomplete
#' - Everything in R is an object      
#' - Object names cannot start with a number or include reserved characters
#' - Object names CAN include periods; 
#'      periods have no special meaning unlike in other languages
##########################################################

x <- 5  # - Assignment operator <- read as "gets"
x # echo to console 
y <- 10
y / x # do arithmetic operations 
z <- y/x # note new object in environment
z <- c(100, 2, 1, 4)
sort(z)
mean(z) # pass arguments into functions
ls() # listing the objects in the session doesn't require arguments
rm(z) # remove an object
print("Hello world!") # we can put this in our first script 
?mean # question mark gets help on functions 
??histogram # two question marks looks for all functions mentioning term
example(seq) # show examples of a function
x <- seq(1, 50) 
x <- seq(1, 50, by=2)
x <- seq(1, 50, length=100)
x <- seq(from=1, to=50) # don't need to name arguments but you can
x
x <- seq(to=50, from=1) # if you used named arguments pass them in any order
x # number in brackets in console output gives index to 1st item on given line 
# mydata <- read.dta(file="https://people.ucsc.edu/~aspearot/Econ_217/org_example.dta")  # this will generate an error
# need to download package holding read.dta function if we don't have it already
# install.packages("foreign") # only need to do this once ever on a machine
# mydata <- read.dta(file="https://people.ucsc.edu/~aspearot/Econ_217/org_example.dta")  # still an error
# need to load it into current R session
library(foreign) # do this everytime you need a package 
mydata <- read.dta(file="https://people.ucsc.edu/~aspearot/Econ_217/org_example.dta")
# loading a dataset with >1 mil obs may take some time
# ignore a couple of warnings resulting from format of the STATA dataset
View(mydata) # or click on mydata in Environment
length(mydata)
names(mydata) 
dim(mydata) # dimensions 
str(mydata) # structure of this object, dataframe differs from matrix
# mean(age) # this will generate an error
mean(mydata$age) # need to tell R where to find age, it's part of mydata
summary(mydata$age)
summary(mydata) # we can do summary on different types of objects
hist(mydata$age)
table(mydata$year)
table(mydata$lfstat)
table(mydata$year,mydata$lfstat)
# can you figure out how to create a new data.frame with only the 2013 obs?
my2013data <- subset(mydata,year==2013)
dim(my2013data) # looks good, nobs as expected
my2013CAdata <- subset(mydata, (year==2013 & state=="CA"))
dim(my2013CAdata)
plot(mydata$age, mydata$rw)
myreg <- lm(formula = rw ~ age, data=mydata)
summary(myreg) # functions can act on different types of objects
# we saw summary on a variable, a data.frame, and a linear model 
# HW: finish all 8 modules of http://tryr.codeschool.com/ 
