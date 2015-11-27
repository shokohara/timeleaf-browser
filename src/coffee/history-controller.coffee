angular.module("app")
.controller("HistoryController",
  ["$scope", "Status", "Session", "$browser", "History", "Notes",
    ($scope, Status, Session, $browser,  History, Notes) ->
      $scope.alerts = []
      $scope.closeAlert = (index) -> $scope.alerts.splice index, 1
      onSuccess = (tweets)-> $scope.tweets = tweets
      onUnauthorized = () ->
        $scope.alerts.push
          type: "info"
          msg: "投稿履歴機能は新規投稿後から有効になります。"
      $scope.tweets = History.query().$promise.then(
        (user)-> onSuccess(user)
        (error)-> switch error.status
          when Status.UNAUTHORIZED
            Session.create({id: $browser.cookies().id, password: $browser.cookies().password}).$promise.then(
              (value)-> onSuccess(value)
              (error)-> switch error.status
                when Status.UNAUTHORIZED then onUnauthorized()
                when Status.BAD_REQUEST then onUnauthorized()
            )
      )
      $scope.remove = (tweet)->
        Notes.remove(id: tweet.id).$promise.then(
          (value)-> $scope.tweets = History.query()
          (error)-> console.log error
        )
      $scope.copy = (tweet)->
        new Notes({text: tweet.text}).$save().then(
          (value)->
            $scope.alerts = []
            $scope.tweets = History.query()
          (error)-> switch error.status
            when Status.TOO_MANY_REQUEST
              $scope.alerts = []
              $scope.alerts.push
                type: "warning"
                msg: _.reduce(error.data.errors, (x, y)-> x + "\n" + y)
        )
])
