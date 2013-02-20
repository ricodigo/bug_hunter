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
  console.log($routeParams)
  $scope.errors = Bug.query($routeParams);
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

