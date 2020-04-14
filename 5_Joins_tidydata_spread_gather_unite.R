############################################################
#' Ec294A Lab R Focus Session Notes 
#' Week 5
#' dplyr two-table verbs/joins
#' - mutating joins: inner joins (left, right, full), outer join 
#' - filtering joins: semi_join, anti_join - help diagnose join issues
#' - set operations: union, intersect, setdiff
#' tidy data
#' - tidyr verbs: spread, gather, unite, spread
############################################################
# Join types
# - Mutating joins, 
#     add new variables to one table from matching rows in another.
# - Filtering joins, 
#     filter observations from one table based on whether or not 
#     they match an observation in the other table.
# - Set operations
#     combine observations in the data sets as if they were set 
#     elements.
############################################################
library(dplyr)
# some fake data
patients <- data.frame(id = 1:10, age = round(runif(10,55,60)))
visits <- data.frame(id = rep(1:8, each=3), visit = rep(1:3), outcome = round(runif(24,50,160)))
# base R merge
merged <- merge(patients, visits, by="id")
patients
visits
merged
dim(merged)
# base R merge with all option 
all <- merge(patients, visits, by="id", all=TRUE)
all
dim(all) # two more rows from patients 9 and 10 with no visits/outcomes
# dplyr::left_join 
#     include all observations from the LEFT data, drop those from RIGHT
#     without a match in the left
lj <- left_join(patients, visits)
patients
visits
lj
dim(lj)
identical(all, lj)
# dplyr::right_join 
#     include all observations from the RIGHT data, drop those from LEFT
#     without a match in the right
rj <- right_join(patients, visits)
patients
visits
rj
dim(rj)
dim(merged)
identical(merged, rj)
# add a few patients to "visits" that are not in patients to demonstrate
# rbind is how we "append" 
# full_join
newvisits <- data.frame(id = rep(12:14), visit = rep(1,3), outcome = round(runif(3, 50, 160)))
visits2 <- rbind(visits, newvisits)
dim(lj <- left_join(patients, visits2))
dim(rj <- right_join(patients, visits2))
dim(fj <- full_join(patients, visits2))
# The left, right and full joins are collectively know as outer joins. 
# When a row doesn’t match in an outer join, the new variables are filled in with missing values.
lj
rj
fj
ljcc <- lj[complete.cases(lj), ] 
rjcc <- lj[complete.cases(rj), ]
fjcc <- lj[complete.cases(fj), ]
ljcc
rjcc
fjcc
identical(ljcc, rjcc)
identical(rjcc, fjcc)
# complete.cases evaluates to true for observations without any NAs
# left_join is probably the most used. we often find ourselves with one "main" dataset,using
# other sets to supplement our main dataset. left_join ensures we don't lose obs in the 
# main dataset
# Inner join only includes observations that match in both x and y
# Inner join drops any observations which do not show up in BOTH datasets
ij <- inner_join(patients, visits2)
identical(ij, fjcc) # same as any outer join complete case
# note: how do left_join(x,y) and right_join(y,x) differ? 
# order  
df1 <- data.frame(a = 1:3, b = 4:6)
df2 <- data.frame(a = 1:3, c = 8:10)
lj <- left_join(df1, df2)
rj <- right_join(df2, df1)
# need to watch out for non-unique merge variables 
df1 <- data_frame(x = 1:3, score = c(90, 50, 30))
df2 <- data_frame(x = c(1, 1, 2, 2, 4, 4), z = c("SD", "LA", "SD", "LA", "SF", "SD"))
df1
df2 
df3 <- left_join(df1, df2)
df3
# if merge var is not unique, you will end up with 'duplicates' 
# the join will add all possible combos of the matching obs
# this may not be what you want, be careful.
# Note: coercion coerces to most flexible type
# logicals will be coerced to integers 
# factors and numerics often coerced to strings
# you'll get a warning if info may be lost
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Filtering Joins
# which filter observations from one table based on whether 
#  or not they match an observation in the other table.
# Two types of filtering joins
# - semi_join(x, y) keeps all observations in x that have a match in y.
# - anti_join(x, y) drops all observations in x that have a match in y.
semi_join(df1, df2) # 3 isn't in df2 
anti_join(df1, df2) # 3 isn't in df2 
semi_join(df2, df1) # 4 isn't in df1
anti_join(df2, df1) # 4 isn't in df1
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# SET OPERATIONS
# combine the observations in the data sets as if they were set elements.
# - intersect(x, y): return only observations in both x and y
# - union(x, y): return unique observations in x and y
# - setdiff(x, y): return observations in x, but not in y.
df1 <- data_frame(x = c("A", "B", "C"), y = 1:3)
df2 <- data_frame(x = c("B", "C", "D"), y = 2:4)
# intersect - only observations in both x and y
df1;df2
intersect(df1, df2)
# union - unique observations in x and y
union(df1, df2)
# setdiff() - observations in x, but not in y.
setdiff(df1,df2)
setdiff(df2,df1)
# bind_cols()
df1 <- data_frame(x = 1:2, y = c("A","B"))
df2 <- data_frame(x = 1:2, y = c("C","D"))
df1; df2
bind_cols(df1, df2)
# bind_rows()
df1 <- data.frame(x1 = 1:3, x2 = LETTERS[1:3])
df2 <- data.frame(x1 = 5:7, x3 = LETTERS[5:7])
bind_rows(df1, df2)
#' nycflights13 contains info about flights out of NYC in 2013
#' it also includes a number of other useful datasets with info
#' that may be correlated with delays.
#' 
# flights:all flights that departed from NYC (e.g. EWR, JFK and LGA) in 2013: 
#         336,776 obs x 19 vars
# weather: hourly meterological data for each airport 26,130 x 15 vars
# planes: construction information about each physical plane 3,322 obs x 9 vars
# airports: airport names and locations 1,458 obs x 8 vars
# airlines: translation between two letter carrier codes and names 16 x 2 vars
library("nycflights13") 
flights # obs are single flights, with some stats
f2 <- flights %>% select(year:day, hour, origin, dest, tailnum, carrier)
str(f2)
dim(f2) # 8 vars now 
dim(airlines)
# grab the airline name from airlines df, finds common variable to merge
withlinenames <- left_join(f2, airlines)
dim(withlinenames)
# note: no "by" argument given, joins by all shared columns
# in this case, by carrier (one shared column)
names(f2) %in% names(airlines)
names(f2)[which(names(f2) %in% names(airlines))]
# join by all shared columns: year, month, day, hour, origin
weather
f3 <- left_join(f2, weather) # found five shared columns
names(f2) %in% names(weather)
names(f2)[which(names(f2) %in% names(weather))]
dim(f2)
dim(weather)
dim(f3) 
# f2: 8 vars - 5 merge vars = 3 vars unique to f2  
# weather: 15 vars - 5 merge vars = 10 vars unique to weather
# f3: 3 + 10 + 5 merge vars = 18 vars
# now flights and weather info merged into one tibble
# join by one column
names(planes)[which(names(planes) %in% names(f3))]
f4 <- left_join(f3, planes, by = "tailnum")
# join ONLY BY tailnum
# year in planes dataset refers to year of construction while
# year in flights dataset refers to year of flight (all 2013)
# join() creates new variable names to resolve ambiguity 
# both years receive new names to prevent accidental reference to old name
# Join by variable name, but name isn't the same in the two datasets
f4
distinct(select(f4, dest))
airports 
distinct(select(airports, faa))
# Use named `by` option if the join variables have diff names
# name on left is the kept name
f5 <- left_join(f4, airports, by = c("dest" = "faa"))
# another possibility, origin name 
f6 <- left_join(f4, airports, by = c("origin" = "faa"))
# These are most useful for diagnosing join mismatches.
# e.g. many flights don’t have a matching tail number in `planes`
# these are all tailnums showing up in flights that are not in planes. 
flights %>% 
  anti_join(planes, by = "tailnum") %>% 
  count(tailnum, sort = TRUE) 
