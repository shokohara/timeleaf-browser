angular.module("app")
.factory("SharedService",
  ["$rootScope", ($rootScope)->
    signUp =
      name: ""
      text: ""
      sex: ""
      prefecture: ""
    signUp:
      get: ()-> signUp
      set: (s)-> signUp = s
    text = ""
    text:
      get: ()-> text
      set: (t)->
        text = t
        $rootScope.$broadcast("post")
]).factory("User", ["$resource", "Env", ($resource, Env) ->
  $resource "//#{Env.API_HOST_NAME}:#{Env.API_HOST_PORT}/user", null,
    "create":
      method: "POST"
    "update":
      method: "PUT"
]).factory("Users", ["$resource", "Env", ($resource, Env) ->
  $resource "//#{Env.API_HOST_NAME}:#{Env.API_HOST_PORT}/users/:id", null,
    "create":
      method: "POST"
    "update":
      method: "PUT"
]).factory("Rooms", ["$resource", "Env", ($resource, Env) ->
  $resource "//#{Env.API_HOST_NAME}:#{Env.API_HOST_PORT}/rooms/:id", null,
    "create":
      method: "POST"
    "update":
      method: "PUT"
]).factory("Authorities", ["$resource", "Env", ($resource, Env) ->
  $resource "//#{Env.API_HOST_NAME}:#{Env.API_HOST_PORT}/rooms/:id", null,
    "update":
      method: "PUT"
]).factory("RoomsWS", ["$resource", "Env", ($resource, Env) ->
  $resource "//#{Env.API_HOST_NAME}:#{Env.API_HOST_PORT}/rooms/wss/:id", null
]).factory("RoomUsers", ["$resource", "Env", ($resource, Env) ->
  $resource "//#{Env.API_HOST_NAME}:#{Env.API_HOST_PORT}/rooms/:roomId/users/:userId", null,
    "create":
      method: "POST"
    "update":
      method: "PUT"
    "delete":
      method: "DELETE"
]).factory("RoomAuthorities", ["$resource", "Env", ($resource, Env) ->
  $resource "//#{Env.API_HOST_NAME}:#{Env.API_HOST_PORT}/rooms/:id/authorities", null,
    "create":
      method: "POST"
    "update":
      method: "PUT"
]).factory("Blacklist", ["$resource", "Env", ($resource, Env) ->
  $resource "//#{Env.API_HOST_NAME}:#{Env.API_HOST_PORT}/rooms/:id/blacklist", null,
    "create":
      method: "POST"
]).factory("Whitelist", ["$resource", "Env", ($resource, Env) ->
  $resource "//#{Env.API_HOST_NAME}:#{Env.API_HOST_PORT}/rooms/:id/whitelist", null,
    "create":
      method: "POST"
]).factory("Notes", ["$resource", "Env", ($resource, Env) ->
  $resource "//#{Env.API_HOST_NAME}:#{Env.API_HOST_PORT}/posts", null
]).factory("History", ["$resource", "Env", ($resource, Env) ->
  $resource "//#{Env.API_HOST_NAME}:#{Env.API_HOST_PORT}/users/posts", null
]).factory("Session", ["$resource", "Env", ($resource, Env) ->
  $resource "//#{Env.API_HOST_NAME}:#{Env.API_HOST_PORT}/session", null,
    "create":
      method: "POST"
    "delete":
      method: "DELETE"
]).factory("Talks", ["$resource", "Env", ($resource, Env) ->
  $resource "//#{Env.API_HOST_NAME}:#{Env.API_HOST_PORT}/rooms/:id/talks", {id:'@id'}, null
]).factory("RoomUsers", ["$resource", "Env", ($resource, Env) ->
  $resource "//#{Env.API_HOST_NAME}:#{Env.API_HOST_PORT}/rooms/:id/users", null
]).factory("Entries", ["$resource", "Env", ($resource, Env) ->
  $resource "//#{Env.API_HOST_NAME}:#{Env.API_HOST_PORT}/entries", null
])
#.factory "httpInterceptor", ["$injector", "$q", "$activityIndicator", ($injector, $q, $activityIndicator) ->
#  responseError: (rejection) ->
#    switch rejection.status
#      when 401
#        console.log "401"
#    return $q.reject(rejection)
#]
