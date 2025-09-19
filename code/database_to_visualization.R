#### set-up ####

# load packages
library(tidyverse)

# download monitoring station list
stations <- read_delim("https://wiskiweb01.pca.state.mn.us/KiWIS/KiWIS?datasource=0&service=kisters&type=queryServices&request=getStationList&format=csv&stationgroup_id=3571011&returnfields=station_name,station_no,station_latitude,station_longitude",
                       delim = ";")