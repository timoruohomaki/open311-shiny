library(readr)
library(lubridate)
library(dplyr)

# Shiny


if(!file.exists("./data")){dir.create("./data")}

fileList <- list.files(path = "data", recursive = TRUE, pattern = "\\.csv$", full.names = TRUE)

open311.raw <- readr::read_csv(fileList, id = "sourceFile")

# factorize columns when needed

open311.clean1 <- open311.raw %>% mutate(on_time = as.factor(on_time), case_status = as.factor(case_status),
                                     subject = as.factor(subject), reason = as.factor(reason),
                                     queue = as.factor(queue), department = as.factor(department))