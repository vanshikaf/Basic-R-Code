############################################################
#' Ec294A Lab R Focus Session Notes 
#' Week 9
#' Interacting with a database through R
#' Using SQLite with R with dbplyr functions
############################################################
library("dbplyr") # dplyr code related to databases  
library("RSQLite") # we will use a SQLite backend 
library("nycflights13") # example data
#' Create a small database on your machine (wherever you are 
#' currently working.) This is not the most typical scenario. 
#' Typically the need is to connect to a database that lives remotely
#' on a server hosting the database. The way we connect is 
#' irrelevant for practicing the basic syntax. We can learn the basic
#' syntax no matter what kind of connection we are using. 
#' 
#' Create a connection to our play database
#' This is only a connection; we do NOT load the file into 
#'  our memory as we do when e.g. creating a data.frame from a .csv
#'  file. Here, we only instructing R to create a connection to 
#'  a database, and name the connection object
#
#' Note: I will try to use the "::" notation to indicate from which
#' package we are using a function the first time we invoke it
#' so that you aware of what comes from where. 
#
# ******  Create a connection to SQLite database manager
mycon = DBI::dbConnect(RSQLite::SQLite(), 
                       dbname="../dbhome/exampledb.sqlite3")
#' Here we use .sqlite3 suffix, but .db is also popular/valid 
mycon
DBI::dbListTables(mycon) # nothing there yet
#' If you load the libraries, this what you would probably
#' use most of the time   
# mycon = dbConnect(SQLite(), dbname="../dbhome/exampledb.sqlite3")
# mycon# there's nothing in exampledb.db yet
# ******  Put some stuff in the database
# copy into the db the flights data from nycflights13 so we can 
# practice SQL queries, you normally will not do this bc your 
# database will already exist! 
# copy_to takes local dataframe (flights) and uploads to (remote) source
dplyr::copy_to(mycon, nycflights13::flights, "flights",
        temporary = FALSE, 
        indexes = list(
          c("year", "month", "day"), 
          "carrier", 
          "tailnum",
          "dest"),
        overwrite = TRUE # only need the second time code is run
)
# What are "indexes"? Help quickly find rows in the table
# 
# Note from R for Data Science: 
# flights connects to airlines via carrier 
# flights connects to airports via origin, dest (called faa in airports)
# flights connects to planes via tailnum
# flights connects to weather via origin (the location), 
#                    and year, month, day and hour (the time).
#
DBI::dbListTables(mycon) # now we have our 1st table
# sqlite_stat1 and sqlite_stat4 are internal tables 
# finish "building" the database by copying over data from the 
# dataframes in nycflights13 
copy_to(mycon, nycflights13::airlines, "airlines",
        temporary = FALSE, 
        indexes = list("carrier"),
        overwrite = TRUE # only need the second time code is run
)
copy_to(mycon, nycflights13::airports, "airports",
        temporary = FALSE, 
        indexes = list("faa"),
        overwrite = TRUE # only need the second time code is run
)
copy_to(mycon, nycflights13::planes, "planes",
        temporary = FALSE, 
        indexes = list("tailnum"),
        overwrite = TRUE # only need the second time code is run
)
copy_to(mycon, nycflights13::weather, "weather", 
        temporary = FALSE,
        indexes = list(
        c("year", "month","day","hour"), "origin"),
        overwrite = TRUE # only need the second time code is run
)
DBI::dbListTables(mycon) # now we have all the tables
################################
#' instead of the code in line 32
#' mycon = dbConnect(SQLite(), dbname="../dbhome/exampledb.sqlite3")
#' in practice your connect code might look something like this
#' using MySQL vs SQLite:
# con <- DBI::dbConnect(RMySQL::MySQL(), 
# host = "database.hostname.com",
# user = "yourname",
# password = rstudioapi::askForPassword("hostname password")
#
# warning: never hard code your passwords!
# another option, package "keyring" 
#
# lots of SQL "dialects"... in addition to RSQLite, current 
# specific backend packages available includeRMySQL (MySQL, MariaDB), 
# RPostgreSQL (Postgres), odbc (proprietary backends), bigrquery (google)
#
################################
#toydb <- dbplyr::nycflights13_sqlite()
#class(toydb)
################################
# create a table from the database connection, though it does not 
# generate the entire df data.frame, only a connection
flights_db <- dplyr::tbl(mycon, "flights")
?tbl # creates a data frame table from a src query
flights_db # looks like a tibble 
class(flights_db) # but not a tibble! tbl_dbi
# flights_db <- mycon %>% tbl("flights") # simpler syntax
# compare with a regular tibble, nrows unknown
flights # this is the dataframe included in nycflights13 
class(flights) # legit tibble
nrow(flights)
nrow(flights_db)  
# queries are not actually run until you force it, queries can be "expensive"
# time-consuming, so dplyr prevents you from accidentally doing something
# very costly. you have to indicate to dplyr that you REALLY want to run
# the query with either collect() or compute() or something else requiring
# all of the data, dplyr waits until it absolutely has to run the query
tail(flights)
tail(flights_db)  # can't find last rows without executing full query
head(flights)
head(flights_db)  # head is okay bc we don't need to inspect entire db
##############################################
# actually retrieve the entire table from the database connection
flights_db <- dplyr::tbl(mycon, "flights") %>%
  show_query() %>%
  collect()
