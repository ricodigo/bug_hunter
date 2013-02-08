var dependecies = ["ui.bootstrap.accordion", "ui.bootstrap.tooltip", "bug_model"]
var app = angular.module("app", dependecies);

app.config(function ($routeProvider) {
  $routeProvider.when('/',
    {
      templateUrl: "/template/errors.html",
      controller: "ErrorCtrl"
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
  $scope.title = "List errors"
  $scope.errors = Bug.query();
});

// /*
// app.factory("Error", function($resource) {
//     return $resource("/errors/:id", {
//       id: "@id"
//     }, {
//       update: {
//         method: "PUT"
//       }
//     });
//   }
// );*/


