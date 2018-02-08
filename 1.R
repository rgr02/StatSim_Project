rm(list = ls())

# Packages
library(readstata13)
library(dplyr)

# Specify folder and file
file <- "data\\data_to_jrss.dta"

# Read the data
data <- read.dta13(file,convert.underscore = T) # convert = T because of Stata variable naming convention

# Check the structure
str(data)


# Check for duplicates
if(
  select(data,tornata,id) %>%
  distinct() %>%
  count() != nrow(data)
)warning("Duplicate key entries in the Dataset")

# length data = length unique keys -> no duplicates in there :)


# Replacing 0 with NA for "satisfaction" variables
# 5:11 = column indicies
for(i in 5:11){
  data[,i] <- 
    replace(
      data[,i],                # Data Vector
      which(data[,i] == 0),    # Index Vector
      NA                       # Value
  )
}


# TODO:
# Kodieren der Variablen als Faktor??
# Werte der 2. Beobachtung für Gruppe "unpacked" weglassen
# Fertigen Dataset in Workspace schreiben, um ihn später laden zu können