angular.module("app")
.controller("LobbyController",
  ["$rootScope", "$scope", "$modal", "$log", "$document", "$state", "$stateParams", "$window", "$anchorScroll",
   "$location", "$timeout", "Users", "Talks", "RoomUsers", "Entries", "Session", "Constant", "Status",
   "Env", "$browser", "SharedService",
    ($rootScope, $scope, $modal, $log, $document, $state, $stateParams, $window, $anchorScroll, $location, $timeout, Users, Talks, RoomUsers, Entries, Session, Constant, Status, Env, $browser, SharedService) ->
      webSocket = null
      $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams)->
        if toState.url is "/" then webSocket.close()
      connect = ->
        WebSocket = window.WebSocket || window.MozWebSocket
        webSocket = new WebSocket("ws://#{Env.SOCKET_HOST_NAME}:#{Env.SOCKET_HOST_PORT}/lobby")
        webSocket.onclose = (e)-> console.log "onclose"
        webSocket.onerror = (e)-> console.log "onerror"
        webSocket.onmessage = (x)-> switch JSON.parse(x.data).type
          when "quit" then $state.go("room", JSON.parse(x.data).result.room)
        webSocket.onopen = ()-> console.log "onopen"
      entry = ->
        userObj = -> id: $browser.cookies().id, password: $browser.cookies().password
        createUser = (onSuccess)-> Users.post().$promise.then(onSuccess).catch(console.log)
        users = (onSuccess, onError) -> Users.get(id: $browser.cookies().id).$promise.then(onSuccess).catch(onError)
        sessions = (onSuccess, onError)-> Session.create(userObj()).$promise.then(onSuccess).catch(onError)
        users(connect, -> sessions(entry, -> createUser(entry)))
      entry()
  ])
