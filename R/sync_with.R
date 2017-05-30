syncWith <- function(map, groupname) {
  invokeMethod(map, data = leaflet::getMapData(map), "syncWith", groupname)
}
