angular.module("app")
.controller("NavigationBarController", ["$scope", "History", "Notes", "SharedService", ($scope, History, Notes, SharedService) ->
  $scope.navbarCollapsed = true
  $scope.post = ->
    History.query().$promise.then(
      (posts)-> SharedService.text.set(posts[0].text)
      (error)-> console.log error
    )
])
