############################################################
#' Ec294A Lab R Focus Session Notes 
#' Week 10
#' - file input: zipped file, sas files, excel files
#' - web scraping
#' - working with flights and ggplot2, more examples
#' - knitr global options to avoid setting chunk by chunk
#' - getting help: cheatsheets, vignettes, google
#' - getting help: "minimum reproducible example", dput
###########################################################

####### note: please don't blindly copy code #####
####### these all evaluate to 10 ##########
1*10
5*2
5+5
# but if you do something in a unique way, identical to another
round(pi*3+1) # it can raise suspicions 
10 # a simple, popular way is not considered copying, not suspicious
# we are learning, no reason to "re-invent the wheel"
# learning from others is encouraged, make sure you understand it 

###########################################################
####### Downloading zipped files ##########################
###########################################################
library(downloader)

####### flat file bail ########################
browseURL("https://nces.ed.gov/ccd/pubschuniv.asp")
url = ("https://nces.ed.gov/ccd/Data/zip/ccd_sch_029_1617_w_0e_050317_csv.zip")
download(url, dest="../data/ccd_1617_csv.zip") 
unzip("../data/ccd_1617_csv.zip", exdir = "../data")

####### SAS file success ########################
url = ("https://nces.ed.gov/ccd/Data/zip/ccd_sch_029_1617_w_0e_050317_sas.zip")
download(url, dest="../data/ccd_1617_sas.zip") 
unzip("../data/ccd_1617_sas.zip", exdir = "../data")
list.files("../data")
file.rename("../data/ccd_sch_029_1617_w_0e_050317.sas7bdat", 
            "../data/ccd_1617.sas7bdat")
list.files("../data")
library(haven)  # haven vs. foreign
ccd1617 <- read_sas("../data/ccd_1617.sas7bdat")

####### excel file  ########################
# can use readxl, but might be best to save as csv and read from csv

###########################################################
####### Web Scraping ######################################
###########################################################
library(rvest)
library(tidyverse)

####### Super Bowl Scores Example, modified from:
####### David Radcliffe https://rpubs.com/Radcliffe/superbowl
browseURL("http://espn.go.com/nfl/superbowl/history/winners")
url <- "http://espn.go.com/nfl/superbowl/history/winners"
webpage <- read_html(url)
sb_table <- html_nodes(webpage, "table")
sb <- html_table(sb_table)[[1]]
sb_table[[1]] # first (only) table on the page 
sb <- as.tibble(sb)
sb <- slice(sb, -1:-2) # get rid of headers
names(sb) <- c("number", "date", "site", "result")
sb$number
sb$number <- 1:nrow(sb)
sb$date <- as.Date(sb$date, "%B. %d, %Y")
sb <- separate(sb, result, c("winner", "loser"), sep=", ", remove=TRUE)
# remove takes the column to be separated out of the data
scores_pattern <- " \\d+$" 
# regular expression, recall \\d means a digit, + means 1 or more, $ means ends w/
# we grab all digits at the end of the string, including the leading whitespace
# the leading whitespace is ignored in conversion to numeric
str_view_all(c("Green Bay 35", "Kansas City 10"), " \\d+$")
# an example to make sure we know what this regex is doing
sb$winnerScore <- as.numeric(str_extract(sb$winner, scores_pattern))
sb$loserScore <- as.numeric(str_extract(sb$loser, scores_pattern))
sb$winner <- str_replace(sb$winner, scores_pattern, "")
sb$loser <- str_replace(sb$loser, scores_pattern, "")

####### House of Representatives Wikipedia example, modified from:
####### @juliasilge
browseURL("https://en.wikipedia.org/wiki/Current_members_of_the_United_States_House_of_Representatives")
h <- read_html("https://en.wikipedia.org/wiki/Current_members_of_the_United_States_House_of_Representatives")
reps <- h %>%
  html_node("#votingmembers") %>%
  html_table()
