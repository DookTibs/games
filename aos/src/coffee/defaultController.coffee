class window.AosController
  constructor: () ->
    console.log "constructing standard game controller"

  getTownStyle: () ->
    return { stroke: "black", fill: "white" }
  
  getLabelStyle: () ->
    return genericLabelStyle = { fill: "black", "text-anchor": "middle" }

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
        @hd.renderHexAt(c, r, data, @getStyleForHexType(data.type))
    
    # post rendering tasks - for instance bring borders to the front so they look correct
    SvgUtils.bringToFront(".hex_outlines")
