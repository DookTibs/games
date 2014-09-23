class window.AosController
  constructor: (@ROWS, @COLS) ->
    console.log "constructing standard game controller"

    document.body.addEventListener('touchmove', ( (evt) ->
      evt.preventDefault();
    ), false); 

    # tileDialog = $("<div>").attr("id", "tileChooserDialog").appendTo($("body"))
    # tileDialog.html("this is the tile chooser")

    # this belongs in default controller...
    console.log "constructing Puerto Rico controller"
    @hd = new HexGameBoard(this, "gameboard")
    @hd.sizeToFit(@ROWS, @COLS)
    @buildBoard()
    @renderBoard()

    @tb = new TileBank(this)
    @tb.initUi(@hd.getHexSize())


  getTownStyle: () ->
    return { stroke: "black", fill: "white" }
  
  getLabelStyle: () ->
    return genericLabelStyle = { fill: "black", "text-anchor": "middle" }

  @debug: (s) ->
    $("#debugger").html(s + "<br>" + $("#debugger").html())

  getStyleForHexType: (t) ->
    defaultStyle = { fill: "#659B74", stroke: "black" }
    mountainStyle = { fill: "grey", stroke: "black" };
    blankStyle = { fill: "none", stroke: "none" };
    redCityStyle = { stroke: "black", fill: "#E4473F" }

    if t == HexData.TYPE_MOUNTAIN
      return mountainStyle
    else if t == HexData.TYPE_BLANK
      return blankStyle
    else if t == HexData.TYPE_CITY
      return redCityStyle # really should look at color of city...
    else # town, normal, etc.
      return defaultStyle

  renderBoard: () ->
    for r in [0...@ROWS]
      for c in [0...@COLS]
        data = @board.getHexData(c, r)
        @hd.renderHexAt(c, r, data)

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
    actualOrigin = @hd.getHexPosition(0,0)
    coords = @pxToCoords(pixelX - actualOrigin.x, pixelY - actualOrigin.y)
    console.log(coords)
    # $("#boardhex_" + coords.c + "_" + coords.r).attr("fill", "purple")

  handleTileBankHexDrop: (pixelX, pixelY, nubs) ->
    actualOrigin = @hd.getHexPosition(0,0)
    coords = @pxToCoords(pixelX - actualOrigin.x, pixelY - actualOrigin.y)
    for nub in nubs
      @board.addNubToHex(coords.c, coords.r, new TrackNub(nub.a,nub.b))
    data = @board.getHexData(coords.c, coords.r)
    console.log(@board.renderHexAt)
    data.reset = true
    @hd.renderHexAt(coords.c, coords.r, data)

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
    size = @hd.getHexSize()
    c = 2/3 * x / size
    r = (-1/3 * x + 1/3*Math.sqrt(3) * y) / size
    return { c: c, r: r }

 
