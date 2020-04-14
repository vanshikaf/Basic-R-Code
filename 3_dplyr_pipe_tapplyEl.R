##########################################################
#' Ec294A Lab R Focus Session Notes 
#' Week 3
#' Manipulating Data
#' - Base R vs dplyr functions: rename(), mutate(), filter(), select(), arrange()
#' - the %>% "pipe" operator (from magrittr package, installed with dplyr) 
#' Saving and loading R data.frames
#' Apply Family of Functions
#' - tapply first (also: lapply, sapply, ...)  
###########################################################
toydf <- data.frame(x=11:15, x2=rnorm(5), x3=rnorm(5, mean=10), y=rnorm(5, mean=100)) 
toydf
#### Base R: rename column name "y" as "x4 #############
(cn <- colnames(toydf)) # can close expressions in parens to assign and output
cn[cn=="y"] <- "x4"  # find the index of the one we want to replace, and replace with new name
cn[cn=="x"] <- "x1"  # find the index of the one we want to replace, and replace with new name
colnames(toydf) <- cn # put new name vector into colnames attribute
colnames(toydf)
#### Base R: select columns ####################
toydf$x1      # all do the same thing
toydf[,1]     # all do the same thing
toydf[,"x1"]  # all do the same thing
toydf[,c("x2","x3")] # multiple columns
#### Base R: select rows #######
toydf[1,]
toydf[1:3,]
toydf[ (toydf$x2 < 0) | (toydf$x4 > 100), ]
#### Base R: select rows, columns #######
toydf[ (toydf$x2 < 0) | (toydf$x4 > 100), c("x2", "x4")]
#### Base R: add columns to the data ##################
toydf$newcol <-  toydf$x1 * 2
toydf$newx <-  toydf$x1/toydf$x2
toydf
#### Base R: grab columns with names matching criteria #####
cols <- grep("x", names(toydf)) # returns indices where name matches criteria
cols
toydf[ ,cols]
toydf[ ,grep("x", names(toydf))] # in one step, but we don't want newx
toydf[ ,grep("^x", names(toydf))] # "begins with x" 
toydf[ ,grep("4$", names(toydf))] # "ends with 4" 
toydf[ ,grep("3$|4$", names(toydf))] # "ends with 3 or 4
#### Base R: remove column #####
toydf
toydf <- toydf[,colnames(toydf)!="newcol"] # grab all columns except
toydf
toydf$newx <- NULL
toydf
#### Base R: ordering columns #####
toydf$newcol = toydf$x2 * 2
cn <- colnames(toydf)
toydf
toydf <- toydf[, c("newcol", cn[cn != "newcol"])] #subset in order you want
#### Base R: ordering rows #####
toydf[order(toydf$x4),]  # sort by x4
toydf[order(toydf$x4, decreasing = TRUE),] # decreasing
toydf[6:10,] <- toydf[1:5,] # copy rows 1-5 to 6-10
toydf[1:10,"x3"] <- 1:10 # new values into x3 to demonstrate sort
toydf
toydf[order(toydf$x2, -toydf$x3),] # increasing x2, decreasing x3
##########################################################
#' 
#' dplyr makes these manipulations more intuitive and readable
#' 
###########################################################
toydf <- data.frame(x=11:15, x2=rnorm(5), x3=rnorm(5, mean=10), y=rnorm(5, mean=100)) 
toydf
######### dplyr: rename column name "y" as "x4 #############
library(dplyr)   # masks tells you functions in new package have same names as old functions
# if you want to use the old ones, use the colon syntax in the function call, e.g. stats::filter 
toydf <- rename(toydf, x4 = y)   # new name equals old name 
toydf
toydf[5] <- rep("LA",5)
toydf
# you try renaming x to x1, V5 to y
toydf <- rename(toydf, x1 = x, y = V5)   # new name equals old name 
toydf
######### dplyr: select columns, pick variables by names ####
select(toydf, x1) # no $/indexing necessary! select knows where to look
select(toydf, x1, x2) # select allows us to grab two variables
select(toydf, c(x1, x2)) # diff syntax
select(toydf, starts_with("x"))
select(toydf, ends_with("x"))
######### dplyr: filter rows, pick observations by values ###
filter(toydf, x2 < 0 | x4 > 100)  # no $/indexing necessary! 
filter(toydf, x2 < 0, x4 > 100)  # if no logical op specified b/w conds, AND is default
filter(toydf, x2 < 0 & x4 > 100)  
######### combine filters and selects #######################
select(filter(toydf, x2 < 0 | x4 > 100), x2, x4) 
#' in R functions are often nested as arguments in other functions
#' to make code more readable without breaking your original data.frame
#' you might make temp objects to store these manipulations, breaking up the 
#' longish function call 
temp <- filter(toydf, x2 < 0 | x4 > 100)
temp <- select(temp, x2, x4)
temp
# the "%>%" (pipe) operator makes these chained manipulations more intuitive
# toydf is piped into filter, the result of the filter is piped into select
# take toydf, filter the rows and select columns x2 and x4 
toydf %>% 
  filter(x2 < 0 | x4 > 100) %>% 
  select(x2, x4)