?html_node
# see line 813 of Page Source, we are using CSS selector id , see selector
browseURL("https://cran.r-project.org/web/packages/rvest/vignettes/selectorgadget.html")
# <table class="wikitable sortable" id="votingmembers">
reps <- reps[,c(1:2,4:9)] %>% as_tibble()
# get rid of the color (red/blue) filled column 
reps$clean_Representative1 <- 
  str_replace(reps$Representative, pattern="(([A-Z][^A-Z]+){2})(.*)", 
              replacement="\\1")
# parens for grouping in regular expression, two groups 
# first group: 
# Capital letter, followed by 1 or more NON-caps, repeated twice
# second group: 
# anything, 0 or more times 
# \\1 gets the first group 
reps$clean_Representative1
reps$Representative
# still not perfect, but better 
browseURL("https://regex101.com/")
####### HELP! 
browseURL("https://www.r-project.org/help.html")
browseURL("https://www.rstudio.com/resources/cheatsheets/")
browseVignettes()
browseURL("https://www.google.com") # yes, it could work! 
####### "minimum reproducible example" 
browseURL("http://adv-r.had.co.nz/Reproducibility.html")
dput(mtcars) # dput creates a text representation of data (stored binary)
# copy the output
?dput
# type name of df <- and paste the output
mtcars2 <- structure(list(mpg = c(21, 21, 22.8, 21.4, 18.7, 18.1, 14.3, 
                                 24.4, 22.8, 19.2, 17.8, 16.4, 17.3, 15.2, 10.4, 10.4, 14.7, 32.4, 
                                 30.4, 33.9, 21.5, 15.5, 15.2, 13.3, 19.2, 27.3, 26, 30.4, 15.8, 
                                 19.7, 15, 21.4), cyl = c(6, 6, 4, 6, 8, 6, 8, 4, 4, 6, 6, 8, 
                                                          8, 8, 8, 8, 8, 4, 4, 4, 4, 8, 8, 8, 8, 4, 4, 4, 8, 6, 8, 4), 
                         disp = c(160, 160, 108, 258, 360, 225, 360, 146.7, 140.8, 
                                  167.6, 167.6, 275.8, 275.8, 275.8, 472, 460, 440, 78.7, 75.7, 
                                  71.1, 120.1, 318, 304, 350, 400, 79, 120.3, 95.1, 351, 145, 
                                  301, 121), hp = c(110, 110, 93, 110, 175, 105, 245, 62, 95, 
                                                    123, 123, 180, 180, 180, 205, 215, 230, 66, 52, 65, 97, 150, 
                                                    150, 245, 175, 66, 91, 113, 264, 175, 335, 109), drat = c(3.9, 
                                                                                                              3.9, 3.85, 3.08, 3.15, 2.76, 3.21, 3.69, 3.92, 3.92, 3.92, 
                                                                                                              3.07, 3.07, 3.07, 2.93, 3, 3.23, 4.08, 4.93, 4.22, 3.7, 2.76, 
                                                                                                              3.15, 3.73, 3.08, 4.08, 4.43, 3.77, 4.22, 3.62, 3.54, 4.11
                                                    ), wt = c(2.62, 2.875, 2.32, 3.215, 3.44, 3.46, 3.57, 3.19, 
                                                              3.15, 3.44, 3.44, 4.07, 3.73, 3.78, 5.25, 5.424, 5.345, 2.2, 
                                                              1.615, 1.835, 2.465, 3.52, 3.435, 3.84, 3.845, 1.935, 2.14, 
                                                              1.513, 3.17, 2.77, 3.57, 2.78), qsec = c(16.46, 17.02, 18.61, 
                                                                                                       19.44, 17.02, 20.22, 15.84, 20, 22.9, 18.3, 18.9, 17.4, 17.6, 
                                                                                                       18, 17.98, 17.82, 17.42, 19.47, 18.52, 19.9, 20.01, 16.87, 
                                                                                                       17.3, 15.41, 17.05, 18.9, 16.7, 16.9, 14.5, 15.5, 14.6, 18.6
                                                              ), vs = c(0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 
                                                                        0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1), am = c(1, 
                                                                                                                                1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 
                                                                                                                                0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1), gear = c(4, 4, 4, 3, 
                                                                                                                                                                              3, 3, 3, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 4, 4, 4, 3, 3, 3, 
                                                                                                                                                                              3, 3, 4, 5, 5, 5, 5, 5, 4), carb = c(4, 4, 1, 1, 2, 1, 4, 
                                                                                                                                                                                                                   2, 2, 4, 4, 3, 3, 3, 4, 4, 4, 1, 2, 1, 1, 2, 2, 4, 2, 1, 
                                                                                                                                                                                                                   2, 2, 4, 6, 8, 2)), .Names = c("mpg", "cyl", "disp", "hp", 
                                                                                                                                                                                                                                                  "drat", "wt", "qsec", "vs", "am", "gear", "carb"), row.names = c("Mazda RX4", 
                                                                                                                                                                                                                                                                                                                   "Mazda RX4 Wag", "Datsun 710", "Hornet 4 Drive", "Hornet Sportabout", 
                                                                                                                                                                                                                                                                                                                   "Valiant", "Duster 360", "Merc 240D", "Merc 230", "Merc 280", 
                                                                                                                                                                                                                                                                                                                   "Merc 280C", "Merc 450SE", "Merc 450SL", "Merc 450SLC", "Cadillac Fleetwood", 
                                                                                                                                                                                                                                                                                                                   "Lincoln Continental", "Chrysler Imperial", "Fiat 128", "Honda Civic", 
                                                                                                                                                                                                                                                                                                                   "Toyota Corolla", "Toyota Corona", "Dodge Challenger", "AMC Javelin", 
                                                                                                                                                                                                                                                                                                                   "Camaro Z28", "Pontiac Firebird", "Fiat X1-9", "Porsche 914-2", 
                                                                                                                                                                                                                                                                                                                   "Lotus Europa", "Ford Pantera L", "Ferrari Dino", "Maserati Bora", 
                                                                                                                                                                                                                                                                                                                   "Volvo 142E"), class = "data.frame")
