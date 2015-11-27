angular.module("app").directive 'resize', ($rootScope, $window) ->
  link: (scope) ->
    angular.element($window).on 'resize', (e) ->
      $rootScope.$broadcast 'resize::resize'
