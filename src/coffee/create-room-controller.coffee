angular.module("app")
.controller("CreateRoomController",
  ["$scope", "$log", "Constant", "Status", "Session", "$browser", "Rooms",
    ($scope, $log, Constant, Status, Session, $browser, Rooms) ->
      $scope.Constant = Constant
      $scope.alerts = []
      $scope.name = ""
      $scope.closeAlert = (index) -> $scope.alerts.splice index, 1
      onSuccess = (user)->
        $scope.signUp.name = user.name
      onUnauthorized = ->
        $scope.alerts.push
          type: "info"
          msg: "プロフィール更新機能は新規投稿後から有効になります。"
        $("button").addClass("disabled")
        $("input, select, textarea").attr("disabled","")
#      Users.get().$promise.then(
#        (user)-> onSuccess(user)
#        (error)-> switch error.status
#          when Status.UNAUTHORIZED
#            Session.create({id: $browser.cookies().id, password: $browser.cookies().password}).$promise.then(
#              (value)->onSuccess(value)
#              (error)-> switch error.status
#                when Status.UNAUTHORIZED then onUnauthorized()
#                when Status.BAD_REQUEST then onUnauthorized()
#            )
#      )
      $scope.submit = ()->
        $scope.form.name.$setDirty()
        $("input.ng-invalid, select.ng-invalid, textarea.ng-invalid").first().focus()
        if $scope.form.$invalid then return else ""
        $("button").button("loading")
        onComplete = -> $("button").button("reset")
        toJsonForServer = (name)-> name: name
        Rooms.create(toJsonForServer($scope.name)).$promise.then(
          (value)->
            onComplete()
            $scope.alerts.push
              type: "info"
              msg: "部屋を作成しました"
          (error)->
            onComplete()
            $scope.alerts.push
              type: "danger"
              msg: "部屋の作成に失敗しました"
        )
      $scope.cancel = ()-> $modalInstance.dismiss()
  ])
