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
    pts = @generateHexPoints(center, size)
    path = @createPathFromPoints(pts)
    hex = @snapCanvas.path(path)

    hex.attr(attrs)
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

    @setHexSize(Math.min(hVal, vVal) / 2)

  setHexSize: (@_hexSize) ->
    # for flat topped hexes
    @hexWidth = @getHexSize() * 2
    @horizDistance = 3/4 * @hexWidth
    @hexHeight = Math.sqrt(3)/2 * @hexWidth

  getHexSize: () ->
    return @_hexSize

  getHexPosition: (row, col) ->
    # this makes the top left hex butt up right against the border
    xOffset = @getHexSize() + @SIDE_PADDING
    yOffset = @hexHeight/2 + @SIDE_PADDING

    centerX = xOffset + (col * @horizDistance)
    centerY = yOffset + (row * @hexHeight) + (if col % 2 == 1 then @hexHeight/2 else 0)
    return {x: centerX, y: centerY};

  # 1 is the top of the flat pointed hex. 2 is upper right, etc.
  generateHexSidePoints: (col, row, side) ->
    if (side != -1 and (side < 1  or side > 6))
      console.log "invalid side passed in"
      return

    center = @getHexPosition(row, col)
    pts = @generateHexPoints(center, @getHexSize())
    if side != -1
      if side == 1
        pts = [pts[4], pts[5]]
      else if side == 2
        pts = [pts[5], pts[0]]
      else
        pts = pts[side-3..side-2]
    return pts

  getMidPoint: (a, b) ->
    return { x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 }

  getCoordsOfCircleAngle: (center, radius, angle) ->
    angleInRads = Snap.rad(angle)
    x = center.x + radius * Math.cos(angleInRads)
    y = center.y + radius * Math.sin(angleInRads)
    return { x: x, y: y}

  createArcPath: (center, radius, startAngle, endAngle) ->
    startCoords = @getCoordsOfCircleAngle(center, radius, startAngle);
    endCoords = @getCoordsOfCircleAngle(center, radius, endAngle);

    xAxisRot = 0
    largeArcFlag = 0
    sweepFlag = 1

    arcPath = "M" + startCoords.x + "," + startCoords.y   # move to one point of arc
    arcPath += " A" + radius + "," + radius + " " + xAxisRot + " " + largeArcFlag + "," + sweepFlag   # arc
    arcPath += " " + endCoords.x + "," + endCoords.y      # to this point
    # arcPath += "z"                                        # do NOT close path

    # return @createPathFromPoints([startCoords, endCoords])
    # return @createPathFromPoints([center, {x: center.x + 300, y: center.y + 50}])
    return arcPath

  getSharpCurveAngles: (sideA, sideB) ->
    # ensure that sideA is the lower number
    if (sideB < sideA)
      [sideB, sideA] = [sideA, sideB]

    # could probably clean this up with a little math
    if sideA == 1 and sideB == 2
      return [60, 180]
    else if sideA == 2 and sideB == 3
      return [120, 240]
    else if sideA == 3 and sideB == 4
      return [180, 300]
    else if sideA == 4 and sideB == 5
      return [240, 0]
    else if sideA == 5 and sideB == 6
      return [300, 60]
    else if sideA == 1 and sideB == 6
      return [0, 120]

  drawTrackNub: (col, row, fromSide, toSide) ->
    rawDiff = Math.abs(fromSide - toSide)
    sidesApart = rawDiff % 4
    console.log fromSide + "->" + toSide + "..." + sidesApart + " side(s) apart (" + rawDiff + ")"

    adjFrom = Math.min(fromSide, toSide)
    adjTo = Math.max(fromSide, toSide)

    fromPoints = @generateHexSidePoints(col, row, adjFrom)
    toPoints = @generateHexSidePoints(col, row, adjTo)

    if sidesApart == 3 # straight
      pts = [ @getMidPoint(fromPoints[0], fromPoints[1]), @getMidPoint(toPoints[0], toPoints[1]) ]
      path = @createPathFromPoints(pts)
    else if sidesApart == 2 # gentle curve
    else if sidesApart == 1 # sharp curve
      originPoint = if rawDiff == 1 then fromPoints[1] else toPoints[1]
      angles = @getSharpCurveAngles(adjFrom, adjTo)
      path = @createArcPath(originPoint, @getHexSize() / 2, angles[0], angles[1])

    if path
      track = @snapCanvas.path(path)
      track.attr({ stroke: "black", "stroke-width": 12, fill: "none", "stroke-linecap": "butt" })
    else
      console.log "invalid sides passed to drawTrackNub"

  paintThickBorder: (col, row, thickness, side = -1) ->
    pts = @generateHexSidePoints(col, row, side)
    path = @createPathFromPoints(pts)
    border = @snapCanvas.path(path)
    border.attr({ stroke: "black", "stroke-width": thickness, fill: "none" })

  paintDashedBorder: (col, row, side = -1) ->
    pts = @generateHexSidePoints(col, row, side)
    path = @createPathFromPoints(pts)

    clearer = @snapCanvas.path(path)
    clearer.attr({ stroke: "#659B74", "stroke-width": 2.3, fill: "none" })

    border = @snapCanvas.path(path)
    border.attr({ stroke: "black", "stroke-width": 5, fill: "none", "stroke-dasharray": "5,5" })

  drawHexGrid: (rows, cols, data, defaultHexStyle = { fill: "#659B74", stroke: "black" }) ->
    for r in [0..rows-1]
      for c in [0..cols-1]
        center = @getHexPosition(r, c)
        centerX = center.x
        centerY = center.y

        lookupKey = "#{c},#{r}"
        d = data[lookupKey]
        if d != undefined and d.style != undefined
          styleForHex = d.style
        else
          styleForHex = defaultHexStyle

        hex = @drawHex(center, @getHexSize(), styleForHex)


        if (d != undefined and d.town != undefined)
          @drawCircle(center, @getHexSize() * .6, d.town.style)
          @drawText({x: centerX, y: centerY + @hexHeight/2 - (@hexHeight*.05)}, d.town.name, d.town.labelStyle)

        if (d != undefined and d.city != undefined)
          hex.attr(d.city.style)
          @drawText({x: centerX, y: centerY - @hexHeight/2 + (@hexHeight*.13)}, d.city.name, d.city.labelStyle)
          boxWidth = @hexWidth * .35
          boxHeight = @hexHeight * .3
          @drawRectangle({x: centerX - boxWidth/2, y: centerY + @hexHeight/2 - boxHeight * 1.2}, boxWidth, boxHeight, {stroke: "black", fill: "white"})
