angular.module("app")
.controller("RoomController",
  ["$rootScope", "$scope", "$modal", "$log", "$document", "$stateParams", "$window", "$anchorScroll", "$location", "$timeout",
   "User", "Talks", "Rooms", "RoomUsers", "Entries", "Session", "Constant", "Status", "Env", "$cookies", "Blacklist", "RoomsWS",
   "Whitelist", "RoomAuthorities"
    ($rootScope, $scope, $modal, $log, $document, $stateParams, $window, $anchorScroll, $location, $timeout, User, Talks, Rooms, RoomUsers, Entries, Session, Constant, Status, Env, $cookies, Blacklist, RoomsWS, Whitelist, RoomAuthorities) ->
      $('[data-toggle="tooltip"]').tooltip()
      webSocket = null
      $scope.opened = false
      $scope.error = false
      $scope.errors = []
      $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams)->
        if toState.url is "/" and webSocket? then webSocket.close()
      resizeMediaListTalks = ->
        mediaListTalksHeight = ->
          panelTalksHeight = ->
            panelTalksMargin = parseInt($(".panel-talks").css("marginBottom").replace('px',
              '')) + parseInt($(".panel-talks").css("marginTop").replace('px', ''))
            parseInt($window.innerHeight - $(".navbar").outerHeight(true) - panelTalksMargin)
          h90 = parseInt($(".panel.panel-talks").css("borderTopWidth"))
          h91 = parseInt($(".panel.panel-talks").css("borderBottomWidth"))
          h0 = parseInt($(".panel-body").css("paddingTop"))
          # panel-bodyのpaddingBottom
          h1 = parseInt($(".panel-body").css("paddingBottom"))
          # ulのmarginBottom
          h2 = parseInt($(".media-list-talks").css("marginBottom"))
          # 入力部分
          h3 = $(".panel-talks form").outerHeight(true)
          panelTalksHeight() - h90 - h91 - h0 - h1 - h2 - h3 - 5
        $scope.mediaListTalksStyle =
          height: "#{mediaListTalksHeight()}px"
      $scope.talkStyle = (talk)->
        color: '#' + talk.color
      $scope.userStyle = (user)->
        color: '#' + user.color
      scrollBottom = ->
        $(".media-list-talks").height() - $(".talks-container").height() - $(".talks-container").scrollTop()
      scrollToBottom = ->
        $(".talks-container").scrollTop($(".media-list-talks").outerHeight(true))
      $scope.$on 'resize::resize', (event)-> resizeMediaListTalks()
      resizeMediaListTalks()
      cookieInit = ->
        unless $cookies.get("color")? then $cookies.put("color", "000000")
        unless $cookies.get("name")? then $cookies.put("name", "ゲスト#{Math.floor((Math.random() * 10))}#{Math.floor((Math.random() * 10))}#{Math.floor((Math.random() * 10))}")
      cookieInit()
      $scope.color = $cookies.get("color")
      $scope.Constant = Constant
      $scope.users = []
      $scope.user = {}
      $scope.room = {}
      $scope.talk = ""
      $scope.alerts = []
      $scope.signUp = {}
      $scope.signUp.name = ""
      $scope.shouldSignUp = false
      $scope.myFilter = (user) -> !$scope.isOwner(user)
      $scope.hasAuthority = (user) ->
        _.contains(_.chain($scope.room.authorities).map((x)-> x.user_id).uniq().value(), user.id)
      $scope.hasAuthority0 = ->
        _.contains(_.chain($scope.room.authorities).map((x)-> x.user_id).uniq().value(), parseInt($cookies.get("id")))
      $scope.openModal = ->
        $scope.user.roles = _.chain($scope.room.authorities).map((x)-> x.user_id).uniq().value()
        $scope.roomName = $scope.room.name
        $scope.limit = $scope.room.limit
        $scope.locked = $scope.room.locked
        Blacklist.query(id: $stateParams.id).$promise.then((x)->
          $scope.blacklist = x
        )
        Whitelist.query(id: $stateParams.id).$promise.then((x)->
          $scope.whitelist = x
        )
        RoomAuthorities.query(id: $stateParams.id).$promise.then((x)->
          $scope.roomAuthorities = x
        )
        $("#myModal").modal()
        false
      $scope.hide = ->
        $scope.showUpdateProfile = false
      $scope.show = ->
        $scope.showUpdateProfile = true
      $scope.showRoomProfile = true
      $scope.closeAlert = (index) -> $scope.alerts.splice index, 1
      $scope.click = (room)-> post(room)
      $scope.ban = (user)->
        RoomUsers.delete({roomId: $stateParams.id, userId: user.id}).$promise.then((x)->
          Blacklist.create({id: $stateParams.id}, user).$promise.then((y)->
            console.log "ok"
          )
        )
      $scope.submitRoom = (form)->
        room = {}
        room.name = form.roomName.$viewValue
        room.limit = form.limit.$viewValue
        room.locked = form.locked.$viewValue
        room.authorities = form.authorities?= []
        Rooms.update(id: $stateParams.id, room).$promise.then((x)->
          Rooms.get({id: $stateParams.id}).$promise.then((x)->
            $("#myModal").modal('hide')
          )
        )
      $scope.submitAuthorities = (form)->
        room = {}
        room.authorities = form.authorities?= []
        Rooms.update(id: $stateParams.id, room).$promise.then((x)->
          Rooms.get({id: $stateParams.id}).$promise.then((x)->
            $("#myModal").modal('hide')
          )
        )
      $scope.submitBlacklist = (form)->
        Blacklist.update(id: $stateParams.id, ids: if form.ids? then form.ids else []).$promise.then((x)->
          $("#myModal").modal('hide')
        )
      $scope.submitWhitelist = (form)->
        Whitelist.update(id: $stateParams.id, ids: if form.ids? then form.ids else []).$promise.then((x)->
          $("#myModal").modal('hide')
        )
      $scope.submitUser = (form)->
        user = {}
        user.name = form.name.$viewValue
        user.color = form.color.$viewValue
        User.update(user).$promise.then((x)->
          User.get().$promise.then((x)->
            $scope.name = x.name
            $scope.color = x.color
            $cookies.put("color", x.color)
            $scope.showUpdateProfile = false
          )
        )
      $scope.submitTalk = (talk)->
        text = $scope.talk.text
        $scope.talk.text = ""
        object =
          t: "talk"
          data:
            user:
              name: $cookies.get('name')
            talk:
              text: text
              color: "##{$scope.color}"
        webSocket.send(JSON.stringify(object))
      $scope.messages = []
      $scope.isOwner = (user)->
        $scope.room.user_id is user.id
      $scope.hasOwner = ->
        $scope.room.user_id is parseInt($cookies.get('id'))
      $scope.isSelf = (user)-> user.id is parseInt($cookies.get('id'))
      connect = ->
        WebSocket = window.WebSocket || window.MozWebSocket
        webSocket = new WebSocket("#{Env.SOCKET_PROTOCOL}://#{Env.SOCKET_HOST_NAME}:#{Env.SOCKET_HOST_PORT}/rooms/ws/#{$stateParams.id}")
        webSocket.onclose = ()->
          console.log "onclose"
          $scope.opened = false
          $scope.$apply()
        webSocket.onerror = (e)-> console.log e
        webSocket.onmessage = (d)->
          console.log "onmessage"
          json = JSON.parse(d.data)
          console.log json
          switch json.t
            when "room"
              $scope.room = json.data
            when "talk"
# 最新のtalksをdomに適用した後だと複数件のtalks追加があった場合100px以上のスクロールが発生し過去ログ閲覧状態だと判定されるため、問い合わせ開始時に過去ログを閲覧しているかを判定しておく必要がある。
              scrollToBottomWhenDidNotScroll = if scrollBottom() < 100 then scrollToBottom else ->
              $scope.messages.push(json)
              $scope.$apply()
              $timeout(scrollToBottomWhenDidNotScroll, 0)
            when "join"
              $scope.messages.push(json)
              $scope.users = json.data.users
              $scope.user = _.filter(json.data.users, (x)-> x.id is parseInt($cookies.get('id')))[0]
              $scope.$apply()
            when "quit"
              $scope.messages.push(json)
              $scope.users = json.data.users
              $scope.user = _.filter(json.data.users, (x)-> x.id is parseInt($cookies.get('id')))[0]
              $scope.$apply()
            when "update_user"
              $scope.messages.push(json)
              $scope.users = json.data.users
              $scope.user = _.filter(json.data.users, (x)-> x.id is parseInt($cookies.get('id')))[0]
              $scope.$apply()
            when "update_user_name"
              $scope.messages.push(json)
              $scope.users = json.data.users
              $scope.user = _.filter(json.data.users, (x)-> x.id is parseInt($cookies.get('id')))[0]
              $scope.$apply()
            when "update_room_owner"
              $scope.messages.push(json)
              $scope.users = json.data.users
              $scope.user = _.filter(json.data.users, (x)-> x.id is parseInt($cookies.get('id')))[0]
              $scope.room = json.data.room
              $scope.$apply()
            when "update_room_name"
              $scope.messages.push(json)
              $scope.users = json.data.users
              $scope.user = _.filter(json.data.users, (x)-> x.id is parseInt($cookies.get('id')))[0]
              $scope.room = json.data.room
              $scope.$apply()
            when "update_room_limit"
              $scope.messages.push(json)
              $scope.users = json.data.users
              $scope.user = _.filter(json.data.users, (x)-> x.id is parseInt($cookies.get('id')))[0]
              $scope.room = json.data.room
              $scope.$apply()
        webSocket.onopen = ()->
          $scope.opened = true
          $scope.error = false
          $scope.$apply()
          console.log "onopen"
      onConnectBadRequst = (error) ->
        $scope.error = true
        console.log "ぶろっく"
        $scope.errors = error.data.errors
      entry = ->
        userObj = -> id: $cookies.get('id'), password: $cookies.get('password')
        createUser = (onSuccess)-> User.create().$promise.then(onSuccess).catch(console.log)
        users = (onSuccess, onError) -> User.get().$promise.then(onSuccess).catch(onError)
        roomWs = (onSuccess, onError) -> RoomsWS.get(id: $stateParams.id).$promise.then(onSuccess).catch(onError)
        sessions = (onSuccess, onError)-> Session.create(userObj()).$promise.then(onSuccess).catch(onError)
        users(roomWs(connect, onConnectBadRequst), -> sessions(entry, -> createUser(entry)))
      entry()
      $scope.submit = ()->
        toJsonForServer = (signUp)->
          name: signUp.name
          sex: signUp.sex
          prefecture: signUp.prefecture
          bio: signUp.bio
        $scope.form.name.$setDirty()
        $scope.form.sex.$setDirty()
        $scope.form.prefecture.$setDirty()
        $scope.form.bio.$setDirty()
        $("input.ng-invalid, select.ng-invalid, textarea.ng-invalid").first().focus()
        if $scope.form.$invalid then return else ""
        $("button").button("loading")
        onComplete = -> $("button").button("reset")
        User.post(toJsonForServer($scope.signUp)).$promise.then((x)->
          Session.create({id: $cookies.get('id'), password: $cookies.get('password')}).$promise.then((x)->
            $scope.shouldSignUp = false
            entry()
          )
        ).catch((x)->
          onComplete()
          console.log error
        )
  ])