# in the reproducible example you generate to request help, 
# you would just call it mtcars
# i named it mtcars2 just so we could compare them
identical(mtcars, mtcars2)

###########################################################
####### more flights and ggplot2 ##########################
###########################################################
library(nycflights13)

# might be nice to have a numeric object for graphing time
# see http://r4ds.had.co.nz/exploratory-data-analysis.html
# recall how sched_dep_time was stored as say 1350 for 1:50pm 
f <- 
  flights %>%
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  )

time_cancelled <- f %>%
  ggplot(aes(sched_dep_time)) +
  geom_density() +
  facet_wrap(~ cancelled)
print(time_cancelled)
### weather 
fw <- left_join(flights, weather) #fw for flights&weather
fw
View(fw) # check my merge
# lots of NAs? look at unit of time in weather
View(weather)
# just a missing 2013-01-01 5am entry, looks like we can ignore it
names(weather)
def_long_delay <- mean(fw$dep_delay, na.rm = TRUE)+(2*sd(fw$dep_delay, na.rm = TRUE))
fw
fw2 <- fw %>% 
  select(dep_delay, names(weather)) %>%
  select(-origin, -year, -month, -day, -hour, -time_hour) %>%
  filter(dep_delay > def_long_delay) %>%
  gather(-dep_delay, key = "x_name", value = "x_value") 

weather_scatter <- fw2 %>% 
  ggplot(aes(x = x_value, y = dep_delay)) +
  geom_point() + 
  geom_smooth() +
  facet_wrap(~ x_name, scales = "free") 
print(weather_scatter) # not great, but worth logging we tried it

browseURL("http://shiny.stat.ubc.ca/r-graph-catalog/")
browseURL("http://r-statistics.co/Top50-Ggplot2-Visualizations-MasterList-R-Code.html")
###########
# This is how I've been running your homeworks
# won't work for you bc you don't have the folder hw3_sec1 and scripts inside
# just so you can see 
######
library(evaluate)
log <- file("runhw3_sec1.txt")
sink(log)
allfiles<-list.files("./hw3_sec1",full.names=TRUE)
for(fi in allfiles){
  print(fi)
  replay(evaluate(file(fi), keep_message = TRUE))
} 
sink()