class(flights_db)
##############################################
# SQL is the language used to interact with a database,
# dbplyr generates SQL (translates from dplyr to SQL) for you
# it doesn't do everything SQL can do, but it does SELECTS which 
# is mostly what you will need if you are grabbing data from the database
#
# general form of an SQL query (brackets optional)
# SELECT col1 [, col2, ....]  
# FROM table1 [, table2, ....]
# [WHERE clause]  
# you can write a SQL query manually 
# dplyr: Return an actual tibble using collect
flights_db2 <- tbl(mycon, dplyr::sql("SELECT * FROM flights")) %>% 
  show_query() %>% 
  collect()
identical(flights_db2, flights_db) 
# flights (from nycflights13 and flights_fromdb are very similar, except
# time_hour storage differs 
identical(flights_db, flights)
str(flights_db)
str(flights)
flights$time_hour <- as.numeric(flights$time_hour)
identical(flights_db, flights)
################################################################
#' SQL is NOT case-sensitive, but historically SQL commands have
#' been written in upper-case. 
#' 
# This time, just get 5 columns 
# using SQL
tbl(mycon, 
    sql("SELECT year, month, day, tailnum, dep_delay 
        FROM flights ")) %>% collect()
# using dplyr
tbl(mycon, "flights") %>%
  select(year, month, day, tailnum, dep_delay) %>%
  show_query() %>% 
  collect()
# using SQL 
tbl(mycon, 
    sql("SELECT tailnum, dep_delay, arr_delay, 
        dep_delay + arr_delay AS z
        FROM flights")
    ) %>% collect()
# dplyr
tbl(mycon, "flights") %>% 
  select(tailnum, dep_delay, arr_delay) %>%
  mutate(z = dep_delay + arr_delay) %>%
  show_query() 
# using SQL
tbl(mycon, 
    sql("SELECT tailnum, dep_delay, arr_delay, 
        dep_delay + arr_delay AS z
        FROM flights
        WHERE z > 50")
    ) %>% show_query() 
# select, mutate, filter
tbl(mycon, "flights") %>%
  select(tailnum, dep_delay, arr_delay) %>%
  mutate(z = dep_delay + arr_delay) %>%
  filter(z > 50) %>%
  show_query() 
###########
# A common source of confusion with SQL: 
# SQL syntax is NOT ORDERED the way it is executed 
# https://blog.jooq.org/2016/12/09/a-beginners-guide-to-the-true-order-of-sql-operations/
# lexical ordering (how you write it): 
# SELECT 
# FROM
# WHERE
# GROUP BY
# HAVING
# UNION
# ORDER BY
#
# logical ordering (how it is executed):
# FROM
# WHERE
# GROUP BY
# HAVING
# SELECT
# UNION
# ORDER BY
# 
# implication-- this wouldn't work 
# SELECT A.x + A.y AS z
# FROM A
# WHERE z = 10 ....  
# 
# lexical ordering is ok (syntax acceptable) but executing...
# 1) FROM 2) WHERE 3) SELECT 
# so when z is referenced in the WHERE statement, 
# z has not yet been defined
# 
# with indents to highlight nesting
# SELECT *
# FROM (
#       SELECT `tailnum`, `dep_delay`, `arr_delay`, `dep_delay` + `arr_delay` AS `z`
#       FROM (
#             SELECT `tailnum`, `dep_delay`, `arr_delay`
#             FROM `flights`)
#      )
# WHERE (`z` > 50.0)
###########
# "The goal of dplyr is to provide a semantic rather than a 
# literal translation: what you mean rather than what is done." 
# https://cran.r-project.org/web/packages/dbplyr/vignettes/sql-translation.html
#####################################
# a little more about SQL 
# FROM a, b 
tbl(mycon, 
    sql("SELECT * FROM planes")
) %>% 
  collect()
# 3322 rows, 9 columns
tbl(mycon, 
    sql("SELECT * FROM airports")
)%>% 
  collect()
# 1458 rows, 8 columns
temp <- tbl(mycon, 
            sql("SELECT *
                FROM airports, planes")
            ) %>% 
  collect()
temp
# 4,843,476 rows (3322*1397)
# 17 columns (9+8) 
# output from a FROM clause is a combined table reference
# FROM makes a*b rows available (cross-product)
# each record in a is paired with each record in b
# 
# this enormous table is the starting point on which the rest of 
# the query is executed
###############
# JOINS
inner_join(
  tbl(mycon, "flights"),
  tbl(mycon, "planes"),
  by = "tailnum") %>%
  show_query() %>% 
  collect() 
# renames columns with identical names in two sets
# other joins available as well, e.g. left
left_join(
  tbl(mycon, "flights"),
  tbl(mycon, "planes"),
  by = "tailnum") %>%
  show_query() %>%
  collect()
# GROUP BY
# dplyr on regular dataframe 
avgdelays_df <- flights %>%
  group_by(year, month, day) %>%
  summarize(
    delaymean = mean(dep_delay, na.rm = TRUE)
  )
avgdelays_df
# dplyr on database connection
avgdelays_sql <- tbl(mycon, "flights") %>%
  group_by(year, month, day) %>%
  summarize(
    delaymean = mean(dep_delay, na.rm = TRUE)    
  ) %>% show_query() %>% collect()
avgdelays_sql
#### 
# 365 rows, and: 
sum(avgdelays_df$delaymean == avgdelays_sql$delaymean)
avgdelays_df[avgdelays_df$delaymean != avgdelays_sql$delaymean,]
avgdelays_sql[avgdelays_df$delaymean != avgdelays_sql$delaymean,]
# issue with floating point arithmetic approximations
# stored in binary 
identical(avgdelays_df$delaymean, avgdelays_sql$delaymean)
all.equal(avgdelays_df$delaymean, avgdelays_sql$delaymean)
?all.equal
# R to SQL translation is currently limited.
# Focuses on SELECT commands 
# dplyr knows how to convert the following R functions to SQL:
# - basic math operators: +, -, *, /, %%, ^
# - math functions: abs, acos, acosh, asin, asinh, atan, atan2, atanh, ceiling, cos, cosh, cot, coth, exp, floor, log, log10, round, sign, sin, sinh, sqrt, tan, tanh
# - logical comparisons: <, <=, !=, >=, >, ==, %in%
# - boolean operations: &, &&, |, ||, !, xor
# - basic aggregations: mean, sum, min, max, sd, var
# One-table dplyr verbs
flights_db <- tbl(mycon, "flights")
select(flights_db, year:day, dep_delay, arr_delay) %>% 
  show_query() 
filter(flights_db, dep_delay > 0) %>%
  show_query()
arrange(flights_db, year, month, day) %>%
  show_query()
mutate(flights_db, 
       speed = air_time / distance) %>%
  show_query()
summarize(flights_db, 
          delay = mean(dep_time, na.rm = TRUE)) %>%
  show_query()
flights_db %>%
  group_by(month, day) %>%
  summarize(delay = mean(dep_delay, na.rm = TRUE)) %>%
  show_query()
# the expressions are translated into SQL so they can be run on the database. 
# "laziness"
#' When working with databases, 
#' dplyr tries to be as lazy as possible. 
#' 
#' It’s lazy in two ways:
#' - It never pulls data back to R unless you explicitly ask for it.
#' - It delays doing any work until the last possible minute, 
#'   collecting together everything you want to do then sending 
#'   that to the database in one step.
c1 <- filter(flights_db, year == 2013, month == 1, day == 1)
c2 <- select(c1, year, month, day, carrier, dep_delay, air_time, distance)
c3 <- mutate(c2, speed = distance / air_time * 60)
c4 <- arrange(c3, year, month, day, carrier)
#' This sequence of operations never actually touches the database. 
#' dplyr does not generate the SQL and communicate with the database
#' until you force it and even then it only pulls down 10 rows.
c4
class(c4)  # this is  tbl_dbi object right now 
show_query(c4) # this is the SQL query dplyr constructed for us fom 344-347
# To pull all the results use collect(), which returns a tbl_df():
c5 <- c4 %>% collect() # now the query is actually run 
class(c5) # so now we have a tbl_df (tibble)
# Forcing computation
#' - collect() executes the query and returns the results to R.
#' - compute() executes the query and stores the results in a temporary table 
#'   in the database.
# You are most likely to use collect(): once you have interactively converged on 
# the right set of operations, use collect() to pull down the data into a local 
# tbl_df(). 
#' SQL queries can take a long time, justifying "pre-collection"
flights_db %>% select(year:day, dep_delay, arr_delay) %>% show_query()
flights_db %>% filter(dep_delay > 240) %>% show_query() 
flights_db %>% 
  group_by(dest) %>%
  summarize(delay = mean(dep_time)) %>% show_query()
tailnum_delay_db <- flights_db %>% 
  group_by(tailnum) %>%
  summarize(
    delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  ) %>% 
  arrange(desc(delay)) %>%
  filter(n > 100)
tailnum_delay_db %>% show_query()
tailnum_delay <- tailnum_delay_db %>% collect()
tailnum_delay
##### without dplyr helper functions, send SQL queries manually 
myquery <- RSQLite::dbSendQuery(mycon, "SELECT * FROM flights")
flights_manualquery <- DBI::dbFetch(myquery)  
flights_manualquery
DBI::dbClearResult(myQuery)
##### close connection
DBI::dbDisconnect(mycon)


