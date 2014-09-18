class window.HexDrawer
  SIDE_PADDING: 1
  constructor: (@snapCanvasId) ->
    console.log "now snap canvas is [" + @snapCanvasId + "]"
    @snapCanvas = Snap("#" + @snapCanvasId)
    @jqCanvas = $("#" + @snapCanvasId)

  generateHexPoints: (center, size) ->
    rv = []
    for i in [0..5]
      angle = 2 * Math.PI/6 * i
      loopX = center.x + size*Math.cos(angle)
      loopY = center.y + size*Math.sin(angle)
      rv.push({x: loopX, y: loopY})
    rv

  createPathFromPoints: (pts, closePath = true) ->
    if closePath
      pts.push(pts[0])
      
    rv = ""
    for pt, i in pts
      rv += if (i == 0) then "M" else "L" 
      rv += pt.x + " " + pt.y
    rv

  drawCircle: (center, radius, attrs) ->
    c = @snapCanvas.circle(center.x, center.y, radius)
    # c.attr({ class: className })
    c.attr(attrs)

  drawText: (midpoint, text, attrs) ->
    t = @snapCanvas.text(midpoint.x, midpoint.y, text)
    t.attr(attrs)

  drawRectangle: (origin, width, height, attrs) ->
    console.log "drawing rect #{origin.x}, #{origin.y}, #{width}, #{height}"
    r = @snapCanvas.rect(origin.x, origin.y, width, height)
    r.attr(attrs)

  # draws a hex at center.x, center.y. distance from center to vertex is size. size is also length of a side (think of
  # the hex as being made of 6 equilateral triangles with length size
  # this draws hexes with flat side on top
  drawHex: (center, size, attrs) ->
    # console.log "let's draw a hex at #{center.x}, #{center.y}"
    pts = @generateHexPoints(center, size)
    path = @createPathFromPoints(pts)
    hex = @snapCanvas.path(path)
    #hex.attr({ stroke: "red", fill: "green" })

    hex.attr(attrs)
    ###
    if className == "basic_hex"
      hex.attr({ stroke: "black", fill: "green" })
    else
      hex.attr({ class: className })
    ###

    return hex

  sizeToFit: (rows, cols) ->
    console.log "size hexes to fit - dimensions are [" + @jqCanvas.width() + "] x [" + @jqCanvas.height() + "]"
    # base value
    hVal = (@jqCanvas.width() - (@SIDE_PADDING*2)) / ((.75 * (cols - 1)) + 1)

    if (cols == 1)
      vValTmp = (@jqCanvas.height() - (@SIDE_PADDING*2)) / ((.5 * (rows )))
    else
      vValTmp = (@jqCanvas.height() - (@SIDE_PADDING*2)) / ((.5 * (rows )) + .25)
    vVal = vValTmp / (Math.sqrt(3))

    return Math.min(hVal, vVal) / 2

  generateDownloadUrl: () ->
    rawData = @snapCanvas.innerSvg
    console.log "RAW DATA [" + rawData + "]"

  drawHexGrid: (rows, cols, hexSize, data, defaultHexStyle = { fill: "#659B74", stroke: "black" }) ->
    # if -1 is passed in, we will attempt to fit
    if hexSize == -1
      hexSize = @sizeToFit(rows, cols)

    # for flat topped hexes
    hexWidth = hexSize * 2
    horizDistance = 3/4 * hexWidth
    hexHeight = Math.sqrt(3)/2 * hexWidth

    # this makes the top left hex butt up right against the border
    xOffset = hexSize + @SIDE_PADDING
    yOffset = hexHeight/2 + @SIDE_PADDING

    for r in [0..rows-1]
      for c in [0..cols-1]
        centerX = xOffset + (c * horizDistance)
        centerY = yOffset + (r * hexHeight) + (if c % 2 == 1 then hexHeight/2 else 0)

        ###
        classForHex = defaultHexClass
        lookupKey = "#{c},#{r}"
        d = data[lookupKey]
        if d != undefined and d.class != undefined
          classForHex = d.class
        ###

        lookupKey = "#{c},#{r}"
        d = data[lookupKey]
        if d != undefined and d.style != undefined
          styleForHex = d.style
        else
          styleForHex = defaultHexStyle

        # hex = @drawHex({x:centerX, y:centerY}, hexSize, classForHex)
        hex = @drawHex({x:centerX, y:centerY}, hexSize, styleForHex)

        if (d != undefined and d.town != undefined)
          @drawCircle({x: centerX, y: centerY}, hexSize * .5, d.town.style)
          @drawText({x: centerX, y: centerY + hexHeight/2 - (hexHeight*.05)}, d.town.name, d.town.labelStyle)

        if (d != undefined and d.city != undefined)
          hex.attr(d.city.style)
          @drawText({x: centerX, y: centerY - hexHeight/2 + (hexHeight*.13)}, d.city.name, d.city.labelStyle)
          boxWidth = hexWidth * .3
          boxHeight = hexHeight * .3
          @drawRectangle({x: centerX - boxWidth/2, y: centerY + hexHeight/2 - boxHeight * 1.1}, boxWidth, boxHeight, {stroke: "black", fill: "white"})
    
