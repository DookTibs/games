#represents the entire game board
class window.AosBoard
  @DIR_NO = 1
  @DIR_NE = 2
  @DIR_SE = 3
  @DIR_SO = 4
  @DIR_SW = 5
  @DIR_NW = 6

  constructor: (rows, cols, defaultType = HexData.TYPE_NORMAL) ->
    # console.log("building the board...")
    @boardStorage = []
    for r in [0..rows]
      rowData = []
      for c in [0..cols]
        console.log "loop #{r}, #{c}"
        rowData.push(new HexData(r, c, defaultType))
      @boardStorage.push(rowData)

  # given a column and row, and a direction to move in, give the column and row of that neighbor
  @getNeighborColRow: (col, row, dir) ->
    nCol = col
    nRow = row
    if (dir == AosBoard.DIR_NO) # up
      nRow--
    else if (dir == AosBoard.DIR_SO) # down
      nRow++
    else
      if (col % 2 == 1)
        if (dir == AosBoard.DIR_NE)
          nCol++
        else if (dir == AosBoad.DIR_SE)
          nCol++
          nRow++
        else if (dir == AosBoard.DIR_SW)
          nCol--
          nRow++
        else if (dir == AosBord.DIR_NW)
          nCol--
      else
        if (dir == AosBoard.DIR_NE)
          nRow--
          nCol++
        else if (dir == AosBoad.DIR_SE)
          nCol++
        else if (dir == AosBoard.DIR_SW)
          nCol--
        else if (dir == AosBord.DIR_NW)
          nCol--
          nRow--

    return { row: nRow, col: nCol }

  setHexTown: (col, row, townName) ->
    hd = @getHexData(col, row)
    hd.setTown({name: townName})

  setHexCity: (col, row, cityName, cityColor) ->
    hd = @getHexData(col, row)
    hd.setCity({name: cityName, color: cityColor})

  setHexType: (col, row, type) ->
    console.log "get data for [" + col + "],[" + row + "], ["+  type + "]"
    hd = @getHexData(col, row)
    hd.type = type

  addNubToHex: (col, row, nub) ->
    hd = @getHexData(col, row)
    hd.addNub(nub)

  getHexData: (col, row) ->
    hd = @boardStorage[row][col]
    return hd

  debugBoard: () ->
    console.log("board structure:")
    for row, r in @boardStorage
      rowRep = ""
      for slot, c in row
        hd = @getHexData(c, r)
        if hd.town != null
          rowRep += "[" + hd.town.name.substr(0,5) + "]\t"
        else if hd.city != null
          rowRep += "[" + hd.city.name.substr(0,5) + "]\t"
        else
          rowRep += "[" + hd.type.substr(0, 5) + "]\t"
      console.log rowRep
