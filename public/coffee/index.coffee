angular.module 'app', ['ui.bootstrap']
.directive 'ccDrag', ($compile, $http, $templateCache, $timeout) ->
  restrict: 'A'
  scope:
    item: '=ccDrag'
  link: (scope, elem, attrs) ->
    $elem = $ elem[0]

    animates = ("#{ani.name} #{ani.duration or 1000}ms #{ani.delay or 0}ms both" for ani in scope.item.animates)
    animates.push scope.item.repeat
    animatesCopy = animates.slice(0)

    $elem
      .css
        position: 'absolute'
        top: "#{scope.item.y}%"
        left: "#{scope.item.x}%"
        width: "#{scope.item.w}%"
        'z-index': scope.item.zindex
        '-webkit-animation': animatesCopy.shift()

    $elem.on 'webkitAnimationEnd', ->
      animate = animatesCopy.shift()

      $elem.css '-webkit-animation', animate

      if animate in ['global', 'last']
        switch animate
          when 'global'
            $elem.hide()
            animatesCopy = animates.slice(0)
            animate      = animatesCopy.shift()
          when 'last'
            animatesCopy = animates.slice(-2)
            animate      = animatesCopy.shift()
        $timeout ->
          $elem.show().css '-webkit-animation', animate


    setLocation = (x, y) ->
      W         = 320
      H         = 504
      width     = $elem.width()
      height    = $elem.height()
      maxWidth  = W - width
      maxHeight = H - height
      
      top   = parseFloat(y) or 0
      left  = parseFloat(x) or 0

      top = 0 if top < 0
      top = maxHeight if top > maxHeight

      left = 0 if left < 0
      left = maxWidth if left > maxWidth

      $elem.css 'top', top/H*100 + '%'
      $elem.css 'left', left/W*100 + '%'

      scope.item.y = top/H*100
      scope.item.x = left/W*100

    url = "/view/#{scope.item.type}Item.html"

    build = ->
      elem.html $templateCache.get url
      $compile(elem.contents()) scope

    if not $templateCache.get(url)
      $http.get(url, {cache: true}).success (data) ->
        $templateCache.put url, data
        build()
    else
      build()

    $elem.on 'mousedown', (e) ->
      $elem.__move = true
      $elem.css 'cursor', 'move'
      $elem.__x  = e.x
      $elem.__sx = e.x
      $elem.__y  = e.y
      $elem.__sy = e.y
      $elem.__z  = $elem.css 'z-index'
      $elem.css 'z-index', 999

    $elem.on 'mousemove', (e) ->
      return unless $elem.__move
      offset = $elem.offset()

      $elem.offset
        top: offset.top+e.y-$elem.__y
        left: offset.left+e.x-$elem.__x

      $elem.__y = e.y
      $elem.__x = e.x

    $elem.on 'mouseup', (e) ->
      $elem.__move = false
      $elem.css 'cursor', ''
      $elem.css 'z-index', $elem.__z

      return if $elem.__sx is e.x and $elem.__sy is e.y
      setLocation $elem.css('left').replace('px', ''), $elem.css('top').replace('px', '')

.directive 'baseSetting', ->
  restrict    : 'A'
  replace     : true
  require     : 'ngModel'
  templateUrl : '/view/baseSetting.html'
.controller 'mainCtrl', ($scope, $modal, $window, $http, $timeout) ->
  $scope.curIdx  = -1
  $scope.curPage = null
  $scope.pages   = angular.fromJson($window.localStorage.pages) or []

  $scope.move = (idx, n) ->
    page = $scope.pages.splice idx, 1
    $scope.pages.splice idx+n, 0, page[0]
  $scope.selectPage = (idx, page) ->
    page           = angular.copy page
    animate        = page.animate or 'fadeInUp'
    page.animate   = 'animated '
    items          = page.items
    page.items     = []
    $scope.curIdx  = idx
    $scope.curPage = page
    $timeout -> $scope.curPage.animate += animate
    $timeout ->
      $scope.curPage.items.push item for item in items
    , 1000
  $scope.newPage = ->
    page =
      title: "page-#{$scope.pages.length}"
      bgColor: '#ffffff'
      animate: 'fadeInUp'
      items: []

    $scope.pages.push page
    $scope.curPage = angular.copy page
    $scope.curIdx  = $scope.pages.length - 1
  $scope.delPage = (idx) ->
    $scope.pages.splice idx, 1
  $scope.newText = (idx, item) ->
    modal = $modal.open
      templateUrl: '/view/textModal.html'
      resolve:
        item: -> item
      controller: ($scope, $modalInstance, item) ->
        item ?=
          name : "new text"
          text : "new text"
          font :
            color   : ''
            bgColor : ''
            size    : 12
            style   : ''
          x        : 0
          y        : 0
          zindex   : 0
          animates: [{
            name: 'bounceInDown'
            repeat: false
            duration: 1000
            delay: 0
          }]
          type     : 'text'
        $scope.item = angular.copy item
        $scope.ok = ->
          $modalInstance.close $scope.item
        $scope.cancel = ->
          $modalInstance.dismiss ''
    modal.result.then (rst) ->
      if item then $scope.curPage.items[idx] = angular.copy rst
      else $scope.curPage.items.push rst
  $scope.newImage = (idx, item) ->
    modal = $modal.open
      templateUrl: '/view/imageModal.html'
      resolve:
        item: -> item
      controller: ($scope, $modalInstance, item) ->
        item ?=
          name    : "new image"
          src     : "http://dummyimage.com/320x320/4d494d/686a82.gif&text=placeholder+image"
          x       : 0
          y       : 0
          zindex  : 0
          w       : 100
          animates: [{
            name: 'bounceInDown'
            repeat: false
            duration: 1000
            delay: 0
          }]
          type    : 'image'
        $scope.item = angular.copy item
        $scope.ok = ->
          $modalInstance.close $scope.item
        $scope.cancel = ->
          $modalInstance.dismiss ''
    modal.result.then (rst) ->
      if item then $scope.curPage.items[idx] = angular.copy rst
      else $scope.curPage.items.push rst
  $scope.newVideo = ->
    $scope.curPage.items.push {
      name : "item-#{$scope.curPage.items.length}"
      text : "item-#{$scope.curPage.items.length} video"
      x    : 0
      y    : 0
      type : 'video'
    }
  $scope.newLink = ->
    $scope.curPage.items.push {
      name : "item-#{$scope.curPage.items.length}"
      text : "item-#{$scope.curPage.items.length} link"
      x    : 0
      y    : 0
      type : 'link'
    }
  $scope.editItem = (idx, item) ->
    switch item.type
      when 'text' then $scope.newText idx, item
      when 'image' then $scope.newImage idx, item    
  $scope.delItem = (idx) ->
    $scope.curPage.items.splice idx, 1
  $scope.savePage = ->
    $scope.pages[$scope.curIdx] = angular.copy $scope.curPage
  $scope.saveList = ->
    localStorage.pages = JSON.stringify $scope.pages
    $http.post '/', $scope.pages
    .success (file) ->
      $window.open "/view.html?json=#{file}"
angular.bootstrap document, ['app']