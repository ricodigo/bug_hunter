var dependecies = ["ui.bootstrap.accordion", "ui.bootstrap.tooltip", "bug_model"]
var app = angular.module("app", dependecies);

app.config(function ($routeProvider) {
  $routeProvider.when('/',
    {
      templateUrl: "/template/errors_index_view.html",
      controller: "ErrorCtrl"
    }
  )
  $routeProvider.when('/errors/:id',
    {
      templateUrl: "/template/errors_show_view.html",
      controller: "ErrorShowCtrl"
    }
  )
})

angular.module("bug_model", ["ngResource"]).factory("Bug", function($resource) {
  var Bug;
  Bug = $resource("/errors/:id", {
    format: "json"
  }, {
    update: {
      method: "PUT"
    }
  });
  return Bug;
});

app.controller("ErrorCtrl", function($scope, $location, $routeParams, $http, Bug) {
  $scope.title = "List errors";
  $scope.errors = Bug.query();
  $scope.messageTitle = function(error) {
    if(error.file) {
      return error.file;
    } else {
      var url = error.url;
      if (url.length > 100) {
        url = error.url.slice(0,100);
        url += "...";
      }
      return 'Slow request '+ url;
    }
  }
});

app.controller("ErrorShowCtrl", function($scope, $location, $routeParams, $http, Bug) {
  $scope.error = Bug.get($routeParams);
});

