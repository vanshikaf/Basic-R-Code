############################################################
#' Ec294A Lab R Focus Session Notes 
#' Week 6
#' - lubridate for working with dates
#' - stringr for working with strings
############################################################
library(lubridate)
library(stringr)
library(nycflights13) # data for practicing dates
library(babynames) # data for practicing strings
library(dplyr)
#################################################
#' lubridate basics
#################################################
# we learned about base R as.Date() and base R date objects
# lubridate makes working with dates easier
x <- "03/04/2017"
class(x) # can't manipulate this like a date
xdate <- mdy(x)
class(xdate) # now we have a date
xdate
# lubridate is very flexible, helps us minimize pesky formatting issues
# mdy can handle various delimiters as long as the ordering is month-date-year
x <- c("03/04/2017", "03-05-2017", "03.06.2017")
class(x) # strings
xdates <- mdy(x) # Mar 4, Mar 5, Mar 6
class(xdates)
xdates
# we can be pretty vague compared to base R, lubridate handles parsing
x2 <- c("3/4/2017", "3-5-17", "March 6, 2017")
xdates2 <- mdy(x2)
xdates2 # still Mar 4, Mar 5, Mar 6
# be careful! do you mean dmy()? date-month-year? then use dmy(), notice
# March 6, 2017 is obvious to a human as month-date-year but will be forced
# into June 3, 2017 if you tell R it is in date-month-year
xdates3 <- dmy(x)
x
xdates3 # now April 3, May 3, June 3
# ymd() and ydm() also work like you'd expect
xdates4 <- ymd(c("1950-2-8", "1950/5/26", "1977 oct 21"))
xdates4
# times
x <- "feb 13 2017 15:05"
xtime <- mdy_hm(x)
xtime
# append _h, _hm, or _hms as necessary, on mdy, etc.
xtime <- mdy_hm(x, tz="PST") # error bc PST is not a known zone 
OlsonNames() # differs by system, see what's available
tz(xtime) <- "America/Los_Angeles"
xtime
# or just set it as you make it
ytime <- mdy_hm(x, tz="America/Los_Angeles")
ytime
class(ytime) # R calls these POSIXct - portable os interface calendar time... 
# use the most general format you can, time zones can get complicated...
# pull out components of a date
nowish <- now()
nowish
year(nowish)
month(nowish, label = TRUE, abbr = FALSE)
yday(nowish) # day of year, how far into the year you are
mday(nowish) # day of month
wday(nowish, label = TRUE, abbr = FALSE) # day of week
# differences 
todayis <- today()
class(todayis)
nowis <- now()
bday <- mdy("March 4, 2017")
bday 
wday(bday) # gabriel was born on a saturday
wday(bday, label = TRUE)
wday("3/4/2017", label = TRUE) # can't be sloppy using this function on a string
bday2 <- as.Date("3/4/2017")
bday2
wday(bday2, label = TRUE) # April 20, 0003 AD was a Sunday 
old <-  todayis - bday
old
# the result of subtracting days is a difftime object
class(old)
weekinsec <- dweeks() 
weekinsec
dweeks # look at the function, makes a Duration clas object which is seconds in a year
(secsinweek = 1 * 7 * 24 * 60 * 60) # 1 week, 7 days, 24 hours, 60 minutes, 60 seconds
weeksold <- old / dweeks()
weeksold # almost 50 weeks old 
yearsold <- old / dyears()
yearsold # almost a year old
x <- dminutes(2) # how many seconds is 2 minutes
class(x) # duration object
dhours(2)  # how many seconds is 2 hours
ddays(2)  # how manys days is 2 days
dweeks(2)  # how many seconds is 2 weeks
dyears(2)  # how many seconds is 2 years
#################################################
#' lubridate with nycflights13
#' based on Hadley Wickham, R for Data Science examples
#################################################
# take a look at the date/time info in flights
flights %>% 
  select(year, month, day, hour, minute)
# make a date object out of individual components 
f <- flights %>% 
  select(
    year, month, day, hour, minute, 
    dep_time, sched_dep_time, dep_delay, 
    arr_time, sched_arr_time, arr_delay, flight, carrier
    ) %>%
  mutate(
    departure = make_datetime(year, month, day, hour, minute)
  ) 
