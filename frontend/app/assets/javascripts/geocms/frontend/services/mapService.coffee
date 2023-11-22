mapModule = angular.module "geocms.map", ["geocms.plugins", "geocms.projections", "geocms.baseLayer"]

mapModule.service "mapService",
  [
    "pluginService",
    "$http",
    "projectionService",
    "baseLayerService",
    "$rootScope",
    "$compile",
    "$filter",
    "$state"
    (pluginService, $http, projections, baseLayerService, $root, $compile, $filter, $state) ->

      mapService = {}

      mapService.container = null
      mapService.layers = []
      mapService.crs = null
      mapService.fullscreen = false

      mapService.createMap = (id, lat, lng, zoom, pluginParams) ->
        options = { zoomControl: false, crs: projections.getCRS(config.crs)}
        @container = new L.Map(id, options).setView([lat, lng], zoom)
        @container.attributionControl.setPrefix("Built with <a href='https://github.com/LETG/geocms'>GeoCMS</a>")
        pluginService.addPlugins(@container, pluginParams)
        @addEventListener()

      mapService.addBaseLayer = () ->
        baseLayer = baseLayerService.getBaseLayer()
        baseLayer.addTo(@container)

      mapService.addLayer = (layer) ->
        layer.opacity = 90 unless layer.opacity?

        tile_layer_type = if layer.single_tiled then L.nonTiledLayer.wms else L.tileLayer.wms

        layer._tilelayer = tile_layer_type layer.data_source_wms,
          layers: layer.name,
          format: 'image/png',
          transparent: true,
          version: layer.data_source_wms_version,
          styles: layer.default_style || '',
          continuousWorld: true,
          tiled: layer.tiled,
          maxZoom: layer.max_zoom,
          minZoom: 3,
          opacity: (layer.opacity / 100),
          zIndex: layer.position + 1,
          pane: 'tilePane',
        layer._tilelayer.addTo(@container)
        layer.onMap = true
        layer

      mapService.importCenter = ->
        {
          center: @container.getCenter()
          zoom: @container.getZoom()
          bounds: @container.getBounds()
        }

      mapService.invalidateMap = () ->
        @container.invalidateSize()

      mapService.addEventListener = () ->
        @container.addEventListener('click', @queryLayer, mapService)

      mapService.queryLayer = (e) ->
        html = '<div ng-include="\''+config.prefix_uri+'/templates/layers/popup.html\'"></div>'
        scope = $root.$new()
        linkFunction = $compile(html)
        @currentPosition = e.latlng
        @layerPoint = e.layerPoint
     
        # @container.setView(@currentPosition)
        scope.ms = this
        scope.filteredLayers = $filter('filter')(scope.cart.layers, scope.ms.greaterThan('opacity', 0))
        scope.filteredLayers = $filter('filter')(scope.filteredLayers, scope.ms.containsPoint())
        scope.filteredLayers = $filter('filter')(scope.filteredLayers, scope.ms.queryableLayer())

        if scope.filteredLayers.length == 1
          scope.ms.chooseLayer(scope.filteredLayers[0])
          @container.on('popupclose', (e) -> scope.$destroy())
          scope.$apply()
        else if scope.filteredLayers.length <= 10
          # if there is more than 10 layers
          container = @container
          currentPosition = @currentPosition

          # another popup is used
          html = '<div ng-include="\''+config.prefix_uri+'/templates/layers/popup_with_data.html\'"></div>'
          linkFunction = $compile(html)

          # Data is retrieved for each layer
          # If no data, then layer is removed from the list of layers
          # If else, data is stored inside layer object
          Promise.all(scope.filteredLayers.map((layer) ->
            mapService.getLayerData(layer)
              .then (result) ->
                data = result.data
                if data.features.length <= 0
                  scope.filteredLayers.splice(scope.filteredLayers.indexOf(layer), 1)
                else
                  scope.filteredLayers[scope.filteredLayers.indexOf(layer)].data = data
              .catch (error) ->
                console.error("Error: #{error}")
          ))
          .then ->
            if scope.filteredLayers.length == 1
              # If only 1 layer is present after filter, we directly show it with preloaded data
              scope.ms.chooseLayerWithData(scope.filteredLayers[0])
            else if scope.filteredLayers.length > 1
              # If else, then we show the popup but on click on the layer, data is pre loaded
              L.popup({ className: "query-layer-switcher geocms-popup", autoPanPaddingTopLeft: if $state.is("contexts.show.share") then new L.Point(0,0) else new L.Point(Math.round(container.getSize().x*0.34),200)})
                .setLatLng(currentPosition)
                .setContent(linkFunction(scope)[0])
                .openOn(container)
            container.on('popupclose', (e) -> scope.$destroy())
            scope.$apply()
        else if scope.filteredLayers.length > 1
          L.popup({ className: "query-layer-switcher geocms-popup",autoPanPaddingTopLeft: if $state.is("contexts.show.share") then new L.Point(0,0) else new L.Point(Math.round(@container.getSize().x*0.34),200)})
                    .setLatLng(@currentPosition)
                    .setContent(linkFunction(scope)[0])
                    .openOn(@container)
          @container.on('popupclose', (e) -> scope.$destroy())
          scope.$apply()
    

      mapService.getLayerData = (layer) ->
        url = config.prefix_uri+"/api/v1/layers/"+layer.layer_id+"/queryable"

        that = this

        new Promise (resolve, reject) ->
          $http.get(url)
            .success (data, status, headers, config) ->
              if data.queryable
                that.currentLayer = layer
                that.getFeatureWMSData()
                  .then (featureData) ->
                    resolve(featureData)
                  .catch (error) ->
                    reject(error)
            .error (data, status, headers, config) ->
              console.error("error in mapService.getLayerData()")
              reject("Error in HTTP request")

      mapService.getFeatureWMSData = ->
        url = mapService.getWMSFeatureURL()

        $http.get(url
        ).success((data, status, headers, config) ->
          return data
        ).error (data, status, headers, config) ->

      mapService.chooseLayerWithData = (layer) ->
        L.popup({ maxWidth: 820, maxHeight: 620, className: "geocms-popup",autoPanPaddingTopLeft: if $state.is("contexts.show.share") then new L.Point(545,200) else new L.Point(545,200) })
                .setLatLng(mapService.currentPosition)
                .setContent(mapService.generateTemplate(layer.data, layer))
                .openOn(mapService.container)

      mapService.queryableLayer = ->
        (item) ->
          return item.queryable
        
      mapService.chooseLayer = (layer) ->
        url = config.prefix_uri+"/api/v1/layers/"+layer.layer_id+"/queryable"

        that = this

        $http.get(url)
        .success((data, status, headers, config) ->
          if data.queryable
            that.currentLayer = layer
            that.getFeatureWMS()
        ).error (data, status, headers, config) ->
          console.error("error in mapService.chooseLayer()")

      mapService.containsPoint = ->
        (item) ->
          bounds = (if (item.bbox? && item.bbox.length > 0) then L.latLngBounds(L.latLng(Math.floor(item.bbox[1] *100) / 100, Math.floor(item.bbox[0] *100) / 100), L.latLng(Math.ceil(item.bbox[3] *100) / 100, Math.ceil(item.bbox[2] *100)/ 100)) else null)
          return if bounds? then bounds.contains(mapService.currentPosition) else false

      mapService.getFeatureWMS = ->
        url = mapService.getWMSFeatureURL()

        $http.get(url
        ).success((data, status, headers, config) ->
          L.popup({ maxWidth: 820, maxHeight: 620, className: "geocms-popup",autoPanPaddingTopLeft: if $state.is("contexts.show.share") then new L.Point(545,200) else new L.Point(545,200) })
                .setLatLng(mapService.currentPosition)
                .setContent(mapService.generateTemplate(data))
                .openOn(mapService.container)
        ).error (data, status, headers, config) ->

      mapService.getWMSFeatureURL = () ->
        size = @container.getSize()
        position = @container.layerPointToContainerPoint(@layerPoint)
        
        time_str=''

        if @currentLayer.timelineIndex? 
          time_str = '&time='+@currentLayer.dimensions[@currentLayer.timelineIndex]

        config.prefix_uri+
        '/api/v1/data_sources/get_feature_infos'+
        '?wms_url='+@currentLayer.data_source_wms+
        '&feature_name='+@currentLayer.name+
        '&width='+size.x+
        '&height='+size.y+
        '&bbox='+@container.getBounds().toBBoxString()+
        '&current_x='+Math.round(position.x)+
        '&current_y='+Math.round(position.y)+
        time_str


        

      mapService.generateTemplate = (data, layer=null) ->
        if layer == null
          layer = @currentLayer

        _.templateSettings =
          interpolate: /\{\{(.+?)\}\}/g
        wrapper = "<div class='geocms-popup-header'><h1>"+layer.title+"</h1></div>"
        wrapper += "<div class='geocms-popup-body'>"
        if data == "null" or data.status == "failed"
          body = "<p>"+config.t.map.layer_properties_fetch_error+"</p>"
        else if data.features.length > 0
          if layer.template? and layer.template != ""
            html = layer.template
          else
            html = "<ul class='list-unstyled'>"
            _.each data.features[0].properties, (val, key) ->
              html += "<li><strong>"+key+":</strong> "+val+"</li>"
            html += "</ul>"
          template = _.template(html)
          body = template(data.features[0].properties)
        else
          body = "<p>"+config.t.map.no_point_data+"</p>"
        wrapper + body + '</div>'
      mapService
]
