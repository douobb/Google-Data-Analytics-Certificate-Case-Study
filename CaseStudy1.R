library(tidyverse)
weekDay <- c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")

# Import & Aggregate
aggregate_files <- list.files(pattern = "*.csv")
aggregate_data <- map_df(aggregate_files, read_csv)

# Clean
divvyTrips <- aggregate_data %>% 
  select(ride_id, started_at, ended_at, start_station_name, end_station_name, member_casual) %>% 
  drop_na() %>% 
  mutate(ride_length = as.numeric(difftime(ended_at, started_at, units = "mins"))) %>%
  mutate(day_of_week = weekDay[wday(ended_at)]) %>%
  mutate(ended_month = month.abb[month(ended_at)]) %>%
  mutate(ended_hour = hour(ended_at)) %>%
  select(ride_id, ended_hour, ended_month, day_of_week, ride_length, member_casual) %>% 
  filter(ride_length >=1, ride_length <= 1440)

divvyTrips$day_of_week <- factor(divvyTrips$day_of_week, levels = weekDay)

# Numbers of rides by month
divvyTrips %>% count(ended_month,member_casual) %>%
  ggplot() +
  geom_bar(mapping = aes(x = reorder(ended_month,match(ended_month,month.abb)),y = n,fill = member_casual), stat="identity") +
  labs(title="Numbers of rides by month", x = "month", y = "rides")

# Numbers of rides by days of week
divvyTrips %>% count(day_of_week,member_casual) %>%
  ggplot() +
  geom_bar(mapping = aes(x = reorder(day_of_week,match(day_of_week,weekDay)),y = n), stat="identity") +
  facet_wrap(~member_casual) +
  labs(title="Numbers of rides by days of week", x = "days of week", y = "rides")

# Numbers of rides by hour
divvyTrips %>% count(ended_hour,member_casual) %>%
  ggplot() +
  geom_bar(mapping = aes(x = ended_hour,y = n), stat="identity") +
  facet_wrap(~member_casual) +
  labs(title="Numbers of rides by hour", x = "hour", y = "rides")

# Numbers of rides by days of week and hours
divvyTrips %>% count(ended_hour,member_casual,day_of_week) %>%
  ggplot() +
  geom_bar(mapping = aes(x = ended_hour,y = n), stat="identity") +
  facet_wrap(member_casual~day_of_week,nrow = 2) +
  labs(title="Numbers of rides by days of week and hours", x = "hour", y = "rides")

# Average ride length
View(divvyTrips %>% group_by(member_casual) %>%
       summarise(rides = n(), avg_ride_length = mean(ride_length)))
