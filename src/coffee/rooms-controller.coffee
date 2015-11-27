angular.module("app")
.controller("RoomsController",
  ["$scope", "$state", "$modal", "$log", "$q", "RoomUsers", "Entries", "Session", "Constant", "Env",
    ($scope, $state, $modal, $log, $q, RoomUsers, Entries, Session, Constant, Env) ->
      console.log Env
      $scope.Constant = Constant
      $scope.click = (room)-> $state.go("room", {id: 1})
  ])
