##########################################################
#' Ec294A Lab R Focus Session Notes 
#' Week 2
#' More Nuts and Bolts
#' - Run vs Source, control-enter on a line to run
#' - Interactive mode is useful for learning
#' - Toggle comments (useful for debugging), command+shift+c
#' Data Types
#' - numeric (int/double), character, logical
#' - factors/ordered factors, dates/times
#' - Coercion
#' - Operations, Vector Recycling
#' Data Structurs
#' - vector, matrix, array, list, data.frame
#' Some Useful Functions
###########################################################
###########################################################
# Data Types: Numerics
###########################################################
x <- c(0.5, 1, 2)
x
class(x)
y <- c(10, 20, 30)
x * y # vector operations execute element-by-element
length(x)
x10 <- rep(x, 10)
x10
length(x)
length(x10)
length(y)
x10 * y # vector elements are "recycled" as necessary
x <- c(10, 20, 30)
y <- c(2, 4)
x / y # R will warn you if it thinks you might have made a mistake
# the 1 is recycled, length(x) is not a multiple of length(y)
###########################################################
# Data Types: Character Strings
###########################################################
words <- c("My", "name", "is", "Emily")
words
class(words)
length(words)
sentence <- paste(words, collapse = " ")
sentence
length(sentence)
# x + words # can't operate on vectors of different types
y <- c(1, "A", 2, "B")
y # implicit coercion of datatypes, numerics coerced to characters
class(y)
a_num <- c(1, 2, 3)
class(a_num)
a_chr <- as.character(a_num) # explicit coercion
class(a_chr)
a_num
a_chr
x <- c(1, 2, 3)
x
class(x)
x[3] <- "a" # replace 3rd element
class(x)
x <- c(1, 2, 3)
x[4] <- "4"
x
class(x) # numerics coerced to strings
y <- as.numeric(x) # if all characters can be repped as numerics
y # explicit coercion will bring it back if possible
class(y)
firstnames = c("Jan", "Marsha", "Cindy")
lastnames = "Brady"
fullnames = paste(firstnames, lastnames) # vector recycling! 
fullnames 
###########################################################
# Data Types: Logical (Boolean)
###########################################################
t_boo <- c(TRUE, TRUE, TRUE)
class(t_boo)
f_boo <- !t_boo # NOT
f_boo
t_boo & f_boo # operates element-by-element
t_boo | f_boo
as.numeric(t_boo) #explicit coercion
as.character(t_boo) #explicit coercion
###########################################################
# Data Types: Factors/Ordered Factors
###########################################################
sizes <- c("M", "L", "S", "M", "M", "M", "XS")
class(sizes) # character
sizes_f <- factor(sizes)
class(sizes_f) # now it's a factor
sizes_f # by default levels are sorted in alphabetical order
sizes_f <- factor(sizes, order = TRUE, levels=c("XS", "S", "M", "L", "XL"))
# include levels even if they're not in the data yet
table(sizes_f)
min(sizes_f) # min observed in data
max(sizes_f) # max observed in data
###########################################################
# Data Types: Dates/Times
###########################################################
bday <- as.Date("2017-03-04") 
bday
class(bday)
Sys.Date()
today <- Sys.Date()
class(today)
today - bday
bday <- as.Date("03/04/17") # as.Date function expects yyyy-mm-dd or yy/mm/dd
bday
today - bday # so many years since April 17, 0003
mydateformat <- "%m/%d/%y" # specify a particular format
bday <- as.Date("03/04/17", mydateformat) # tell as.Date it's in specified format
bday
bday <- as.Date("March 4, 2017", "%B %d, %Y") # another format
bday
now <- Sys.time()
later <- Sys.time()
later - now
###########################################################
# Logical Operations
###########################################################
x <- seq(1:10)
y <- 5
y # vector is the basis of all data structures in r, no scalars
x > y # vector recycling!
any(x>y)
all(x>y)
which(x>y)
y <- c(5, 2)
x
y
x > y # recycling! 
###########################################################
# Data Structures: Vectors, Matrices, Arrays, Lists, Data.frames
###########################################################
v <- rep(c(1,10),each=5)
v
v > 5 # returns logical vector of whether condition met
which(v > 5) # returns vector of indices of values meeting condition
v[which(v > 5)] # returns extracted values meeting condition
###########################################################
# Matrices
###########################################################
m <- matrix(v, nrow = 5) # fills by column by default
m <- matrix(v, nrow = 5, byrow = TRUE) 
class(m)
m <- rbind(c(1,2), c(3,4)) # row bind vectors
m
m <- cbind(c(1,2), c(3,4)) # column bind vectors
m
m <- matrix(v, nrow = 5)
r4 <- m[4,]
r4
m[c(3,5),2]
m[-c(1,2,4),] # all rows except 1,2,4 , all columns
###########################################################
# Arrays
###########################################################
a <- array(1:27, dim = c(3,3,3))
a[1,,] # 1st row of each matrix
a[1,2,3] # 1st row, 2nd column, 3rd matrix
dim(a)
a
a[5] # 5th element, by row/column/matrix
###########################################################
# Lists
###########################################################
mylist <- list("Rafael", 2, rnorm(10)) # can hold different types
class(mylist)
mylist
my3v <- mylist[[3]] # extract 3rd list element (vector) using double brackets
my3v
class(my3v)
my3l <- mylist[3] # single brackets will return a list
my3l
class(my3l)
# mynames(mylist) # none yet
mynames <- c("name", "age", "random")
names(mylist) <- mynames
mylist
n <- mylist$random # access by name extracts elements (vector)
n
class(n) 
###########################################################
# Data.frames
###########################################################
df <- data.frame(
  col1 = rep(Sys.Date(),10), 
  col2 = rep("LALA", 10), 
  col3 = rnorm(10), 
  col4 = rep(NA, 10))
df
class(df)
str(df)
names(df)
df[10,]
df[[10,3]] # double brackets to extract single element
df[df$col3 < 0, ] # can extract based on element values
summary(df)
###########################################################
# Some more functions
###########################################################
x <- rnorm(n = 1000) #1000 draws form standard normal
xden <- density(x) # compute density
plot(xden)
y <- rnorm(n = 1000, mean = 0, sd = 2) # spread it out
yden <- density(y)
lines(yden) # add a line to the plot
library(foreign)
mydata <- read.dta(file = "https://people.ucsc.edu/~aspearot/Econ_217/org_example.dta")
my2013CAdata <- subset(mydata, (year==2013 & state=="CA"))
dim(my2013CAdata)
plot(my2013CAdata$age, my2013CAdata$rw)
# replace NA with 0 
my2013CAdata$rw0 <- ifelse(is.na(my2013CAdata$rw), 0, my2013CAdata$rw) 
# ifelse arguments: test, yes, no
mean(my2013CAdata$rw0)
# or just remove NA
mean(my2013CAdata$rw, na.rm=TRUE) # very different means
boxplot(my2013CAdata$rw ~ my2013CAdata$educ) # split by factor levels
pdf("rw_educ_2013CA.pdf") # open a file to output to
boxplot(my2013CAdata$rw ~ my2013CAdata$educ) # split by factor levels
dev.off() # close the file
