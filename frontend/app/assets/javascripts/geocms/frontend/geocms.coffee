geocms = angular.module( 'geocms', [
  'ui.router'
  'restangular'
  'ui.slider'
  'ui.tree'
  'ui.bootstrap'
  'ui.bootstrap.extras'
  'ui.geocms.textselect'
  'ng.enter'
  'ngAnimate'
  'wu.masonry'
  'toaster'
  'geocms.contexts'
  'geocms.folders'
  'geocms.map'
  'geocms.cart'
  'geocms.catalogserv'
  'geocms.catalog'
  'geocms.map_options'
])

geocms.config [
  "$httpProvider",
  "$stateProvider",
  "$locationProvider",
  "$urlRouterProvider",
  "RestangularProvider",

  ( $httpProvider,
    $stateProvider,
    $locationProvider,
    $urlRouterProvider,
    RestangularProvider ) ->

    #$locationProvider.html5Mode(true)
    # RestangularProvider.setDefaultHttpFields({cache: true});
    $locationProvider.html5Mode({
      enabled: true,
      requireBase: false
    });
    $urlRouterProvider.when(config.prefix_uri+'', config.prefix_uri+'/maps');
    $urlRouterProvider.when(config.prefix_uri+'/', config.prefix_uri+'/maps');

    _.templateSettings =
      interpolate: /\{\{(.+?)\}\}/g

]

geocms.run [
  "Restangular"
  "mapService"
  "$rootScope"
  (Restangular, mapService, $root) ->
    Restangular.setBaseUrl(config.prefix_uri+"/api/v1")
    Restangular.setDefaultHeaders({'X-CSRF-Token': $('meta[name="csrf-token"]'). attr('content')});
    $root.config = config
    # TODO: find a better way
    # This is a little hacky
    # Before sending the object to the server i need to wrap it in an object
    # of the same name
    # eg : context: { attr1: ..., attr2: ... } instead of { attr1: ..., attr2: ... }
    # by default restangular sends it as a hash with the attributes, which is not
    # what rails strong parameters expect
    # if you find a way around it you can delete undescore singularize which is only
    # used here.
    Restangular.addRequestInterceptor (element, operation, what, url) ->
      obj = {}
      obj[_.singularize(what)] = element
      element = obj
]

geocms.controller 'CategoriesPagination', ($scope) -> 
  $scope.currentPage = 0
  $scope.pageSize = 20
  $scope.numberOfPages = ->
    res = Math.ceil $scope.catalog.categories.length / $scope.pageSize
    if res < 1
      return 1
    else
      return res 

geocms.controller 'LayersPagination', ($scope) -> 
  $scope.currentPage = 0
  $scope.pageSize = 20
  $scope.numberOfPages = ->
    res = Math.ceil $scope.catalog.layers.length / $scope.pageSize
    if res < 1
      return 1
    else
      return res 

geocms.filter 'startFrom', ->
  (input, start) ->
    start = +start
    #parse to int
    input.slice start
