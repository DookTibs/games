class window.BoardRenderer
  SIDE_PADDING: 20
  constructor: (@controller, @snapCanvasId) ->
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
      if side == AosBoard.DIR_NO
        pts = [pts[4], pts[5]]
      else if side == AosBoard.DIR_NE
        pts = [pts[5], pts[0]]
      else
        pts = pts[side-3..side-2]
    return pts

  ###
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
    
  ###


  # given two sides that are 2 apart, return the side between them
  getBetweenSide: (a, b) ->
    [a, b] = [Math.min(a,b), Math.max(a,b)]
    if b - a == 2
      return b - 1
    else if b - a == 4
      return (b % 6) + 1

  getPathForSideToSide: (col, row, fromSide, toSide) ->
    sidesApart = Math.abs(fromSide - toSide)

    fromPoints = @generateHexSidePoints(col, row, fromSide)
    toPoints = @generateHexSidePoints(col, row, toSide)

    if fromSide == 0 or toSide == 0
      hexCenter = @getHexPosition(col, row)
      # edge to center
      if fromSide == 0
        console.log "fromside==0, toside=[" + toSide + "],toPoints:"
        console.log toPoints
        path = SvgUtils.createPathFromPoints([ { x: hexCenter.x, y: hexCenter.y}, SvgUtils.getMidPoint(toPoints[0], toPoints[1]) ])
      else
        path = SvgUtils.createPathFromPoints([ SvgUtils.getMidPoint(fromPoints[0], fromPoints[1]), { x: hexCenter.x, y: hexCenter.y} ])
    else if sidesApart == 3 # straight
      pts = [ SvgUtils.getMidPoint(fromPoints[0], fromPoints[1]), SvgUtils.getMidPoint(toPoints[0], toPoints[1]) ]
      path = SvgUtils.createPathFromPoints(pts, false)
    else if sidesApart == 2 or sidesApart == 4
      betweenSide = @getBetweenSide(fromSide, toSide)
      n = AosBoard.getNeighborColRow(col, row, betweenSide)
      neighborCenter = @getHexPosition(n.col, n.row)
      angles = HexUtils.getGentleCurveAngles(fromSide, toSide)
      path = SvgUtils.createArcPath(neighborCenter, @getHexSize() * 1.5, angles[0], angles[1])
    else if sidesApart == 1 or sidesApart == 5 # sharp curve
      originPoint = HexUtils.getSharedSidePoint(fromPoints, toPoints)
      angles = HexUtils.getSharpCurveAngles(fromSide, toSide)
      path = SvgUtils.createArcPath(originPoint, @getHexSize() / 2, angles[0], angles[1])
    return path

  drawTrackNub: (col, row, fromSide, toSide, color = "black") ->
    path = @getPathForSideToSide(col, row, fromSide, toSide)

    if path
      # console.log "path for [#{col}],[#{row}] is [" + path + "]..."
      track = @snapCanvas.path(path)
      track.attr({ stroke: color, "stroke-width": 4, fill: "none", "stroke-linecap": "butt" })
    else
      console.log "invalid sides passed to drawTrackNub"

  paintThickBorder: (col, row, thickness, side = -1) ->
    pts = @generateHexSidePoints(col, row, side)
    path = SvgUtils.createPathFromPoints(pts)
    border = @snapCanvas.path(path)
    border.attr({ stroke: "black", "stroke-width": thickness, fill: "none" })
    return border

  paintDashedBorder: (col, row, side = -1) ->
    pts = @generateHexSidePoints(col, row, side)
    path = SvgUtils.createPathFromPoints(pts)

    clearer = @snapCanvas.path(path)
    clearer.attr({ stroke: "#659B74", "stroke-width": 2.3, fill: "none" })

    border = @snapCanvas.path(path)
    border.attr({ stroke: "black", "stroke-width": 5, fill: "none", "stroke-dasharray": "5,5" })

  ###
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
  ###


  renderTown: (center, town) ->
    SvgUtils.drawCircle(@snapCanvas, center, @getHexSize() * .6, @controller.getTownStyle())
    # SvgUtils.drawCircle(Snap("#" + hex.attr("id")), {x:0,y:0}, @getHexSize() * .6, @controller.getTownStyle())
    t = SvgUtils.drawText(@snapCanvas, {x: center.x, y: center.y + @hexHeight/2 - (@hexHeight*.05)}, town.name, @controller.getLabelStyle())
    t.attr("font-size", @hexHeight * .14)
 
  drawCube: (center, col, row, cube) ->
    cube = SvgUtils.drawCenteredRectangle(@snapCanvas, {x: center.x, y: center.y }, 20, 20, {stroke: "black", fill: cube.color, id:"fakeCube"})
    thisHook = this
    cube.click(() ->
      thisHook.controller.findRouteFromHex(col, row)
    )

  renderCity: (center, col, row, city) ->
    SvgUtils.drawText(@snapCanvas, {x: center.x, y: center.y - @hexHeight/2 + (@hexHeight*.14)}, city.name, @controller.getLabelStyle())
    boxWidth = @hexWidth * .35
    boxHeight = @hexHeight * .3
    SvgUtils.drawCenteredRectangle(@snapCanvas, {x: center.x, y: center.y + @hexHeight/3.4 }, boxWidth, boxHeight, {stroke: "black", fill: "white" })
    border = @paintThickBorder(col, row, 5)
    border.attr("class", "hex_outlines")

  clearHexAt: (col, row) ->
    $("#boardhex_#{col}_#{row}").remove()

  renderHexAt: (col, row, hexData) ->
    if hexData.reset
      @clearHexAt(col, row)

    console.log "renderHexAt [#{col},#{row}]"
    center = @getHexPosition(col, row)
    centerX = center.x
    centerY = center.y

    # hexContainer = @snapCanvas.svg(center.x, center.y, 100, 100)
    # hex = SvgUtils.drawHex(hexContainer, {x:-100, y:-50}, @getHexSize(), @controller.getStyleForHexType(hexData.type))
    
    hex = SvgUtils.drawHex(@snapCanvas, center, @getHexSize(), @controller.getStyleForHexType(hexData))
    hex.attr("id", "boardhex_#{col}_#{row}")

    if hexData.type == HexData.TYPE_TOWN
      @renderTown(center, hexData.town)

    if hexData.type == HexData.TYPE_CITY
      @renderCity(center, col, row, hexData.city)

    if hexData.nubs != undefined and hexData.nubs.length > 0
      for nub in hexData.nubs
        @drawTrackNub(col, row, nub.sideA, nub.sideB)

    if hexData.previewNubs != undefined and hexData.previewNubs.length > 0
      for nub in hexData.previewNubs
        @drawTrackNub(col, row, nub.sideA, nub.sideB, "blue")

    if (hexData.cubes != undefined and hexData.cubes.length > 0)
      for cube in hexData.cubes
        @drawCube(center, col, row, cube)
