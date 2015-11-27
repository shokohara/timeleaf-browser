angular.module("app")
.controller("SignUpController",
  ["$scope", "$log", "$browser", "$modalInstance", "items", "SharedService", "Constant", "Users", "Session",
    ($scope, $log, $browser, $modalInstance, items, SharedService, Constant, Users, Session) ->
      $scope.Constant = Constant
      toJsonForServer = (signUp)->
        name: signUp.name
        sex: signUp.sex
        prefecture: signUp.prefecture
      $scope.signUp = {}
      $scope.signUp.text = items
      $scope.signUp.name = ""
      $scope.submit = ()->
        $scope.form.name.$setDirty()
        $scope.form.sex.$setDirty()
        $scope.form.prefecture.$setDirty()
        $scope.form.text.$setDirty()
        $("input.ng-invalid, select.ng-invalid, textarea.ng-invalid").first().focus()
        if $scope.form.$invalid then return else ""
        $("button").button("loading")
        onComplete = -> $("button").button("reset")
        Users.post(toJsonForServer($scope.signUp)).$promise.then(
          (value)->
            Session.create({id: $browser.cookies().id, password: $browser.cookies().password}).$promise.then(
              (value)->
                onComplete()
                $modalInstance.close($scope.signUp.text)
              (error)->
                onComplete()
                console.log error
            )
          (error)->
            onComplete()
            console.log error
        )
      $scope.cancel = ()-> $modalInstance.dismiss()
])
