--Create new database
CREATE DATABASE alotech
--Use the database that created
USE alotech


-- Imported flat file(data) and table named as citibike from the bigquery(SELECT * FROM `bigquery-public-data.new_york_citibike.citibike_trips`
																--WHERE DATE(starttime) between "2018-01-01" and "2018-02-01"
																--LIMIT 1000)

-- *************************************************************************************************************************
											
-- Answer 1:
-- Data Range from the citibike table
SELECT MIN(starttime) AS oldestDate, MAX(stoptime) AS newestDate
FROM citibike

--**********************************************************************************

--Answer 2:
--created a view for generation by birth_year (Execute firstly this query)
CREATE VIEW Generation AS

SELECT starttime,
	CASE
		WHEN 1946 <= birth_year AND birth_year <= 1964 THEN 'Boomer'
		WHEN 1965 <= birth_year AND birth_year <= 1979 THEN 'X'
		WHEN 1980 <= birth_year AND birth_year <= 1995 THEN 'Y'
		WHEN 1996 <= birth_year AND birth_year <= 2020 THEN 'Z'
		ELSE 'Other'
	END AS gen_id
FROM citibike

--how many trips a generation has made based on year and month of birth. (Execute secondly this query)
SELECT *
FROM(
SELECT YEAR(starttime) trip_year,gen_id, DATENAME(month, starttime) trip_month, COUNT(*) as trip_count
FROM Generation
GROUP BY YEAR(starttime),gen_id, DATENAME(month, starttime)
) as A
PIVOT(
	SUM(trip_count) FOR trip_month IN([January],[February])
	) as trip_cnt



-- Answer 3:
--Average trip time per month (with outlier tripduration values(2 outlier values detected))
SELECT DATENAME(MONTH, starttime) as [Month], AVG(tripduration) as Average_Trip_Time_Seconds
FROM citibike
GROUP BY DATENAME(MONTH, starttime)


--- Answer 4:
-- Find out the most popular 10 station by using WITH
-- Daily and hourly numbers of journeys starting from these 10 popular stations in 2018

WITH popular_stations AS
(
SELECT TOP 10 start_station_name, COUNT(*) as used_count
FROM citibike
GROUP BY start_station_name
ORDER BY 2 DESC
)
SELECT * 
FROM(
	SELECT c.start_station_name, DATENAME(WEEKDAY, c.starttime) [Day], DATEPART(HOUR, c.starttime) [Hour_of_Day], COUNT(*) count_used
	FROM citibike c, popular_stations p
	WHERE c.start_station_name=p.start_station_name
	GROUP BY c.start_station_name, DATENAME(WEEKDAY, c.starttime), DATEPART(HOUR, c.starttime)
	) AS B
PIVOT (
		SUM(count_used)
		FOR [Day] 
		IN ([Monday],[Tuesday],[Wednesday],[Thursday],[Friday],[Saturday],[Sunday])
		) AS trip_count
ORDER BY 1,2


-- Answer 5:
-- find out the 4th most frequently traveled station with the Row_Number function.
SELECT end_station_name, count_of_trip
FROM(
SELECT end_station_name, COUNT(*) count_of_trip,
	ROW_NUMBER() OVER(ORDER BY COUNT(*) DESC) row_num
FROM citibike
GROUP BY end_station_name
) as X
WHERE row_num = 4

