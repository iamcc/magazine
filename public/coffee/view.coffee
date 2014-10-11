$pages   = $ '#pages'
curPage  = 0
lastPage = 0
moving   = false
h        = 0
w        = 0
H        = 504
W        = 320

initPage = (pages) ->
  lastPage = pages.length - 1

  pages.forEach (page, i) ->
    $div = $('<div>')
      .attr 'id', "page-#{i}"
      .addClass 'page'
      .css 'background-color', page.bgColor
      .css 'position', 'relative'

    $wrap = $('<div>').addClass('wrap')
    $div.append $wrap
    $pages.append $div

    page.items.forEach (item, j) ->
      $item = $('<div>')
      $wrap.append $item

      animates = ("#{ani.name} #{ani.duration or 1000}ms #{ani.delay or 0}ms both" for ani in item.animates)
      animates.push item.repeat

      $item
      .data 'animates', JSON.stringify(animates)
      .addClass('item')
      .css
        position : 'absolute'
        top      : "#{item.y}%"
        left     : "#{item.x}%"
        'z-index': item.zindex
        display  : 'none'

      switch item.type
        when 'text'
          $item.css
            color              : item.font.color
            'background-color' : item.font.bgColor
            'font-size'        : item.font.size
            'font-weight'      : item.font.style
          .html item.text
        when 'image'
          $img = $('<img>')
            .attr('src', item.src)
            .attr('alt', item.name)
            .attr('width', '100%')
          $item.css('width', item.w + '%')
          $item.html $img

bind = ->
  $ document
  .on 'touchstart', (e) -> e.preventDefault()
  .on 'touchmove', (e) -> e.preventDefault()
  .swipeUp (e) ->
    moveNext()
  .swipeDown (e) ->
    movePre()

play = (i) ->
  $("#page-#{i} .item").each (j, item) ->
    $item    = $ item
    animates = $item.data('animates')
    $item.on 'webkitAnimationEnd', ->
      animate = animates.shift()
      $item.css '-webkit-animation', animate

      if animate in ['global', 'last']
        animates = $item.data('animates')
        switch animate
          when 'global'
            $item.hide()
            animate  = animates.shift().replace /^(.* .*ms) (.*ms)/, '$1 0s'
          when 'last'
            animates = animates.slice(-2)
            animate  = animates.shift()
        setTimeout ->
          $item.show().css '-webkit-animation', animate

    $item.css '-webkit-animation', animates.shift()
    $item.show()
init = ->
  url = location.search.replace '?json=', ''
  url = '/json/' + url
  $.getJSON url, (json) ->
    initPage(json)
    bind()

    h = $(document).height()
    w = $(document).width()

    $pages.height pages.length * h
    $('.page').height h

    if w > W
      $wrap = $ '.wrap'
      $wrap.css 'width', "#{W/w*100}%"
      $wrap.css '-webkit-transform', "scale(#{w/W}) translateY(#{(1-W/w)/2*100}%)"

    if h < H
      $wrap = $ '.wrap'
      $wrap.css '-webkit-transform', "scale(#{h/H}) translateY(#{(1-H/h)/2*100}%)"

    play 0

move = (n) ->
  return if moving or curPage is 0 and n < 0 or curPage is lastPage and n > 0
  moving   = true
  curPage  += n

  $pages
  .css '-webkit-transform', "translate3d(0px, -#{curPage*h}px, 0px)"
  .one 'webkitTransitionEnd', ->
    $("#page-#{curPage-n} .item").hide()
    play curPage
    moving = false

moveNext = ->
  move 1
movePre = ->
  move -1

$ ->
  init()