#### dplyr: create new variables with functions of existing variables ####
toydf <- mutate(toydf, newcol = x1*2, newx = x1/x2)
toydf
#### dplyr: remove columns  ##################
toydf <- select(toydf, -newcol, -newx)
toydf
#### dplyr: order columns  ##################
toydf <- select(toydf, y, everything()) # select in your desired order
toydf
#### dplyr: order rows  ##################
toydf <- arrange(toydf, x4)
toydf
toydf <- arrange(toydf, desc(x4)) # descending x4
toydf
toydf[6:10,] <- toydf[1:5,] # copy rows 1-5 to 6-10
toydf[1:10,"x3"] <- 1:10 # new values into x3 to demonstrate sort
toydf
toydf <- arrange(toydf, x2, desc(x3))  # increasing x2, decreasing x3
toydf
##########################################################
#' saving and loading data.frames 
#' More Base R: cut(), tapply(), aggregate()
#' More dplyr: group_by(), summarize()
###########################################################
library(foreign)
mydata <- read.dta(file = "https://people.ucsc.edu/~aspearot/Econ_217/org_example.dta")
save(mydata, file = "../data/org_example.RData")
ls()
rm(mydata)
load(file = "../data/org_example.RData")
# note: age is top-coded, see
# browseURL("https://cps.ipums.org/cps-action/variables/AGE#codes_section")
# use filter to investigate 
ca2013 <- filter(mydata, year==2013, state=="CA") 
plot(ca2013$age, ca2013$rw)
topcodes <- filter(mydata, age>=80)
table(topcodes$age, topcodes$year)
plot(topcodes$year, topcodes$age) # as we expect
# sometimes we want to make categorical data out of numerical data
# browseURL("https://www.bls.gov/emp/ep_table_303.htm")
# let's make age categories <16, 16-24, 25-54, 55-64, 65+ using cut
mydata$agecat <- cut(mydata$age, breaks=c(0,15,24,54,64,99))
select(mydata, age, agecat)
class(mydata$agecat)
levels(mydata$agecat)
levels(mydata$agecat) <- c("age0-15","age16-24", "age25-54", "age55-64", "age65+")
t <- table(mydata$agecat)
prop.table(t)
save(t, file = "ages_in_data.RData")
rm(t)
load("ages_in_data.RData")
# sometimes we want to make new categories based on categorical data
###### let's group B, H, O into Non-White
prop.table(table(mydata$wbho))
mydata$w_nw <- ifelse(
  test = (mydata$wbho %in% c("Black", "Hispanic", "Other")),
  yes = "Non-White",
  no = "White")
prop.table(table(mydata$w_nw)) # looks good
###### introduce group_by and summarize in dplyr
rw_means <- mydata %>% 
  group_by(educ) %>%
  summarize(rw = mean(rw,na.rm = TRUE))
rw_means
###### apply family of functions: tapply (table apply)
t <- tapply(mydata$rw, mydata$educ, mean, na.rm=TRUE) 
t
##### break down syntax, tapply applies function in FUN to X within each level of INDEX)
tapply(
  X = mydata$rw,
  INDEX = mydata$educ,
  FUN = mean,
  na.rm=TRUE
)
class(t)
tapply(
  X = mydata$rw,
  INDEX = list(mydata$educ, mydata$female, mydata$wbho),
  FUN = mean,
  na.rm=TRUE
)
# using aggregate()
rw_means <- aggregate(
  mydata$rw,
  by = list(
    educ = mydata$educ,
    female = mydata$female,
    wbho = mydata$wbho
  ),
  FUN = mean, 
  na.rm = TRUE
)
###### using dplyr::group_by and summarize
###### summarize collapses data into a single row
rw_summarize <- summarize(mydata, meanrw = mean(rw, na.rm=TRUE))
rw_means2 <- mydata %>% 
  group_by(educ, female, wbho) %>% 
  summarize(rw_mean = mean(rw,na.rm = TRUE)) 
# you don't want NAs? try: 
rw_means2 <- mydata %>% 
  filter(!is.na(educ)) %>%
  group_by(educ, female, wbho) %>% 
  summarize(rw_mean = mean(rw,na.rm = TRUE)) 
# pipes make chaining lots of operations together easy and clear
hrs_means <- mydata %>% 
  filter(!is.na(educ)) %>%
  group_by(educ, female, wbho) %>% 
  summarize(hourslw = mean(hourslw,na.rm = TRUE)) %>%
  arrange(desc(hourslw))
##########################################################
#' dplyr summary
#' 
#' filter() picks observations by values
#' arrange() reorders rows
#' select() picks variables by names
#' mutate() creates new variables with functions of existing variables
#' summarize() collapses many values to a single summary
#' 
#' all can be used with group_by()
#' group_by() changes scope of function from entire dataset to individual groups
#'###########################################################