#' tidyr package, see Hadley Wickham's R for Data Science
#' RULES OF TIDY DATA:
#' 1. Each variable has its own column
#' 2. Each observation has its own row
#' 3. Each value has its own cell
library(tidyr)
library(dplyr)
# WHO tuberculosis cases dataset
tb <- read.csv("../data/tb.csv", stringsAsFactors = FALSE) 
View(tb)
#' iso2 is a country code
#' m/f refers to sex
#' numbers in variable columns refer to age ranges
#' e.g. m04 is males aged 0-14. e.g. f1524 are females 15-24
#' numbers are counts of tb cases in this country/demographic category
#' these data has five variables: 
#' - country, year, sex, and age and number of cases. 
# What's "untidy"? 
#' - two vars are correctly in columns (country and year)
#' - actual data are spread out across many columns with different names
#' - two vars (sex and age) are embedded in column names
##############################################################
# gather() - collects data spread across multiple columns into one
# we can use this to deal with the issue that mfage contains both
# gender and age information
##############################################################
tb_g <- gather(tb, key = mfage, value = n, -iso2, -year, na.rm = TRUE)
tb_g <- arrange(tb_g, iso2, year)
tb_g
# same as this code with pipes
tb_g2 <- tb %>%
  gather(mfage, n, -iso2, -year, na.rm = T) %>%
  arrange(iso2, year)
