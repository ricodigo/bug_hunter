var dependecies = ["ui.bootstrap.accordion", "ui.bootstrap.tooltip", "bug_model"]
var app = angular.module("app", dependecies);

var prefix = document.getElementsByTagName('meta')[0]['content'];

app.config(function ($routeProvider) {
  $routeProvider.when('/',
    {
      templateUrl: prefix + "template/dashboard_view.html",
      controller: "DashboardCtrl"
    }
  )
  $routeProvider.when('/errors',
    {
      templateUrl: prefix + "template/errors_index_view.html",
      controller: "ErrorCtrl"
    }
  )
  $routeProvider.when('/errors/:id',
    {
      templateUrl: prefix + "template/errors_show_view.html",
      controller: "ErrorShowCtrl"
    }
  )
})

angular.module("bug_model", ["ngResource"]).factory("Bug", function($resource) {
  var Bug;
  Bug = $resource( (prefix +  "errors/:id"), {
    format: "json"
  }, {
    update: {
      method: "PUT"
    }
  });
  return Bug;
});

app.controller("DashboardCtrl", function($scope, $location, $routeParams, $http, Bug) {
  $scope.title = "Dashboard";
  $scope.by_exception = []
  $http({
    method: 'GET',
    url: (prefix + "group"),
    params: {name: "by_exception"}
  }).success( function(data) {
    $scope.by_exception = data
  });
  $scope.by_date = []
  $http({
    method: 'GET',
    url: (prefix + "group"),
    params: {name: "by_date"}
  }).success( function(data) {
    $scope.by_date = data
  });
});

app.controller("ErrorCtrl", function($scope, $location, $routeParams, $http, Bug) {
  $scope.title = "List errors";
  $scope.errors = Bug.query($routeParams);
  $scope.messageTitle = function(error) {
    var title = error.exception_type + " "
    if(error.file) {
      return title+error.file;
    } else {
      var url = error.url;
      if (url.length > 100) {
        url = error.url.slice(0,80);
        url += "...";
      }
      return title+url;
    }
  }
});

app.controller("ErrorShowCtrl", function($scope, $location, $routeParams, $http, Bug) {
  $scope.error = Bug.get($routeParams);
  $scope.renderEnv = function(env) {
    var result = "";
    for(var key in env) {
      result += key+":\t\t"+env[key]+"\n";
    }
    console.log(result)
    return result;
  }
});

