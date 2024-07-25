# CaseStudy 1 - How does a bike-share navigate speedy success
## Scenario
You are a junior data analyst working on the marketing analyst team at Cyclistic, a bike-share company in Chicago. The director of marketing believes the company’s future success depends on maximizing the number of annual memberships. Therefore, your team wants to understand how casual riders and annual members use Cyclistic bikes dierently. From these insights, your team will design a new marketing strategy to convert casual riders into annual members. But rst, Cyclistic executives must approve your recommendations, so they must be backed up with compelling data insights and professional data visualizations.

## Step 1 - Ask
The manager has assigned you a question to answer: `How do annual members and casual riders use Cyclistic bikes dierently?`

Guiding questions
* What is the problem you are trying to solve?
    * Using the data to find out the difference between annual members and casual riders.
* How can your insights drive business decisions?
    * To help design marketing strategies aimed at converting casual riders into annual members.

## Step 2 - Prepare
Cyclistic’s historical trip data
* Source: Lyft Bikes and Scooters, LLC
* Link: https://divvy-tripdata.s3.amazonaws.com/index.html
* License: https://divvybikes.com/data-license-agreement
* Time period: 2015 - 2024

> I select the data from `202307` to `202406` as my case study.

## Step 3 - Process
1. Change the working directory to the folder we use. Import all the `csv` file and aggregate them.
```R
library(tidyverse)
setwd("G:/projects/Google Data Analytics Certificate Case Study/Case Study 1 - How does a bike-share navigate speedy success/data")
weekDay <- c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")

# Import & Aggregate
aggregate_files <- list.files(pattern = "*.csv")
aggregate_data <- map_df(aggregate_files, read_csv)
```

2. Choose the columns we need. I think the data size is enough, so clean the NA cells might be fine. Therefore use the `drop_na` to clean them.
```R
# Clean
divvyTrips <- aggregate_data %>% 
  select(ride_id, started_at, ended_at, start_station_name, end_station_name, member_casual) %>% 
  drop_na() %>% 
```

3. Add 4 columns and filter the `ride_length` more than 1 minute and less than 1 day.
* ride_length: The time from start to end (minute).
* day_of_week: The day of trip end.
* ended_month: The month of trip end.
* ended_hour: The hour of trip end.
```R
  mutate(ride_length = as.numeric(difftime(ended_at, started_at, units = "mins"))) %>%
  mutate(day_of_week = weekDay[wday(ended_at)]) %>%
  mutate(ended_month = month.abb[month(ended_at)]) %>%
  mutate(ended_hour = hour(ended_at)) %>%
  select(ride_id, ended_hour, ended_month, day_of_week, ride_length, member_casual) %>% 
  filter(ride_length >=1, ride_length <= 1440)
```

The table after our cleaning.
![Cleaned Table](img/Cleaned%20Table.png)

## Step 4 - Analyze & Step 5 - Share
### 1. Numbers of rides by month
Compare the number of rides in the 12 months.
```R
# Numbers of rides by month
divvyTrips %>% count(ended_month,member_casual) %>%
  ggplot() +
  geom_bar(mapping = aes(x = reorder(ended_month,match(ended_month,month.abb)),y = n,fill = member_casual), stat="identity") +
  labs(title="Numbers of rides by month", x = "month", y = "rides")
```
![Plot](img/Numbers%20of%20rides%20by%20month.png)

The number of rides are high from June to September. The number of casual riders grow a lot. I think the reason is this time period have better weather and also have more tourists.

### 2. Numbers of rides by days of week
Compare the number of rides in week.
```R
# Numbers of rides by days of week
divvyTrips %>% count(day_of_week,member_casual) %>%
  ggplot() +
  geom_bar(mapping = aes(x = reorder(day_of_week,match(day_of_week,weekDay)),y = n), stat="identity") +
  facet_wrap(~member_casual) +
  labs(title="Numbers of rides by days of week", x = "days of week", y = "rides")
```
![Plot](img/Numbers%20of%20rides%20by%20days%20of%20week.png)

In the plot we can see the trend of two type of users are different. Members usually ride bikes in weekdays, and casual riders usually ride bikes in weekends.

### 3. Numbers of rides by hour
Compare the number of rides in hours.
```R
# Numbers of rides by hour
divvyTrips %>% count(ended_hour,member_casual) %>%
  ggplot() +
  geom_bar(mapping = aes(x = ended_hour,y = n), stat="identity") +
  facet_wrap(~member_casual) +
  labs(title="Numbers of rides by hour", x = "hour", y = "rides")
```
![Plot](img/Numbers%20of%20rides%20by%20hour.png)

There are two peak in the graph of members, about 8 a.m. and 5 p.m. have higher riding. And the casual riders only have one peak value at 5 p.m. Will the previous point, we can guess that members usually ride bikes for work in weekday's commuting time. Casual riders ride bikes for leisure in weekend afternoon.

### 4. Numbers of rides by days of week and hours
Compare the number of rides in week and hours, meet what we think before.
```R
# Numbers of rides by days of week and hours
divvyTrips %>% count(ended_hour,member_casual,day_of_week) %>%
  ggplot() +
  geom_bar(mapping = aes(x = ended_hour,y = n), stat="identity") +
  facet_wrap(member_casual~day_of_week,nrow = 2) +
  labs(title="Numbers of rides by days of week and hours", x = "hour", y = "rides")
```
![Plot](img/Numbers%20of%20rides%20by%20days%20of%20week%20and%20hours.png)

In weekends, two type of users have the same trend. However, the trends are significantly different in weekdays.

### 5. Average ride length
Compare the average ride length of annual members and casual riders.
```R
# Average ride length
View(divvyTrips %>% group_by(member_casual) %>%
       summarise(rides = n(), avg_ride_length = mean(ride_length)))
```
![Plot](img/Average%20ride%20length.png)

Alougth the members have more rides, the casual riders have higher riding time. Just like what we guess before, maybe the reason is members usually ride to work in short distance, and casual riders ride for leisure. Therefore they will ride for longer time.

### Summary
* The number of rides are high from `June to September`.
* Difference between members and casual riders:

| difference | members | casual riders |
| --- | --- | --- |
| week | higher in weekdays | higher in weekends |
| hour | two peaks in commuting time | one peak in afternoon |
| times of riding | higher | lower |
| average riding time | lower | higher |

## Step 6 - Act
Recommendations:
* Focus on the months that have more users (`June to September`) to promote about the members.
* Give some discounts in `weekdays' commuting time` to attract more people ride to work, and convert casual riders into members.
* Also have discounts on `weekends` and let more people ride for leisure and know about this service.