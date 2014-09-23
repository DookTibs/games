class window.Pathfinder
  constructor: (@board, @controller) ->

  pathSearch: (col, row, fromDir, depth, maxLinks = 6, traversalDataDuper = null) ->
    traversalData = {
      numLinks: 0
      visitedPopulationCenterHexes: []
      nubs: []
    }

    if traversalDataDuper != null
      traversalData.numLinks = traversalDataDuper.numLinks
      for dupe in traversalDataDuper.visitedPopulationCenterHexes
        traversalData.visitedPopulationCenterHexes.push(dupe)
      for nub in traversalDataDuper.nubs
        traversalData.nubs.push(nub)

    indent = ""
    for z in [1..depth]
      indent += "\t"

    if (depth > 20)
      console.log indent + "short circuiting!"
      return

    currHex = @board.getHexData(col, row)
    console.log indent + "examining [" + col + "," + row + "]"

    if (currHex == undefined or currHex.type == HexData.TYPE_BLANK)
      console.log indent + "it's blank; stop"
      return
    else if (currHex.type == HexData.TYPE_CITY)
      if (depth > 2)
        traversalData.numLinks++
        console.log "!!!!!!!! RE REACHED [" + currHex.city.name + "] in [" + traversalData.numLinks + " links"
        @foundPaths.push(traversalData)
        return
      potentialExits = [1..6]
    else if (currHex.type == HexData.TYPE_TOWN)
      potentialExits = currHex.getNubEnds()
      console.log "!!!!! POTENTIAL EXITS FROM TOWN [" + potentialExits + "]..."
      traversalData.numLinks++
      console.log "now [" + traversalData.numLinks + "] links"
    else
      potentialExits = [currHex.getNubEnd(fromDir)]
      console.log indent + "#{fromDir} leads to " + currHex.getNubEnd(fromDir) + "..."

    for nextDir in potentialExits
      if (nextDir != null and nextDir != fromDir)
        # gotta do something special for towns to get right path here...
        console.log indent + "leave on #{nextDir}..."
        traversalData.nubs.push(new TrackNub(fromDir, nextDir))
        neighbor = AosBoard.getNeighborColRow(col, row, nextDir)
        @pathSearch(neighbor.col, neighbor.row, AosBoard.getOppositeSide(nextDir), depth+1, maxLinks, traversalData)

  lookForPath: (col, row) ->
    console.log "pathfinder looking for path from [" + col + "],[" + row + "]..."
    @foundPaths = []
    @pathSearch(col, row, -1, 0)
    console.log "--- ALL DONE ---"
    console.log @foundPaths
