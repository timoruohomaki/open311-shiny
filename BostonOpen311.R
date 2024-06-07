library(readr)
library(lubridate)
library(dplyr)
library(ggplot2)

# Shiny


if(!file.exists("./data")){dir.create("./data")}

fileList <- list.files(path = "data", recursive = TRUE, pattern = "\\.csv$", full.names = TRUE)

open311.raw <- readr::read_csv(fileList, id = "sourceFile")

# factorize columns when needed (also to check how many different values we have)

open311.clean1 <- open311.raw %>% mutate(on_time = as.factor(on_time), case_status = as.factor(case_status),
                                     subject = as.factor(subject), reason = as.factor(reason),
                                     queue = as.factor(queue), department = as.factor(department),
                                     police_district = as.factor(police_district), precinct = as.factor(precinct))

# add key performance indicators (remove if unnecessary)
# see also: https://www.zendesk.com/blog/top-10-help-desk-metrics/ 

open311.clean2 <- open311.clean1 %>% 
        mutate(resolution_time = as.numeric(difftime(closed_dt, open_dt, units = "days"))) %>% 
        mutate(sla_deviation = as.numeric(difftime(closed_dt, sla_target_dt, units = "days")))

# aggregated datasets for daily performance metrics: average monthly resolution time

open311.monthly <- aggregate(resolution_time ~ year(closed_dt) + month(closed_dt), open311.clean2, FUN = mean)

open311.monthly.all <- open311.monthly %>% 
        arrange(`year(closed_dt)`,`month(closed_dt)`)

colnames(open311.monthly.all) = c('year','month','resolution_time')

open311.monthly.all <- open311.monthly.all %>% mutate(year = as.factor(year)) %>% mutate(month = as.factor(month))

figure1 <- ggplot(data = open311.monthly.all, aes(x = month, y = resolution_time, color = year)) + 
        geom_point() +
        ylim(0,50) +
        labs(title="Open311 Request Resolution times 2020-2023", x="Month of Year", y="Time [days]")

figure1 <- figure1 + scale_x_discrete(name = "Month of Year")

figure1 + geom_smooth(aes(as.numeric(month), resolution_time), method = "lm", fill = NA)


