angular.module("app")
.controller("ProfileController",
  ["$scope", "$log", "Upload", "Constant", "Status", "Session", "$browser", "Users",
    ($scope, $log, Upload, Constant, Status, Session, $browser, Users) ->
      $scope.Constant = Constant
      $scope.alerts = []
      $scope.signUp = {}
      $scope.signUp.text = ""
      $scope.signUp.name = ""
      $scope.closeAlert = (index) -> $scope.alerts.splice index, 1
      onSuccess = (user)->
        $scope.signUp.name = user.name
        $scope.signUp.sex = user.sex
        $scope.signUp.prefecture = user.prefecture
        $scope.signUp = user
      onUnauthorized = ->
        $scope.alerts.push
          type: "info"
          msg: "プロフィール更新機能は新規投稿後から有効になります。"
        $("button").addClass("disabled")
        $("input, select, textarea").attr("disabled","")
      Users.get(id: $browser.cookies().id).$promise.then(
        (user)-> onSuccess(user)
        (error)-> switch error.status
          when Status.UNAUTHORIZED
            Session.create({id: $browser.cookies().id, password: $browser.cookies().password}).$promise.then(
              (value)->onSuccess(value)
              (error)-> switch error.status
                when Status.UNAUTHORIZED then onUnauthorized()
                when Status.BAD_REQUEST then onUnauthorized()
            )
      )
      $scope.$watch 'files', -> if $scope.files? and $scope.files[0]? then upload $scope.files[0]

      upload = (file) ->
        Upload.upload(
          method: 'PUT'
          url: 'http://localhost:9000/users/image'
          file: file
          withCredentials: true
        ).progress((evt) ->
          progressPercentage = parseInt(100.0 * evt.loaded / evt.total)
          console.log 'progress: ' + progressPercentage + '% ' + evt.config.file.name
        ).success((data, status, headers, config) ->
          $scope.alerts.push
            type: "success"
            msg: "アイコンを更新しました"
          console.log 'file ' + config.file.name + 'uploaded. Response: ' + data
        ).error(->
          $scope.alerts.push
            type: "danger"
            msg: "アイコンの更新に失敗しました"
        )

      $scope.submit = ()->
        $scope.form.name.$setDirty()
        $scope.form.sex.$setDirty()
        $scope.form.prefecture.$setDirty()
        $("input.ng-invalid, select.ng-invalid, textarea.ng-invalid").first().focus()
        if $scope.form.$invalid then return else ""
        $("button").button("loading")
        onComplete = -> $("button").button("reset")
        toJsonForServer = (signUp)->
          name: signUp.name
          sex: signUp.sex
          prefecture: signUp.prefecture
        Users.update(toJsonForServer($scope.signUp)).$promise.then(
          (value)->
            onComplete()
            $scope.alerts.push
              type: "success"
              msg: "プロフィールを更新しました"
          (error)->
            onComplete()
            $scope.alerts.push
              type: "danger"
              msg: "プロフィールの更新に失敗しました"
        )
      $scope.cancel = ()-> $modalInstance.dismiss()
  ])
