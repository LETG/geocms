catalogModule = angular.module "geocms.catalogserv", ["restangular", "geocms.cart"]

catalogModule.service "catalogService", 
[
  "Restangular",
  "$state",
  "$rootScope",
  (Restangular, $state, $rootScope) ->
    
    Catalog = ->
      @currentCategory = null
      @categoryTree = []
      @categories = []
      @layers = []
      @query = null
      @selectAllButtonText = null
      return

    Catalog::getCategory = (category) ->
      return if @currentCategory == category
      @currentCategory = category
      @breadcrumb(category)
      that = this
      Restangular.one("categories", category.id).get().then (category) ->
        that.categories = category.children
        that.layers = category.layers
      return

    Catalog::addToCart = (id, cart) ->
      if @isOnCart(id, cart) then cart.remove(cart.get(id)) else cart.add(id)
      return

    Catalog::selectAllCheckboxes = (cart, layers, currentPage, pageSize) ->
      startIndex = currentPage * pageSize
      endIndex = startIndex + pageSize
      layersToSelect = layers.slice(startIndex, endIndex)

      # If first layer is not in card, then we should add all
      shouldAddAll = !@isOnCart(layers[0].layer_id, cart)

      if shouldAddAll
        @selectAllButtonText = "select_all"
      else
        @selectAllButtonText = "unselect_all"

      for layer in layersToSelect
        if shouldAddAll && !@isOnCart(layer.layer_id, cart)
          cart.add(layer.layer_id)
        else if !shouldAddAll && @isOnCart(layer.layer_id, cart)
          cart.remove(cart.get(layer.layer_id))

      return

    Catalog::updateLayersPerPage = (currentPage, pageSize) ->
      $rootScope.$broadcast('pageSizeUpdated', pageSize)
      return

    Catalog::isOnCart = (id, cart) ->
      if _.findWhere(cart.layers, {layer_id: id}) then true else false

    Catalog::roots = ->
      that = this
      Restangular.all("categories").getList().then (categories) ->
        that.categories = categories
      return

    Catalog::breadcrumb = (category) ->
      index = @categoryTree.indexOf(category)
      if index > -1
        @categoryTree.splice(index+1, Number.MAX_VALUE)
      else
        @categoryTree.push category
      return

    Catalog::goToRoot = ->
      return @close() unless @categoryTree.length > 0 or @query?
      @categoryTree = []
      @layers = []
      @categories = []
      @query = null
      @roots()

    Catalog::search = ->
      that = this
      Restangular.all("layers").customGET("search", { q: @query }).then (response) ->
        that.layers = response.layers
        that.categories = []

    Catalog::close = ->
      open_layers = () ->
        if !document.getElementById('layers_tab').classList.contains 'active'
          $('.nav-tabs a[href="#layers"]').click();
      setTimeout(open_layers)
      $state.go "^"

    Catalog
]