library(leaflet)
library(sf)

my_depid <- "09977"

show_leaflet_mydep <- function(my_depid = "10097"){
  if(!exists("mvdepressions_4326")){
    mvdepressions_4326 <- sf::st_read("/nfs/khondula-data/planetmethane/polygons/mvdepressions.shp") %>%
    st_transform(4326)}
  # AOI <- st_read("/nfs/khondula-data/planetmethane/polygons/AOI_union.shp")
  
  if(!exists("mvdepressions_centroids")){
    mvdepressions_centroids <- st_centroid(mvdepressions_4326)}
  
  mvdeps_polygons_sf <- st_read("/nfs/khondula-data/planetmethane/polygons/mvdeps_buff20_inNLCD.shp")

  
  mydepression <- filter(mvdepressions_4326, dep_id %in% my_depid)
  mydepression_buff20 <- filter(mvdeps_polygons_sf, dep_id %in% my_depid) %>%
    st_transform(4326)
  
  my_dep_centroid <- mvdepressions_centroids %>% filter(dep_id == my_depid[1]) %>%
    st_coordinates() %>% as.data.frame()
  
  leaflet() %>%
    setView(lng = my_dep_centroid[["X"]], lat = my_dep_centroid[["Y"]], zoom = 16) %>%
    addProviderTiles(providers$Esri.WorldImagery) %>%
    # addPolygons(data = mvdepressions_4326, fillOpacity = 0, color = "yellow") %>%
    addPolygons(data = mydepression_buff20, opacity = 1, 
                color = "yellow", fillOpacity = 0, weight = 1, 
                label = ~as.character(dep_id), group = "buffered") %>%
    addPolygons(data = mydepression, opacity = 1, 
                color = "orange", fillColor = "yellow", weight = 0.5,
                label = ~as.character(dep_id), group = "polygon") %>%
    addPolygons(data = st_transform(mvdeps_polygons_sf, 4326), group = "all mvdeps",
                label = ~as.character(dep_id)) %>%
    addLayersControl(overlayGroups = c("polygon", "buffered", "all mvdeps")) %>% 
    addMeasure(primaryAreaUnit = "sqmeters", primaryLengthUnit = "meters") %>%
    hideGroup("all mvdeps")
  
}

show_leaflet_mydep(my_depid = c("10112"))
show_leaflet_mydep(my_depid = c("00413"))


