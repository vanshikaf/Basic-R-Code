##########################################################
#' Ec294A Lab R Focus Session Notes 
#' Week 4
#' - functions, scope, default arguments
#' - control flow: for loops, while loops, repeat loops, next, break
#' - apply, lapply, sapply, mapply  
#' Back to Manipulating Data 
#' - dplyr functions, more examples 
###########################################################
g <- function(x) {
  return(x+1)
}
g # functions are objects, echo to console 
g(10)
# functions are objects, we can assign them
sumab <- function(a,b) {
  return(a+b)
}
diffab <- function(a,b) {
  return(a-b)
}
f <- sumab # assign functions as objects
f(3,2)
f <- diffab
f(3,2)
# functions are objects, we can pass them as arguments
g <- function(h,a,b) { 
  h(a,b)
}
g(sumab,3,2)  
g(diffab,3,2)
g(function(x,y) return(x*y),2,3) # anonymous functions
# variable scope: local and global variables
rm(list=ls())
w <- 12
f <- function(y) {
 d <- 8
 h <- function() {
   return(d*(w+y))
 }
 return(h())
}
# h  # should give us an error object 'h' not found
# h() is local to f() 
# d is local to f(), but global to h()
# y is local to f(), but global to h()
f(2)
# functions have no side effects, do not change nonlocal variables
ls()
w <- 12
f <- function(y) {
  d <- 8
  w <- w + 1
  y <- y - 2
  print(paste("w is now:",w))
  h <- function() {
    return(d*(w+y))
  }
  return(h())
}
t <- 4
f(t)
w  # doesn't change outside the function, not updated in global environment
# only the copy of w in the local environment to f changed
t  # still t even though t as y changed in the function
mean1 <- function(x){
  sum(x) / length(x)
}
x1 <- rnorm(1000, 0, 1)
mean1(x1)
mean1(rnorm(1000, 1000, 10))
# mean1() # error, no default argument
mean1 <- function(x = rnorm(100)) {  # set a default argument
  sum(x) / length(x)
}
mean1() # no error, no argument reverts to default
mean1(rnorm(1000, 500, 1)) # override default arguement
# weighted mean
meanwt <- function(x, w){
  xw <- x * w # need to be same length 
  sum(xw) / sum(w)
}
meanwt(c(75,72,80), c(25,25,50))
# count the number of negative values in x
negcount <- function(x) {
  k <- 0
  for (n in x) {
    if (n < 0) k <- k+1 
  }
  return(k) # not necessary but useful for clarity
}
set.seed(1)
negcount(rnorm(100))
propneg <- function(x) {
  k <- 0
  for (n in x) {
    if (n < 0) k <- k+1 
  }
  prop <- k/length(x)
  return(prop) # not necessary but useful for clarity
}
propneg(rnorm(100))
# for loop fixed length
for (i in 1:100) {
  print(paste("iteration =", i, "propneg = ", propneg(rnorm(1000))))
}
# can use a while loop to do the same thing
i <- 1
while (i <= 100) {
  print(paste("iteration =", i, "propneg = ", propneg(rnorm(1000))))
  i <- i + 1
}
# can use a repeat loop to do the same thing
i <- 1
repeat {
  print(paste("iteration =", i, "propneg = ", propneg(rnorm(1000))))
  if (i == 100) break;
  i <- i + 1
}
#### nested for loops 
# Create a 10 x 10 matrix 
mymat <- matrix(nrow = 10, ncol = 10)
# For each entry, assign value as rowindex * colindex 
for(i in 1:nrow(mymat)) {
  for(j in 1:ncol(mymat)) {
    mymat[i,j] = i*j
  }
}
mymat
##### next construct, skips the rest of this iteration and goes to the next 
for (i in 1:10) {
  if (i==5) {
    next    
  }
  print(i)
}
##### break construct, skips the rest of the loop
for (i in 1:10) {
  if (i==5) {
    break
  }
  print(i)
}
#### another simple function, default argument 
celsius_to_fahr <- function(degrees_cels) {
  degrees_fahr <- degrees_cels * 9/5 + 32
  return(degrees_fahr) 
}
(fahr <- celsius_to_fahr(20))
#' default arguments
#' function nrmlz: rescales a vector, x, between lbound and ubound
#' default lbound = 0, ubound = 1
nrmlz <- function(x, lbound = 0, ubound = 1) {
  min <- min(x, na.rm = TRUE)
  max <- max(x, na.rm = TRUE)
  rescaled <- (x - min) / (max - min) * (ubound - lbound) + lbound
  return(rescaled)
}
v <- rnorm(10)
nv <- nrmlz(v)
v
nv
nv100 <- nrmlz(v, 100, 200)
nv100
set.seed(1)
# apply (only works on matrices, will coerce data.frames into matrices)
(mymat <- matrix(1:9, nrow = 3))
apply(mymat, 1, sum) # sum margin 1 (rows), same as rowSums
apply(mymat, 2, sum) # sum margin 2 (cols), same as colSums
apply(mymat, 1, mean) # mean of margin 1 (rows)
apply(mymat, 2, mean) # mean of margin 2 (cols)
# lapply and sapply example
mylist <- list(a=matrix(1:9,3), b=1:5, c=matrix(1:4,2), d=2) 
lapply(mylist, sum) # returns a list
sapply(mylist, sum) # returns a vector "simple" apply 
# lapply and sapply, another example
mylist <- list(
  a = rnorm(1000,0,1),
  b = rnorm(1000,10,5),
  c = rnorm(1000,100,10)
)
lapply(mylist,mean)
lapply(mylist,sd)
sapply(mylist,mean)
sapply(mylist,sd)
# mapply (multiple lists)
list1 <- list(a=matrix(1:16,4), b=matrix(1:16,8), c=1:5)
list2 <- list(a=matrix(1:16,4), b=matrix(1:16,8), c=15:1)
?identical
mapply(identical, list1, list2)
# Return list: if you have multiple things to return, use a list container
sumvec <- function(x){
  result <- list(
    mean       = mean(x),
    sd         = sd(x),
    median     = median(x),
    length     = length(x)
  )
}
x <- c(rnorm(1000, mean = 100, sd = 50))
xsum <- sumvec(x)
xsum # returned a list
xsum$mean
xsum$sd
xsum$median
xsum$length
# get() function helps us loop over objects, get means for these vecs
x <- rnorm(10)
y <- rnorm(10,50,10)
x
y
# this does NOT do what we want! 
for (v in c(x,y)){
  print(mean(v))
} 
# pass get() object name in string form, returns object
for (v in c("x","y")){ 
  print(v)
  vec <- get(v)
  print(mean(vec))
} 
##########################################################
#' 
#' more examples using dplyr functions 
#' 
###########################################################
# install.packages("ggplot2")
library(ggplot2)   # just get this for the datasets
# select two columns
str(msleep)
sleepdata <- select(msleep, name, sleep_total)
sleepdata
# select a range of columns names
names(msleep)
sleepdata <- select(msleep, genus:conservation)
sleepdata
# starts_with()
names(msleep)
sleepdata <- select(msleep, starts_with("sl"))
sleepdata
# combine conditions, any of these
sleepdata <- select(msleep, name, starts_with("sl"), starts_with("vo"), awake:brainwt)
sleepdata
# rename newname = oldname
rename(sleepdata, species = name)
# can also rename in a select
sleepdata <- select(msleep, SPECIES = name, a = starts_with("sl"), starts_with("vo"), b = awake:brainwt)
sleepdata
# distinct values, parallel to unique from base R
names(msleep)
unique(msleep$genus)
distinct(select(msleep, genus)) 
# filter 
filter(msleep, sleep_total >= 16)
filter(msleep, vore == "carni")
# comma suggests AND 
filter(msleep, sleep_total >= 16, bodywt >= 1)
# remember in Base R this would require row/column indexing and $ refs
msleep[msleep$sleep_total >= 16 & msleep$bodywt >= 1, ]
filter(msleep, sleep_total >= 16 & bodywt >= 1)
# using %in% can be clearer than writing lots of ORs 
filter(msleep, order %in% c("Perissodactyla", "Primates"))
filter(msleep, vore %in% c("carni",  "omni"))
# OR
filter(msleep, vore == "carni" | vore == "omni") 
# combine multiple with parentheses 
filter(msleep, (vore == "omni" & bodywt > 15) | (vore == "carni" & bodywt > 100))
# slice
# To select rows by position, use slice():
slice(msleep, 1:10)
slice(msleep, seq(1,100,by = 8)) # every 8 entries 
#### %>% pipe operator - funnel results of functions into following functions
sleepdata <- select(msleep, name, sleep_total)
head(sleepdata) # show first 6 entries 
# can combine into one step
head(select(msleep, name, sleep_total))
# both of these versions can get messy quickly
sleepdata <- msleep %>% 
  select(name, sleep_total) %>% 
  head