# name key "mfage", gender-age demographic
# name value "n", count of cases in that year/country/demographic
# na.rm = T, removes all missing values, in practice find out why it's missing
# "-iso2, -year" says "gather all but iso2 and year"
# tricky syntax but fast and effective result
##############################################################
# separate() - pulls apart one column into multiple columns
# we can use this to deal with the issue that mfage contains both
# gender and age information
##############################################################
tb_s <- separate(tb_g,
                 col = mfage, # column to separate
                 into = c("sex", "age_range"), # name of new column(s)
                 sep = 1 # separator, numeric index position to begin split
                 )
tb_s
# equivalent to this code using the pipe operator
tb_s <- tb_g %>%
  separate(
    col = mfage, # column to separate
    into = c("sex", "age_range"), # name of new column(s)
    sep = 1 # separator, numeric index position to begin split
  )
tb_s
# more straightening up
tbf <- tb_s %>%
  rename(country = iso2, cases = n) %>%
  arrange(country, year, sex, age_range)
tbf
###################################################################
# spread() - opposite of gather
# use to tidy when a single observation is scattered across multiple rows
###################################################################
df <- data.frame(
  id     = rep(1:11, 2) ,
  edinc = c(rep("educ", 11), rep("inc", 11)),             
  entry    = c(
    round(runif(n = 11, 12, 20)),
    round(rnorm(n = 11, mean = 90000, sd = 10000)))
) 
df <- df %>%
  arrange(id, edinc)
df
df <- df %>% 
  spread(
    key = edinc,
    value = entry
  )
df
################# reminder of how to gather ##################
#### you wouldn't want to do this, but good syntax reminder ##
#### can gather to undo our spread ###########################
untidy <- df %>% 
  gather(
  key = edinc,      # Names of key columns 
  value = entry,    # Names of value entry columns 
  ... = -id           # "all but year" - Specification of columns to gather.
) %>% 
  arrange(id, edinc)
untidy
##############################################################
# unite() - opposite of separate
# combine multiple columns into a single column 
# (not as useful as separate), undo our separate from before
##############################################################
# you wouldn't want to do this, but good syntax reminder #####
?unite
tb_s
tb_u <- tb_s %>%
  unite(
    col = mfage, 
    ... = sex, age_range,
    sep = ""
  )
tb_u
tb_u2 <- tb_s %>%
  unite(
    col = mfage, 
    ... = sex, age_range,
    sep = "/"
  )
tb_u2
##### final code to tidy tb.csv might look like this ######
tb <- read.csv("../data/tb.csv", 
               stringsAsFactors = FALSE) %>%
  tbl_df() %>%
  gather(mfage, n, -iso2, -year, na.rm = T) %>%
  separate(mfage, c("sex", "age"), 1) %>%
  rename(country = iso2, cases = n) %>%
  arrange(country, year, sex, age)
tb
