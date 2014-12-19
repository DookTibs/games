class window.AosController
  constructor: (@ROWS, @COLS) ->
    console.log "constructing standard game controller with [" + @ROWS + "] rows and [" + @COLS + "] cols"

    document.body.addEventListener('touchmove', ( (evt) ->
      evt.preventDefault();
    ), false); 

    # tileDialog = $("<div>").attr("id", "tileChooserDialog").appendTo($("body"))
    # tileDialog.html("this is the tile chooser")

    # this belongs in default controller...
    @renderer = new BoardRenderer(this, "gameboard")
    @renderer.sizeToFit(@ROWS, @COLS)
    console.log "build the board..."
    @buildBoard()
    console.log "render the board..."
    @renderBoard()

    @tileBank = new TileBank(this)
    @tileBank.initUi(@renderer.getHexSize())

    $(window).resize(() =>
      console.log "handle resize!"
      @renderer.sizeToFit(@ROWS, @COLS)
      @renderBoard(true)
      # @tileBank.initUi(@renderer.getHexSize())
    )

  findRouteFromHex: (col, row, extraStuff) ->
    console.log "let's attempt to find a path from [" + col + "],[" + row + "]"
    @routeFinder = new RouteFinder(@board, this)
    @routeFinder.lookForRoute(col, row)

    routes = @routeFinder.foundRoutes
    r = routes[0]
    paths = []
    for step in r.split("/")
      console.log "next step [" + step + "]"
      coordsAndSides = step.split(":")
      coords = (coordsAndSides[0]).split(",")
      sides = (coordsAndSides[1]).split(",")
      path = @renderer.getPathForSideToSide(parseInt(coords[0]), parseInt(coords[1]), parseInt(sides[0]), parseInt(sides[1]))
      console.log "converted path: " + path
      paths.push(path)
    SvgUtils.bringToFront(".cube")
    SvgUtils.animateAlongPath(@renderer.snapCanvas, extraStuff.cube, paths)

  getTownStyle: () ->
    return { stroke: "black", fill: "white" }
  
  getLabelStyle: () ->
    return genericLabelStyle = { fill: "black", "text-anchor": "middle" }

  @debug: (s) ->
    $("#debugger").html(s + "<br>" + $("#debugger").html())

  getStyleForHexType: (hexData) ->
    defaultStyle = { fill: "#659B74", stroke: "black" }
    mountainStyle = { fill: "grey", stroke: "black" };
    blankStyle = { fill: "none", stroke: "none" };
    redCityStyle = { stroke: "black", fill: "#E4473F" }
    yellowCityStyle = { stroke: "black", fill: "#FFFF00" }

    t = hexData.type

    if t == HexData.TYPE_MOUNTAIN
      return mountainStyle
    else if t == HexData.TYPE_BLANK
      return blankStyle
    else if t == HexData.TYPE_CITY
      if hexData.city.color == "red"
        return redCityStyle
      else if hexData.city.color == "yellow"
        return yellowCityStyle
    else # town, normal, etc.
      return defaultStyle

  drawHexAt: (c, r, reset) ->
    data = @board.getHexData(c, r)
    data.reset = reset 
    @renderer.renderHexAt(c, r, data)

  renderBoard: (reset = false) ->
    for r in [0...@ROWS]
      for c in [0...@COLS]
        @drawHexAt(c, r, reset)

    # bh = $("#boardhex_5_2")
    # bh.attr("fill", "orange")
    
    # post rendering tasks - for instance bring borders to the front so they look correct
    SvgUtils.bringToFront(".hex_outlines")

  # convert cube to odd-q offset
  convertCubeToOffset: (x, y, z) ->
    c = x
    r = z + (x - (x&1)) / 2
    return { c: c, r: r }

  # convert odd-q offset to cube
  convertOffsetToCube: (c, r) ->
    x = c
    z = r - (c - (c&1)) / 2
    y = -x-z
    return {x: x, y: y, z: z}

  convertCubeToAxial: (x, y, z) ->
    c = x
    r = z
    return { c: c, r: r }

  convertAxialToCube: (c, r) ->
    # convert axial to cube
    x = c
    z = r
    y = -x-z
    return {x:x, y:y, z:z}

  pxToCoords: (x, y) ->
    approxCoords = @findApproxAxialLocation(x, y)
    cubed = @convertAxialToCube(approxCoords.c, approxCoords.r)
    roundedCoords = @hexRound(cubed.x, cubed.y, cubed.z)
    offset = @convertCubeToOffset(roundedCoords.x, roundedCoords.y, roundedCoords.z)
    console.log(offset.c + "," + offset.r)
    return { c: offset.c, r: offset.r }

  findCoords: (pixelX, pixelY) ->
    actualOrigin = @renderer.getHexPosition(0,0)
    coords = @pxToCoords(pixelX - actualOrigin.x, pixelY - actualOrigin.y)
    console.log(coords)
    # $("#boardhex_" + coords.c + "_" + coords.r).attr("fill", "purple")

  handleTileBankOk: () ->
    @board.lockInPreviewNubs(@previewHexCoords.c, @previewHexCoords.r)
    @drawHexAt(@previewHexCoords.c, @previewHexCoords.r, true)
    @tileBank.hideRotationUi() 
    $("#tileChooserDialog").dialog("open")

  handleTileBankCancel: () ->
    @board.clearPreviewNubs(@previewHexCoords.c, @previewHexCoords.r)
    @drawHexAt(@previewHexCoords.c, @previewHexCoords.r, true)
    @tileBank.hideRotationUi() 
    $("#tileChooserDialog").dialog("open")

  handleTileBankPreviewRotation: (dir) ->
    @board.rotatePreviewNubs(@previewHexCoords.c, @previewHexCoords.r, dir)
    # data = @board.getHexData(@previewHexCoords.c, @previewHexCoords.r)
    # data.reset = true
    # @renderer.renderHexAt(@previewHexCoords.c, @previewHexCoords.r, data)
    @drawHexAt(@previewHexCoords.c, @previewHexCoords.r, true)

  handleTileBankHexDrop: (pixelX, pixelY, nubs) ->
    firstHexOrigin = @renderer.getHexPosition(0,0)
    coords = @pxToCoords(pixelX - firstHexOrigin.x, pixelY - firstHexOrigin.y)
    for nub in nubs
      @board.addPreviewNubToHex(coords.c, coords.r, new TrackNub(nub.a,nub.b))
    @drawHexAt(coords.c, coords.r, true)
    # data = @board.getHexData(coords.c, coords.r)
    # data.reset = true
    # @renderer.renderHexAt(coords.c, coords.r, data)

    @previewHexCoords = coords

    # show the rotation ui
    hexCoords = @renderer.getHexPosition(coords.c, coords.r)
    @tileBank.showRotationUi(hexCoords, @renderer.getHexSize() * 2.2)

  hexRound: (x, y, z) ->
    rx = Math.round(x)
    ry = Math.round(y)
    rz = Math.round(z)

    x_diff = Math.abs(rx - x)
    y_diff = Math.abs(ry - y)
    z_diff = Math.abs(rz - z)

    if x_diff > y_diff and x_diff > z_diff
      rx = -ry-rz
    else if y_diff > z_diff
      ry = -rx-rz
    else
      rz = -rx-ry

    return {x:rx, y:ry, z:rz}

  findApproxAxialLocation: (x, y) ->
    size = @renderer.getHexSize()
    c = 2/3 * x / size
    r = (-1/3 * x + 1/3*Math.sqrt(3) * y) / size
    return { c: c, r: r }

 
