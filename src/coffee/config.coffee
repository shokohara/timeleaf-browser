angular.module("app")
.config(["$stateProvider", "$urlRouterProvider", "$compileProvider", "$locationProvider", ($stateProvider, $urlRouterProvider, $compileProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)
  $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|skype):/)
  $urlRouterProvider.otherwise("/")
  $stateProvider
  .state "top",
    url: "/"
    templateUrl: "template/rooms.html"
    controller: "RoomsController"
  .state "lobby",
    url: "/lobby"
    templateUrl: "template/lobby.html"
    controller: "LobbyController"
  .state "room",
    url: "/rooms/{id}"
    templateUrl: "template/room.html"
    controller: "RoomController"
  .state "users/update",
    url: "/users/update"
    templateUrl: "template/profile.html"
    controller: "ProfileController"
  .state "sign-up",
    url: "/sign-up"
    templateUrl: "template/sign-up.html"
    controller: "SignUpController"
  .state "history",
    url: "/history"
    templateUrl: "template/history.html"
    controller: "HistoryController"
  .state "filter",
    url: "/filter"
    templateUrl: "template/filter.html"
    controller: "SearchController"
  .state "search",
    url: "/search"
    templateUrl: "template/search.html"
    controller: "SearchController"
])
.config ["$httpProvider", ($httpProvider) ->
  $httpProvider.defaults.withCredentials = true
#  $httpProvider.defaults.useXDomain = true
#  delete $httpProvider.defaults.headers.common['X-Requested-With']
#  $httpProvider.interceptors.push("httpInterceptor")
]
