// Generated by CoffeeScript 1.7.1
(function() {
  angular.module('app', ['ui.bootstrap']).directive('ccDrag', function($compile, $http, $templateCache, $timeout) {
    return {
      restrict: 'A',
      scope: {
        item: '=ccDrag'
      },
      link: function(scope, elem, attrs) {
        var $elem, ani, animates, animatesCopy, build, setLocation, url;
        $elem = $(elem[0]);
        animates = (function() {
          var _i, _len, _ref, _results;
          _ref = scope.item.animates;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            ani = _ref[_i];
            _results.push("" + ani.name + " " + (ani.duration || 1000) + "ms " + (ani.delay || 0) + "ms both");
          }
          return _results;
        })();
        animates.push(scope.item.repeat);
        animatesCopy = animates.slice(0);
        $elem.css({
          position: 'absolute',
          top: "" + scope.item.y + "%",
          left: "" + scope.item.x + "%",
          width: "" + scope.item.w + "%",
          'z-index': scope.item.zindex,
          '-webkit-animation': animatesCopy.shift()
        });
        $elem.on('webkitAnimationEnd', function() {
          var animate;
          animate = animatesCopy.shift();
          $elem.css('-webkit-animation', animate);
          if (animate === 'global' || animate === 'last') {
            switch (animate) {
              case 'global':
                $elem.hide();
                animatesCopy = animates.slice(0);
                animate = animatesCopy.shift();
                break;
              case 'last':
                animatesCopy = animates.slice(-2);
                animate = animatesCopy.shift();
            }
            return $timeout(function() {
              return $elem.show().css('-webkit-animation', animate);
            });
          }
        });
        setLocation = function(x, y) {
          var H, W, height, left, maxHeight, maxWidth, top, width;
          W = 320;
          H = 504;
          width = $elem.width();
          height = $elem.height();
          maxWidth = W - width;
          maxHeight = H - height;
          top = parseFloat(y) || 0;
          left = parseFloat(x) || 0;
          if (top < 0) {
            top = 0;
          }
          if (top > maxHeight) {
            top = maxHeight;
          }
          if (left < 0) {
            left = 0;
          }
          if (left > maxWidth) {
            left = maxWidth;
          }
          $elem.css('top', top / H * 100 + '%');
          $elem.css('left', left / W * 100 + '%');
          scope.item.y = top / H * 100;
          return scope.item.x = left / W * 100;
        };
        url = "/view/" + scope.item.type + "Item.html";
        build = function() {
          elem.html($templateCache.get(url));
          return $compile(elem.contents())(scope);
        };
        if (!$templateCache.get(url)) {
          $http.get(url, {
            cache: true
          }).success(function(data) {
            $templateCache.put(url, data);
            return build();
          });
        } else {
          build();
        }
        $elem.on('mousedown', function(e) {
          $elem.__move = true;
          $elem.css('cursor', 'move');
          $elem.__x = e.x;
          $elem.__sx = e.x;
          $elem.__y = e.y;
          $elem.__sy = e.y;
          $elem.__z = $elem.css('z-index');
          return $elem.css('z-index', 999);
        });
        $elem.on('mousemove', function(e) {
          var offset;
          if (!$elem.__move) {
            return;
          }
          offset = $elem.offset();
          $elem.offset({
            top: offset.top + e.y - $elem.__y,
            left: offset.left + e.x - $elem.__x
          });
          $elem.__y = e.y;
          return $elem.__x = e.x;
        });
        return $elem.on('mouseup', function(e) {
          $elem.__move = false;
          $elem.css('cursor', '');
          $elem.css('z-index', $elem.__z);
          if ($elem.__sx === e.x && $elem.__sy === e.y) {
            return;
          }
          return setLocation($elem.css('left').replace('px', ''), $elem.css('top').replace('px', ''));
        });
      }
    };
  }).directive('baseSetting', function() {
    return {
      restrict: 'A',
      replace: true,
      require: 'ngModel',
      templateUrl: '/view/baseSetting.html'
    };
  }).controller('mainCtrl', function($scope, $modal, $window, $http, $timeout) {
    $scope.curIdx = -1;
    $scope.curPage = null;
    $scope.pages = angular.fromJson($window.localStorage.pages) || [];
    $scope.move = function(idx, n) {
      var page;
      page = $scope.pages.splice(idx, 1);
      return $scope.pages.splice(idx + n, 0, page[0]);
    };
    $scope.selectPage = function(idx, page) {
      var animate, items;
      page = angular.copy(page);
      animate = page.animate || 'fadeInUp';
      page.animate = 'animated ';
      items = page.items;
      page.items = [];
      $scope.curIdx = idx;
      $scope.curPage = page;
      $timeout(function() {
        return $scope.curPage.animate += animate;
      });
      return $timeout(function() {
        var item, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = items.length; _i < _len; _i++) {
          item = items[_i];
          _results.push($scope.curPage.items.push(item));
        }
        return _results;
      }, 1000);
    };
    $scope.newPage = function() {
      var page;
      page = {
        title: "page-" + $scope.pages.length,
        bgColor: '#ffffff',
        animate: 'fadeInUp',
        items: []
      };
      $scope.pages.push(page);
      $scope.curPage = angular.copy(page);
      return $scope.curIdx = $scope.pages.length - 1;
    };
    $scope.delPage = function(idx) {
      return $scope.pages.splice(idx, 1);
    };
    $scope.newText = function(idx, item) {
      var modal;
      modal = $modal.open({
        templateUrl: '/view/textModal.html',
        resolve: {
          item: function() {
            return item;
          }
        },
        controller: function($scope, $modalInstance, item) {
          if (item == null) {
            item = {
              name: "new text",
              text: "new text",
              font: {
                color: '',
                bgColor: '',
                size: 12,
                style: ''
              },
              x: 0,
              y: 0,
              zindex: 0,
              animates: [
                {
                  name: 'bounceInDown',
                  repeat: false,
                  duration: 1000,
                  delay: 0
                }
              ],
              type: 'text'
            };
          }
          $scope.item = angular.copy(item);
          $scope.ok = function() {
            return $modalInstance.close($scope.item);
          };
          return $scope.cancel = function() {
            return $modalInstance.dismiss('');
          };
        }
      });
      return modal.result.then(function(rst) {
        if (item) {
          return $scope.curPage.items[idx] = angular.copy(rst);
        } else {
          return $scope.curPage.items.push(rst);
        }
      });
    };
    $scope.newImage = function(idx, item) {
      var modal;
      modal = $modal.open({
        templateUrl: '/view/imageModal.html',
        resolve: {
          item: function() {
            return item;
          }
        },
        controller: function($scope, $modalInstance, item) {
          if (item == null) {
            item = {
              name: "new image",
              src: "http://dummyimage.com/320x320/4d494d/686a82.gif&text=placeholder+image",
              x: 0,
              y: 0,
              zindex: 0,
              w: 100,
              animates: [
                {
                  name: 'bounceInDown',
                  repeat: false,
                  duration: 1000,
                  delay: 0
                }
              ],
              type: 'image'
            };
          }
          $scope.item = angular.copy(item);
          $scope.ok = function() {
            return $modalInstance.close($scope.item);
          };
          return $scope.cancel = function() {
            return $modalInstance.dismiss('');
          };
        }
      });
      return modal.result.then(function(rst) {
        if (item) {
          return $scope.curPage.items[idx] = angular.copy(rst);
        } else {
          return $scope.curPage.items.push(rst);
        }
      });
    };
    $scope.newVideo = function() {
      return $scope.curPage.items.push({
        name: "item-" + $scope.curPage.items.length,
        text: "item-" + $scope.curPage.items.length + " video",
        x: 0,
        y: 0,
        type: 'video'
      });
    };
    $scope.newLink = function() {
      return $scope.curPage.items.push({
        name: "item-" + $scope.curPage.items.length,
        text: "item-" + $scope.curPage.items.length + " link",
        x: 0,
        y: 0,
        type: 'link'
      });
    };
    $scope.editItem = function(idx, item) {
      switch (item.type) {
        case 'text':
          return $scope.newText(idx, item);
        case 'image':
          return $scope.newImage(idx, item);
      }
    };
    $scope.delItem = function(idx) {
      return $scope.curPage.items.splice(idx, 1);
    };
    $scope.savePage = function() {
      return $scope.pages[$scope.curIdx] = angular.copy($scope.curPage);
    };
    return $scope.saveList = function() {
      localStorage.pages = JSON.stringify($scope.pages);
      return $http.post('/', $scope.pages).success(function(file) {
        return $window.open("/view.html?json=" + file);
      });
    };
  });

  angular.bootstrap(document, ['app']);

}).call(this);
