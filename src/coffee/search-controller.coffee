angular.module("app")
.controller("SearchController",
  ["$scope", "$modal", "$log", "$document", "Notes", "Session", "Constant", "Status", "$browser", "SharedService",
    ($scope, $modal, $log, $document, Notes, Session, Constant, Status, $browser, SharedService) ->
      newerLoading = false
      olderLoading = false
      $scope.Constant = Constant
      $scope.query = {}
      $scope.query.sex = {}
      $scope.query.prefecture = {}
      $scope.alerts = []
      $scope.closeAlert = (index) -> $scope.alerts.splice index, 1
      $scope.submit = ()-> post($scope.todoText)
      $scope.open = (onSuccess, onFailure)->
        modalInstance = $modal.open({
          templateUrl: "template/sign-up.html",
          controller: "SignUpController",
          resolve: {
            items: ()-> $scope.todoText
          }
        })
        modalInstance.result.then(
          (result)-> onSuccess(result)
          (reason)-> onFailure(reason)
        )
      $scope.newerLoad = -> loadLatest()
      updateNewerLoaderState = (loading) ->
        $scope.newerButtonText = if loading then "更新中" else "更新"
        $scope.newerDisabled = if loading then "disabled" else ""
        $scope.newerSpin = if loading then "fa-spin" else ""
      updateOlderLoaderState = (loading) ->
        $scope.olderButtonText = if loading then "読込中" else "読込"
        $scope.olderButtonClass = if loading then "" else "hidden"
        $scope.olderDisabled = if loading then "disabled" else ""
        $scope.olderSpin = if loading then "fa-spin" else ""
      updateOlderLoaderState(false)
      loadLatest = ->
        maxId = _.chain($scope.posts).pluck("id").max().value()
        obj = {since_id: maxId, count: 20, sexes: sexes(), prefectures: prefectures(), name: $scope.name, skype_id: $scope.skypeId, text: $scope.text}
        newerLoading = true
        updateNewerLoaderState(true)
        Notes.query(obj).$promise.then(
          (notes)->
            $scope.posts = notes.concat($scope.posts)
            newerLoading = false
            updateNewerLoaderState(false)
          (error)->
            newerLoading = false
            updateNewerLoaderState(false)
        )
      post = (text)->
        new Notes({text: text}).$save().then(
          (value)->
            $scope.alerts = []
            $scope.todoText = ""
            loadLatest()
          (error)-> switch error.status
            when Status.UNAUTHORIZED
              Session.create({id: $browser.cookies().id, password: $browser.cookies().password}).$promise.then(
                (value)-> post(text)
                (error)->
                  if error.status is Status.UNAUTHORIZED or Status.BAD_REQUEST
                    $scope.open(
                      (result)->
                        $scope.todoText = result
                        $scope.submit()
                      (reason)-> console.log reason
                    )
              )
            when Status.TOO_MANY_REQUEST
              $scope.alerts = []
              $scope.alerts.push
                type: "warning"
                msg: _.reduce(error.data.errors, (x, y)-> x + "\n" + y)
        )
      sexes = -> _.values($scope.query.sex).filter((x)-> x)
      prefectures = -> _.values($scope.query.prefecture).filter((x)-> x)
      Mousetrap.bind(".", ()-> loadLatest())
      $scope.open = (onSuccess, onFailure)->
        modalInstance = $modal.open({
          templateUrl: "template/sign-up.html",
          controller: "SignUpController",
          resolve: {
            items: ()-> $scope.todoText
          }
        })
        modalInstance.result.then(
          (result)-> onSuccess(result)
          (reason)-> onFailure(reason)
        )
      watch = (newValue, oldValue)->
        newerLoading = true
        updateNewerLoaderState(true)
        Notes.query({sexes: sexes(), prefectures: prefectures(), name: $scope.query.name, skype_id: $scope.query.skypeId, text: $scope.query.text}).$promise.then(
          (notes)->
            newerLoading = false
            updateNewerLoaderState(false)
            $scope.posts = notes
          (error)->
            newerLoading = false
            updateNewerLoaderState(false)
        )
      $scope.textLength = (text) -> twttr.txt.getTweetLength(text)
      $scope.$on "post", (a)-> post(SharedService.text.get())
      $document.on "scroll", ($element) ->
        scrollHeight = $(document).height()
        scrollPosition = $(window).height() + $(window).scrollTop()
        if ((scrollHeight - scrollPosition) / scrollHeight <= 0.10 && !olderLoading)
          minId = _.chain($scope.posts).pluck("id").min().value()
          obj = {since_id: 0, count: 20, max_id: minId - 1, sexes: sexes(), name: $scope.name, skype_id: $scope.skypeId, text: $scope.text}
          olderLoading = true
          updateOlderLoaderState(true)
          Notes.query(obj).$promise.then(
            (notes)->
              $scope.posts = $scope.posts.concat(notes)
              olderLoading = false
              updateOlderLoaderState(false)
            (error)->
              olderLoading = false
              updateOlderLoaderState(false)
          )
      $scope.$watch "query", watch, true
      $scope.focus = ()->
        $("#f0").hide()
        $("#f1").show()
        $("#ff1").focus()
        false
      $scope.blur = ()->
        $("#f0").show()
        $("#f1").hide()
        false
      $scope.blur()
])
