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

# Kodieren der Variablen als Faktor
data <- data.frame(lapply(data, as.factor), stringsAsFactors = FALSE)
str(data)
##########           ?????????
# hier zeigt es auf einmal ab der Spalte "packednodom" die richtigen levels aber die Werte mit 1 und 2, 
# jedoch bei view(data) passt es wieder. hast du ne ahung was man da tun könnte, bitte? ##
#########
View(data)

# Werte der 2. Beobachtung fuer Gruppe "unpacked" weglassen
data <- subset(data, !(data$trattamento=="unpacked" & data$tornata=="2"))

# Fertigen Dataset in Workspace schreiben, um ihn spaeter laden zu koennen
write.csv(data, "C:/Users/Doris/Dropbox/StatSim_Project/data_glueck.csv")