sleepdata
# arrange, ordering rows
msleep %>% 
  arrange(order) %>% 
  head
msleep %>% 
  select(name, order, sleep_total) %>%
  arrange(order, sleep_total) %>% 
  head
# select, arrange, filter
msleep %>% 
  select(name, order, sleep_total) %>%
  arrange(order, sleep_total) %>% 
  filter(sleep_total >= 16)
## descending order - desc() helper function
msleep %>% 
  select(name, order, sleep_total) %>%
  arrange(order, desc(sleep_total)) %>% 
  filter(sleep_total >= 16)
## '-' sign works for descending sort with numerics
msleep %>% 
  select(name, order, sleep_total) %>%
  arrange(order, -sleep_total) %>% 
  filter(sleep_total >= 16)
msleep %>% 
  select(name, order, sleep_total) %>%
  arrange(desc(order), sleep_total) %>% 
  filter(sleep_total >= 16)
# mutate
msleep %>% 
  mutate(rem_proportion = sleep_rem / sleep_total) %>%
  select(name, sleep_total, sleep_rem, rem_proportion) %>%
  head
# you can add many at once
msleep %>% 
  mutate(
    rem_proportion = sleep_rem / sleep_total, 
    bodywt_grams   = bodywt * 1000
  ) %>%
  select(name:order, sleep_total, sleep_rem, rem_proportion, bodywt, bodywt_grams) %>%
  head(25)
