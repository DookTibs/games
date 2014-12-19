class window.RouteFinder
  constructor: (@board, @controller) ->

  routeSearch: (col, row, fromDir, depth, maxLinks = 6, traversalHistory = "") ->
    indent = ""
    for z in [1..depth]
      indent += "\t"

    if (depth > 20)
      console.log indent + "short circuiting!"
      return

    currHex = @board.getHexData(col, row)
    console.log indent + "examining [" + col + "," + row + "]"

    nextHistoryChunk = (if traversalHistory == "" then "" else "/") + col + "," + row + ":" + (if fromDir == -1 then 0 else fromDir) + ","
    if (currHex == undefined or currHex.type == HexData.TYPE_BLANK)
      console.log indent + "it's blank; stop"
      return
    else if (currHex.type == HexData.TYPE_CITY)
      if (depth > 2)
        console.log "!!!!!!!! RE REACHED [" + currHex.city.name + "]"
        @foundRoutes.push(traversalHistory + nextHistoryChunk + "0")
        return
      potentialExits = [1..6]
    else if (currHex.type == HexData.TYPE_TOWN)
      potentialExits = currHex.getNubEnds()
      console.log "!!!!! POTENTIAL EXITS FROM TOWN [" + potentialExits + "]..."
    else
      potentialExits = [currHex.getNubEnd(fromDir)]
      console.log indent + "#{fromDir} leads to " + currHex.getNubEnd(fromDir) + "..."

    for nextDir in potentialExits
      if (nextDir != null and nextDir != fromDir)
        # gotta do something special for towns to get right path here...
        console.log indent + "leave on #{nextDir}..."
        neighbor = AosBoard.getNeighborColRow(col, row, nextDir)

        @routeSearch(neighbor.col, neighbor.row, AosBoard.getOppositeSide(nextDir), depth+1, maxLinks, traversalHistory + nextHistoryChunk + nextDir)

  lookForRoute: (col, row) ->
    console.log "pathfinder looking for path from [" + col + "],[" + row + "]..."
    @foundRoutes = []
    @routeSearch(col, row, -1, 0)
    console.log "--- ALL DONE ---"
    console.log @foundRoutes
