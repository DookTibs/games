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
    @nubs = []
  
  setTown: (d) ->
    @town = d # name
    @type = HexData.TYPE_TOWN

  setCity: (d) ->
    @city = d # name/color
    @type = HexData.TYPE_CITY

  addNub: (nub) ->
    @nubs.push(nub)

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
    hd.setTown({name: townName})

  setHexCity: (col, row, cityName, cityColor) ->
    hd = @getHexData(col, row)
    hd.setCity({name: cityName, color: cityColor})

  setHexType: (col, row, type) ->
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
