#### set-up ####

# load packages
library(ggplot2)
library(maps)


#### station locations and IDs ####

# download monitoring station list
stations <- read.csv("https://wiskiweb01.pca.state.mn.us/KiWIS/KiWIS?datasource=0&service=kisters&type=queryServices&request=getStationList&format=csv&stationgroup_id=3571011&returnfields=station_name,station_no,station_latitude,station_longitude",
                     sep = ";")

# see locations of stations
ggplot(map_data("state", region = "Minnesota"), aes(x = long, y = lat)) +
  geom_polygon(fill = NA, color = "black") +
  geom_point(data = stations, aes(x = station_longitude, 
                                  y = station_latitude)) +
  coord_map()

# save the station ID for freese
station_freese <- "WE2000017"


#### download hydrology data ####

# available time series (this download is slow, skip to below)
# series <- read.csv("https://wiskiweb01.pca.state.mn.us/KiWIS/KiWIS?datasource=0&service=kisters&type=queryServices&request=getTimeseriesList&format=csv&stationgroup_id=3571011&returnfields=station_name,station_no,ts_id,ts_name,parametertype_name,coverage",
#                      sep = ";")

# save to data folder
# write.csv(series, file = "data/available_time_series.csv", row.names = F)

# read from data folder
series <- read.csv("data/available_time_series.csv")

# get time series ID for Freese water levels
id_freese <- series[which(series$station_no == station_freese & 
                            series$ts_name == "09.Archive"), "ts_id"]

# create URL string for station
url_freese <- paste0("https://wiskiweb01.pca.state.mn.us/KiWIS/KiWIS?datasource=0&service=kisters&type=queryServices&request=getTimeseriesValues&datasource=0&format=csv&from=2015-01-01&ts_id=",
                     id_freese,
                     "&returnfields=Timestamp,Value")
  
# download data
dat_freese <- read.csv(url_freese, sep = ";", 
                       col.names = c("time", "value"),
                       skip = 3)

# format date/time column
dat_freese$time_formatted <- as.POSIXct(dat_freese$time, tz = "UTC",
                                        format = "%Y-%m-%dT%H:%M:%S.000Z")


#### visualize ####

# visualize
ggplot(dat_freese, aes(x = time_formatted, y = value)) +
  geom_point() +
  scale_x_datetime(date_breaks = "3 months", date_labels = "%b %y")

# import ground elevation
ground <- read.csv("data/ground_elevation_20250325.csv")

# get value for freese
ground_freese <- ground[which(ground$station_no == station_freese), 
                       "ground_elev"]

# improve graph
ggplot(dat_freese, aes(x = time_formatted, y = value)) +
  geom_hline(yintercept = ground_freese) +
  geom_line(color = "cornflowerblue") +
  scale_x_datetime(date_breaks = "3 months", date_labels = "%b %y") +
  theme_minimal() +
  labs(x = "Time", y = "Wetland Water Elevation (ft)")
# see more color options here: 
# https://sape.inf.usi.ch/quick-reference/ggplot2/colour

# read more about the first 20 stations (also those with the most data) here:
# https://files.dnr.state.mn.us/eco/wetlands/wetland-hydrology-monitoring-report-2022.pdf