# now we have scheduled departure time in a date object
str(f) 
# note the actual departure time (dep_time) is held in an integer 
# arithmetic operators that can be very helpful
# %/% : integer division operator
5 %/% 2
517 %/% 100
# %% : modulus 
5 %% 2
517 %% 100
# this little function will help us make the integer into a date 
make_datetime_100 <-  function(year, month, day, time){
  make_datetime(year, month, day, time %/% 100, time %% 100)
}
# time %/% 100 gets hours from the int, time %% 100 gets the minutes from the int
f2 <-  flights %>%
  filter(!is.na(dep_time), !is.na(arr_time)) %>%
  mutate(
    dep_time = make_datetime_100(year, month, day, dep_time),
    arr_time = make_datetime_100(year, month, day, arr_time),
    sched_dep_time = make_datetime_100(year, month, day, sched_dep_time),
    sched_arr_time = make_datetime_100(year, month, day, sched_arr_time)
  ) 
str(flights) # now the times 
str(f2) # now the times are date objects 
# solve an issue with apparent backward time travel, these flights
# arrive before they depart 
tt <- f2 %>% filter(arr_time < dep_time)
f4 <- f2 %>%
  mutate(
    overnight = arr_time < dep_time, # dummy for redeye
    arr_time = arr_time + days(overnight * 1), # add day to redeyes
    sched_arr_time = sched_arr_time + days(overnight * 1)
  )
f4 %>% 
  filter(overnight == TRUE) %>% 
  select(arr_time, dep_time, overnight) %>% 
  View()
tt <- f4 %>% 
  filter(arr_time < dep_time)
# no more apparent time travel
# we used the lubridate "days" function which returns "period" objects to help us
# "periods" are like "durations" but aren't fixed in seconds
class(days(0))
days(1)
days(5)
todayis + days(5)
bday + years(5) # gabriel turns 5 
#################################################
#' stringr basics, see Hadley Wickham tutorials
#################################################
string1 <- "This is a string"
string2 <- 'To include a "quote" inside a string, use single quotes'
double_quote <- "\"" # or '"'
single_quote <- '\'' # or "'"
x <- c("\"", "\\") # vector of " and \
x # printed representation of a string is NOT the string, shows escapes
writeLines(x) # see raw contents of string, correctly shows " and \
writeLines(string2) 
string2
# special characters 
?'"' 
x <- "\u{00b5}" # unicode character
x
writeLines(x) 
######### string combine, str_c ########
# all stringr functions start with str_
str_c("x","y") 
str_c("x","y",sep = ",")
str_c("prefix-", c("a", "b", "c"), "-suffix") # recycling
v <- c("x", "y", "z")
v
str_c(v, collapse = ", ")
str_c(v, collapse = "")
# str_c is like Base R paste0, one difference is NA treatment
paste0("x","y")
paste0("x", NA) 
str_c("x", NA)
######### string extraction (substring), str_sub ########
x <- c("Apple", "Banana", "Pear")
str_sub(x, 1, 3)
str_sub(x, -3, -1) # negative numbers count backwards from end
str_sub("a", 1, 5) # return as much as possible if string is too short
str_sub(x, 1, 1) <- str_to_lower(str_sub(x, 1, 1)) # modify an existing string, x is modified
x
str_to_upper(x)
str_to_title(x)
######### trim whitespace, pad with whitespace: str_trim, str_pad #######
str_trim("        abc         ") # default is to trim both sides
str_trim("        abc         ", side = "left")
str_trim("        abc         ", side = "right")
str_pad("abc", 10) # default is to pad left
str_pad("abc", 10, side = "right")
str_pad("abc", 10, side = "both")
#################################################
#'
#'  regex basics, can get complicated 
#'  
#' regular expressions are very compact representations of patterns in strings
#' beyond matching for specific literal character patterns, metacharacters can help identify
#' complicated patterns 
#' 
#################################################
x <- c("apple", "banana", "pear")
str_view(x, "an") # this is a function that helps us learn regex
str_detect(x, "an") # detect the pattern
str_locate(x, "an") # locate the pattern
str_view(x, ".a.") # . matches any character 
str_detect(x, ".a.") 
str_locate(x, ".a.")
#' natural question: if . means "any character", how do we look for an actual "."?
#' use escape to tell the regex you want to escape the special behavior, match exactly
#' two layers of complications. 
#' strings use backslash to escape special behavior. 
#' so do regexps 
#' So to match a . you need the regexp backslash dot. regex = \. 
#' We use strings to represent regular expressions 
#' and backslash is also used as an escape symbol in strings. 
#' So to create the regular expression \. we need the string \\. 
dot  <- "\\."
writeLines(dot)  # string representation of a regular expression, backslash to escape special behavior
str_view(c("abc", "a.c", "bef"), "a\\.c")
str_view(c("abc", "a.c", "baaaa.cc"), "a\\.c")
#' another natural question: if \ is an escape character, how do we look for an actual "\"?
#' again, use escape to tell the regex to escape the special behavior, match exactly
#' so the regex we need is \\  we need to use a string to create this, which also needs
#' the escape character
#' So to create the regular expression \\ we need the string \\\\
x <- "a\\b"
writeLines(x)
str_view(x, "\\\\")
# special metacharacters match specific patterns 
# ^ starts with, ends with $ 
x <- c("apple", "banana", "pear")
str_view(x, "^a")
str_view(x, "a$")
# to match only complete strings (not partials as is default) force ^$
x <- c("apple pie", "apple", "apple cake")
str_view(x, "apple")
str_view(x, "^apple$")
# multiple literals [abc]: matches a, b, or c.
# multiple literals [^abc]: matches anything except a, b, or c. 
x <- c("apple", "banana", "pear")
str_view_all(x, "[abc]") # match abc
str_locate(x, "[abc]")
str_locate_all(x, "[abc]")
str_view_all(x, "[^abc]") # match anything except abc
x <- "1 4m l33t h4x0r"
# \d means any digit
str_detect(x, "\\d") 
str_locate_all(x, "\\d")
str_view_all(x, "\\d")
str_view(x, "\\d")
# repetition
# ?: 0 or 1
# +: 1 or more
# *: 0 or more
# {n}: exactly n
str_detect(x, "\\d+") 
str_locate_all(x, "\\d+")
str_view_all(x, "\\d+") # any digit
str_view_all(x, "\\d{2}") # exactly two digits 
# \s any whitespace 
str_view_all(x, "\\s")
x <- c("apple pie", "apple", "apple cake")
str_view(x, "^a.{3}e$") # begins with a, ends with e, 3 anything in between, 
# use | for one or more patterns
str_view(c("grey", "gray"), "gr(e|a)y")
# str_replace 
str_replace(c("grey", "gray"), pattern = "gr(e|a)y", replacement = "GRAY")
#################################################
#'
#' Let's work with stringr using babynames data
#'
#################################################
babynames %>% 
  filter(sex=="F") %>%
  distinct(name) %>%
  nrow()
