# represents content of a single hex
class window.HexData
  @TYPE_NORMAL = "norm"
  @TYPE_BLANK = "blank"
  @TYPE_TOWN = "town"
  @TYPE_CITY = "city"
  @TYPE_MOUNTAIN = "mtn"

  constructor: (r, c, t) ->
    # console.log "creating hexData at r=#{r}, c=#{c}"
    @id = "#{c},#{r}"
    @type = t
    @town = null
    @city = null
  
  setTown: (n) ->
    @town = n
    @type = HexData.TYPE_TOWN

#represents the entire game board
class window.AosBoard
  constructor: (rows, cols, defaultType = HexData.TYPE_NORMAL) ->
    # console.log("building the board...")
    @boardStorage = []
    for r in [0..rows]
      rowData = []
      for c in [0..cols]
        # console.log "loop #{r}, #{c}, #{@boardStorage}"
        rowData.push(new HexData(r, c, defaultType))
      @boardStorage.push(rowData)

  setHexTown: (col, row, townName) ->
    hd = @getHexData(col, row)
    hd.setTown(townName)

  setHexType: (col, row, type) ->
    hd = @getHexData(col, row)
    hd.type = type

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
          rowRep += "[" + hd.town + "]\t\t"
        else
          rowRep += "[" + hd.type + "]\t"
      console.log rowRep
