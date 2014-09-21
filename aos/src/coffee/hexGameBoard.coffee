class window.HexGameBoard
  SIDE_PADDING: 1
  constructor: (@snapCanvasId) ->
    console.log "now snap canvas is [" + @snapCanvasId + "]"
    @snapCanvas = Snap("#" + @snapCanvasId)
    @jqCanvas = $("#" + @snapCanvasId)

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
    if @_hexSize != -1
        # for flat topped hexes
        @hexWidth = @getHexSize() * 2
        @horizDistance = 3/4 * @hexWidth
        @hexHeight = Math.sqrt(3)/2 * @hexWidth

  getHexSize: () ->
    return @_hexSize

  getHexPosition: (col, row) ->
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

    center = @getHexPosition(col, row)
    pts = SvgUtils.generateHexPoints(center, @getHexSize())
    if side != -1
      if side == 1
        pts = [pts[4], pts[5]]
      else if side == 2
        pts = [pts[5], pts[0]]
      else
        pts = pts[side-3..side-2]
    return pts


  # given a column and row, and a direction to move in, give the column and row of that neighbor
  getNeighborColRow: (col, row, dir) ->
    nCol = col
    nRow = row
    if (dir == 1) # up
      nRow--
    else if (dir == 4) # down
      nRow++
    else
      if (col % 2 == 1)
        if (dir == 2)
          nCol++
        else if (dir == 3)
          nCol++
          nRow++
        else if (dir == 5)
          nCol--
          nRow++
        else if (dir == 6)
          nCol--
      else
        if (dir == 2)
          nRow--
          nCol++
        else if (dir == 3)
          nCol++
        else if (dir == 5)
          nCol--
        else if (dir == 6)
          nCol--
          nRow--

    return { row: nRow, col: nCol }

  testAllTrack: () ->
    rev = false
    testData = [
      [1, 0, 6, 3]
      [2, 1, 6, 4]
      [2, 2, 1, 5]
      [1, 2, 2, 3]
      [2, 3, 6, 1]
      [2, 2, 4, 2]
      [3, 1, 5, 1]
      [3, 0, 4, 3]
    ]

    gentleData = [
      [2, 1, 4, 2, rev]
      [3, 0, 5, 3, rev]
      [4, 1, 6, 4, rev]
      [4, 2, 1, 5, rev]
      [3, 2, 2, 6, rev]
      [2, 2, 3, 1, rev]
    ]

    sharpData = [
      [2, 1, 3, 4, rev]
      [3, 1, 5, 6, rev]
      [2, 2, 1, 2, rev]

      [4, 1, 2, 3, rev]
      [5, 0, 4, 5, rev]
      [5, 1, 1, 6, rev]
    ]

    for d in testData
      if (d[4])
        @drawTrackNub(d[0], d[1], d[3], d[2])
      else
        @drawTrackNub(d[0], d[1], d[2], d[3])
    
      
  getGentleCurveAngles: (sideA, sideB) ->
    sidesApart = Math.abs(sideA - sideB)
    # console.log "get gentle curves for [" + sideA + "]->[" + sideB + "] (" + sidesApart + " sides apart)"

    frontHalfOnly = true

    ###
    if frontHalfOnly
      frontHalfOnlyAdjustment = 30
    else
    ###
    frontHalfOnlyAdjustment = 0

    if sidesApart == 2
      if (sideA < sideB)
        base = (sideA * 60) + 120
        rv = [base - frontHalfOnlyAdjustment, base-60]
      else
        base = (sideB * 60) + 120
        rv = [base-60, base - frontHalfOnlyAdjustment]
    else if sidesApart == 4
      if (sideA < sideB)
        base = (sideA - 1) * 60
        rv = [base, base+60 - frontHalfOnlyAdjustment]
      else
        base = (sideB - 1) * 60
        rv = [base+60 - frontHalfOnlyAdjustment, base]
    
    return rv

  getSharpCurveAngles: (sideA, sideB) ->
    sidesApart = Math.abs(sideA - sideB)
    # console.log "get sharp curves for [" + sideA + "]->[" + sideB + "] (" + sidesApart + " sides apart)"

    if sidesApart == 1
      if (sideA < sideB)
        base = sideA * 60
        rv = [base+120, base]
      else
        base = sideB * 60
        rv = [base, base+120]
    else if sidesApart == 5
      if (sideA < sideB)
        rv = [0, 120]
      else
        rv = [120, 0]

    # console.log "going from [" + rv[0] + "] -> [" + rv[1] + "]"
    return rv

  # given two sides that are 2 apart, return the side between them
  getBetweenSide: (a, b) ->
    [a, b] = [Math.min(a,b), Math.max(a,b)]
    if b - a == 2
      return b - 1
    else if b - a == 4
      return (b % 6) + 1

  getSharedPoint: (sideAPoints, sideBPoints) ->
    if (sideAPoints[0].x == sideBPoints[1].x and sideAPoints[0].y == sideBPoints[1].y)
      return sideAPoints[0]
    else
      return sideAPoints[1]

  getPathForSideToSide: (col, row, fromSide, toSide) ->
    sidesApart = Math.abs(fromSide - toSide)

    fromPoints = @generateHexSidePoints(col, row, fromSide)
    toPoints = @generateHexSidePoints(col, row, toSide)

    if sidesApart == 3 # straight
      pts = [ SvgUtils.getMidPoint(fromPoints[0], fromPoints[1]), SvgUtils.getMidPoint(toPoints[0], toPoints[1]) ]
      path = SvgUtils.createPathFromPoints(pts, false)
    else if sidesApart == 2 or sidesApart == 4
      betweenSide = @getBetweenSide(fromSide, toSide)
      n = @getNeighborColRow(col, row, betweenSide)
      neighborCenter = @getHexPosition(n.col, n.row)
      angles = @getGentleCurveAngles(fromSide, toSide)
      path = SvgUtils.createArcPath(neighborCenter, @getHexSize() * 1.5, angles[0], angles[1])
    else if sidesApart == 1 or sidesApart == 5 # sharp curve
      originPoint = @getSharedPoint(fromPoints, toPoints)
      angles = @getSharpCurveAngles(fromSide, toSide)
      path = SvgUtils.createArcPath(originPoint, @getHexSize() / 2, angles[0], angles[1])
    return path

  drawTrackNub: (col, row, fromSide, toSide) ->
    path = @getPathForSideToSide(col, row, fromSide, toSide)

    if path
      # console.log "path for [#{col}],[#{row}] is [" + path + "]..."
      track = @snapCanvas.path(path)
      track.attr({ stroke: "black", "stroke-width": 4, fill: "none", "stroke-linecap": "butt" })
    else
      console.log "invalid sides passed to drawTrackNub"

  paintThickBorder: (col, row, thickness, side = -1) ->
    pts = @generateHexSidePoints(col, row, side)
    path = SvgUtils.createPathFromPoints(pts)
    border = @snapCanvas.path(path)
    border.attr({ stroke: "black", "stroke-width": thickness, fill: "none" })

  paintDashedBorder: (col, row, side = -1) ->
    pts = @generateHexSidePoints(col, row, side)
    path = SvgUtils.createPathFromPoints(pts)

    clearer = @snapCanvas.path(path)
    clearer.attr({ stroke: "#659B74", "stroke-width": 2.3, fill: "none" })

    border = @snapCanvas.path(path)
    border.attr({ stroke: "black", "stroke-width": 5, fill: "none", "stroke-dasharray": "5,5" })

  drawHexGrid: (rows, cols, data, defaultHexStyle = { fill: "#659B74", stroke: "black" }) ->
    if @_hexSize == -1
      @sizeToFit(rows, cols)
    console.log "draing"
    for r in [0..rows-1]
      for c in [0..cols-1]
        center = @getHexPosition(c, r)
        centerX = center.x
        centerY = center.y

        lookupKey = "#{c},#{r}"
        d = data[lookupKey]
        if d != undefined and d.style != undefined
          styleForHex = d.style
        else
          styleForHex = defaultHexStyle

        hex = SvgUtils.drawHex(@snapCanvas, center, @getHexSize(), styleForHex)

        if (d != undefined and d.town != undefined)
          SvgUtils.drawCircle(@snapCanvas, center, @getHexSize() * .6, d.town.style)
          SvgUtils.drawText(@snapCanvas, {x: centerX, y: centerY + @hexHeight/2 - (@hexHeight*.05)}, d.town.name, d.town.labelStyle)

        if (d != undefined and d.city != undefined)
          hex.attr(d.city.style)
          SvgUtils.drawText(@snapCanvas, {x: centerX, y: centerY - @hexHeight/2 + (@hexHeight*.13)}, d.city.name, d.city.labelStyle)
          boxWidth = @hexWidth * .35
          boxHeight = @hexHeight * .3
          SvgUtils.drawRectangle(@snapCanvas, {x: centerX - boxWidth/2, y: centerY + @hexHeight/2 - boxHeight * 1.2}, boxWidth, boxHeight, {stroke: "black", fill: "white"})

    fakeCenter = @getHexPosition(1, 0)
    fakeCube = SvgUtils.drawCenteredRectangle(@snapCanvas, {x: fakeCenter.x, y: fakeCenter.y }, 20, 20, {stroke: "black", fill: "purple", id:"fakeCube"})
    # fakeCube = @drawCenteredRectangle({x: 0, y: 0 }, 40, 40, {stroke: "black", fill: "purple"})
    foo = (() =>
      console.log "animate the cube!"
      cb = $("#fakeCube")
      par = cb.parent()
      cb.detach().appendTo(par)
      SvgUtils.animateAlongPath(@snapCanvas, fakeCube, [
                                  @getPathForSideToSide(1, 0, 6, 3)
                                  @getPathForSideToSide(2, 1, 6, 4)
                                  @getPathForSideToSide(2, 2, 1, 5)
                                  @getPathForSideToSide(1, 2, 2, 3)
                                  @getPathForSideToSide(2, 3, 6, 1)
                                  @getPathForSideToSide(2, 2, 4, 2)
                                  @getPathForSideToSide(3, 1, 5, 1)
                                  @getPathForSideToSide(3, 0, 4, 3)
                                  ])
    )
    # foo()
    fakeCube.click(foo)
    # setTimeout(foo, 500)