babynames %>% 
  filter(sex=="M") %>%
  distinct(name) %>%
  nrow()
# there are more distinct female names than male names
fnames <- babynames %>%
  filter(sex == "F") %>%
  group_by(name) %>%
  summarize(totaln = sum(n))
mean(fnames$totaln)
mnames <- babynames %>%
  filter(sex == "M") %>%
  group_by(name) %>%
  summarize(totaln = sum(n))
mean(mnames$totaln)
# male names are more concentrated, each name is assigned to more babies
# Let's try out some regular expressions 
# these all do the same thing, though _1 returns a char vector 
( m_en_1 <- mnames$name[grep("en$", mnames$name)] ) # Base R 
( m_en_2 <- mnames %>% filter(grepl("en$", name)) )  # dplyr and Base R for strings
( m_en_3 <- mnames %>% filter(str_detect(name, "en$")) ) # dplyr and stringr 
# find all female names that have match "e.i" (i.e. emily)
f_e.i <- fnames %>% filter(str_detect(name, "e.i")) 
nrow(f_e.i) # lots of names
f_e.i %>% filter(name=="Emily") # no Emily! why? case-sensitive
# let's convert to all lower case so we don't have to worry about E vs e for now
# we will see how to match either case later 
# let's try again
( fnames <- fnames %>% mutate(lname = tolower(name)) )# Base R 
( fnames <- fnames %>% mutate(lname = str_to_lower(name)) )# dplyr
f_e.i <- fnames %>% filter(str_detect(lname, "e.i")) 
nrow(f_e.i) # even more nows
View(f_e.i)
em <- f_e.i %>% filter(lname=="emily") # there i am 
View(em)
f_begins_e.i.y <- f_e.i %>% 
  filter(str_detect(lname, "^[Ee].i.y"))
nrow(f_begins_e.i.y) # now it's reasonable 
View(f_begins_e.i.y)
fnames %>% filter(str_detect(name, "Yuan")) # not as common 
m_el <- mnames %>% filter(str_detect(name, "el$"))
nrow(m_el)
f_el <- fnames %>% filter(str_detect(name, "el$"))
nrow(f_el) # *el is a more popular ending for males than females 
# extract last two characters from every name in the vector
# list five highest endings for males and for females
endings <- babynames %>% 
  mutate(end = str_sub(name, -2, -1)) %>%
  group_by(end, sex) %>%
  summarize(endcount = sum(n)) %>% 
  arrange(desc(endcount))

fendings <- endings %>% filter(sex == "F") 
fendings[1:5,]
mendings <- endings %>% filter(sex == "M") 
mendings[1:5,]

