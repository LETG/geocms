baseLayerModule = angular.module "geocms.baseLayer", []

baseLayerModule.service "baseLayerService", [ ->

  baseLayerService = {}
  
  baseLayerService.getBaseLayer = ->
    switch config.crs
      when "EPSG:3857"
        baseLayer = L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager_labels_under/{z}/{x}/{y}.png', {
          attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="https://carto.com/attributions">CARTO</a>'
        })
      when "EPSG:2154"
        baseLayer = L.tileLayer.wms("https://osm.geobretagne.fr/gwc01/service/wms", {
          layers: "osm:map",
          format: 'image/png',
          transparent: true,
          continuousWorld: true,
          unloadInvisibleTiles: false,
          attribution: "Map data © OpenStreetMap contributors, CC-BY-SA"
        })
      when "EPSG:4326"
        baseLayer = L.tileLayer.wms("https://osm.geobretagne.fr/gwc01/service/wms", {
          layers: "osm:map",
          format: 'image/png',
          transparent: true,
          continuousWorld: true,
          unloadInvisibleTiles: false,
          attribution: "Map data © OpenStreetMap contributors, CC-BY-SA"
        })
    baseLayer

  baseLayerService

]