# use transmute if you only want your new variables
msleep %>%
  transmute(
    rem_proportion = sleep_rem / sleep_total,
    bodywt_grams = bodywt * 1000
  )
# summarize, name in collapsed data = summary function 
msleep %>% 
  summarize(sleep_avg = mean(sleep_total))
# summarize a few things at once 
msleep %>% 
  summarize(
    sleep_min    = min(sleep_total),
    sleep_1stQnt = quantile(sleep_total, 0.25),
    sleep_avg    = mean(sleep_total),
    sleep_3rdQnt = quantile(sleep_total, 0.75),
    sleep_max    = max(sleep_total),
    sleep_count  = n()  
  )
## helper functions
# - n(): the number of observations in the current group
# - n_distinct(x): the number of unique values in x.
# - first(x), last(x),  nth(x, n) 
# - work similarly to x[1], x[length(x)], and x[n] 
# group_by - splits by group
msleep %>%
  group_by(order) %>%               
  summarize(
    avg_sleep = mean(sleep_total),
    min_sleep = min(sleep_total), 
    max_sleep = max(sleep_total),
    total = n()
  )
msleep %>%
  group_by(vore, order) %>%               
  summarize(
    avg_sleep = mean(sleep_total),
    min_sleep = min(sleep_total), 
    max_sleep = max(sleep_total),
    total = n()
  ) %>% 
  View
##### why use %>% pipes ? #####
msleep %>%
  group_by(vore, order) %>%               
  summarize(
    avg_sleep = mean(sleep_total),
    min_sleep = min(sleep_total), 
    max_sleep = max(sleep_total),
    total = n()
  )
# nesting functions accomplishes the same thing, but harder to parse
summarize(
  group_by(msleep, vore, order),
  avg_sleep = mean(sleep_total),
  min_sleep = min(sleep_total), 
  max_sleep = max(sleep_total),
  total = n()
)
# creating temp objects accomplishes the same thing, but lots of temp discards
msleep_temp <- group_by(msleep, vore, order)
summarize(
  msleep_temp,
  avg_sleep = mean(sleep_total),
  min_sleep = min(sleep_total), 
  max_sleep = max(sleep_total),
  total = n()
)
