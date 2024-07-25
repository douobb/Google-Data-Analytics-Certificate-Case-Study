# CaseStudy 1 - How does a bike-share navigate speedy success
## 場景
你是一位初級數據分析師，在芝加哥的自行車共享公司 Cyclistic 的營銷分析師團隊工作，行銷總監認為公司未來的成功必須最大化年度會員數，因此你的團隊希望了解休閒騎士和年度會員使用自行車的方式有什麼不同，並且根據結果設計新的行銷策略，將休閒騎士轉化為年度會員，但首先 Cyclistic 主管必須批准您的建議，因此這些建議必須要有有說服力的見解和資料視覺化的支援。

## Step 1 - Ask
主管指派了你一個問題： `休閒騎士和年度會員使用自行車的方式有什麼不同?`

Guiding questions
* 你要解決的問題是什麼?
    * 利用資料找出休閒騎士和年度會員之間的差異。
* 你的見解會如何影響決策?
    * 幫助設計策略，將休閒騎士轉化為年度會員。

## Step 2 - Prepare
Cyclistic 的歷史行程數據
* 資料來源： Lyft Bikes and Scooters, LLC
* 網址： https://divvy-tripdata.s3.amazonaws.com/index.html
* 授權： https://divvybikes.com/data-license-agreement
* 時間段： 2015 - 2024

> 我選擇了 `202307` 到 `202406` 的資料作為我的案例分析。

## Step 3 - Process
1. 將工作目錄改到我們使用的資料夾，引入所有 `csv` 檔案並且合併起來。
```R
library(tidyverse)
setwd("G:/projects/Google Data Analytics Certificate Case Study/Case Study 1 - How does a bike-share navigate speedy success/data")
weekDay <- c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")

# Import & Aggregate
aggregate_files <- list.files(pattern = "*.csv")
aggregate_data <- map_df(aggregate_files, read_csv)
```

2. 選擇我們所需要的欄位，因為資料集的數據夠多，因此我認為可以使用 `drop_na` 清理缺失值所在的列。
```R
# Clean
divvyTrips <- aggregate_data %>% 
  select(ride_id, started_at, ended_at, start_station_name, end_station_name, member_casual) %>% 
  drop_na() %>% 
```

3. 增加四個列，並且篩選 `ride_length` 的值在 1 分鐘到 1 天之間。
* ride_length: 行程的時間 (單位為分鐘)。
* day_of_week: 行程結束時是星期幾。
* ended_month: 行程結束時的月份。
* ended_hour: 行程結束時是幾點。
```R
  mutate(ride_length = as.numeric(difftime(ended_at, started_at, units = "mins"))) %>%
  mutate(day_of_week = weekDay[wday(ended_at)]) %>%
  mutate(ended_month = month.abb[month(ended_at)]) %>%
  mutate(ended_hour = hour(ended_at)) %>%
  select(ride_id, ended_hour, ended_month, day_of_week, ride_length, member_casual) %>% 
  filter(ride_length >=1, ride_length <= 1440)
```

清理後的表格：

![Cleaned Table](img/Cleaned%20Table.png)

## Step 4 - Analyze & Step 5 - Share
### 1. 每月騎乘次數
比較各個月份的騎乘次數。
```R
# Numbers of rides by month
divvyTrips %>% count(ended_month,member_casual) %>%
  ggplot() +
  geom_bar(mapping = aes(x = reorder(ended_month,match(ended_month,month.abb)),y = n,fill = member_casual), stat="identity") +
  labs(title="Numbers of rides by month", x = "month", y = "rides")
```
![Plot](img/Numbers%20of%20rides%20by%20month.png)

騎乘次數在六月到九月時最高，且休閒騎士的數量成長明顯，我認為可能是因為這個時間段有較好的天氣，並且遊客數量較多。

### 2. 星期內每日騎乘次數
比較星期內每日的騎乘次數。
```R
# Numbers of rides by days of week
divvyTrips %>% count(day_of_week,member_casual) %>%
  ggplot() +
  geom_bar(mapping = aes(x = reorder(day_of_week,match(day_of_week,weekDay)),y = n), stat="identity") +
  facet_wrap(~member_casual) +
  labs(title="Numbers of rides by days of week", x = "days of week", y = "rides")
```
![Plot](img/Numbers%20of%20rides%20by%20days%20of%20week.png)

在圖中可以發現兩種使用者的騎乘趨勢是不同的，會員通常在工作日騎乘，而休閒騎士則在周末騎乘較多。

### 3. 各小時騎乘次數
比較每個小時的騎乘次數。
```R
# Numbers of rides by hour
divvyTrips %>% count(ended_hour,member_casual) %>%
  ggplot() +
  geom_bar(mapping = aes(x = ended_hour,y = n), stat="identity") +
  facet_wrap(~member_casual) +
  labs(title="Numbers of rides by hour", x = "hour", y = "rides")
```
![Plot](img/Numbers%20of%20rides%20by%20hour.png)

在會員的圖中可以看到兩個峰值，分別是早上八點以及下午五點，而休閒騎士只有一個峰值在下午五點，綜合前一點可以推測，會員通常在通勤時間騎車上下班，休閒騎士則是在周末下午騎車休閒較多。

### 4. 星期內各日各小時騎乘次數
比較星期內每日每小時的騎乘次數。
```R
# Numbers of rides by days of week and hours
divvyTrips %>% count(ended_hour,member_casual,day_of_week) %>%
  ggplot() +
  geom_bar(mapping = aes(x = ended_hour,y = n), stat="identity") +
  facet_wrap(member_casual~day_of_week,nrow = 2) +
  labs(title="Numbers of rides by days of week and hours", x = "hour", y = "rides")
```
![Plot](img/Numbers%20of%20rides%20by%20days%20of%20week%20and%20hours.png)

在假日時兩者的趨勢是相同的，但是在工作日時就有明顯的不同，符合我們之前的假設。

### 5. 平均騎乘時間
比較兩種使用者的平均騎乘時間。
```R
# Average ride length
View(divvyTrips %>% group_by(member_casual) %>%
       summarise(rides = n(), avg_ride_length = mean(ride_length)))
```
![Plot](img/Average%20ride%20length.png)

雖然會員的騎乘次數比休閒騎士要多，但是休閒騎士的平均騎乘時間較高，如同我們之前假設的，原因可能是會員通勤時間較短，而休閒騎士主要是騎車進行休閒活動，因此騎乘時間較長。

### 總結
* 在`六月到九月`期間有較高的騎乘次數.
* 會員與休閒騎士的差異：

| 差異 | 會員 | 休閒騎士 |
| --- | --- | --- |
| 周 | 工作日較高 | 周末較高 |
| 小時 | 通勤時間有兩個峰值 | 單一個峰值在下午 |
| 騎乘次數 | 較高 | 較低 |
| 平均騎乘時間 | 較低 | 較高 |

## Step 6 - Act
建議:
* 將預算集中在有較多客戶的月份 (`六月到九月`) 去吸引更多會員。
* 在`工作日的通勤時間`提供折扣，吸引更多人騎車通勤，並且轉化為會員。
* 同時在`周末`也提供折扣，讓更多人騎車進行休閒活動，接觸到這項服務。