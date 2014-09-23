class window.BarbadosAosController extends window.AosController

  constructor: () ->
    super(10, 8)

  buildBoard: () ->
    @board = new AosBoard(@ROWS, @COLS)

    mountains = [
        "1,0"
        "1,1"
        "1,2"
        "1,3"
        "1,4"
        "1,5"
        "2,3"
        "2,4"
        "2,5"
        "2,6"
        "3,3"
        "3,4"
        "3,5"
        "3,6"
        "4,5"
        "4,6"
        "5,5"
    ]

    blanks = [
        "0,8"
        "0,9"
        "1,9"
        "2,0"
        "2,9"
        "3,0"
        "3,1"
        "3,9"
        "4,0"
        "4,1"
        "4,2"
        "4,3"
        "5,0"
        "5,1"
        "5,2"
        "5,3"
        "5,9"
        "6,0"
        "6,1"
        "6,2"
        "6,3"
        "6,4"
        "6,9"
        "7,0"
        "7,1"
        "7,2"
        "7,3"
        "7,4"
        "7,8"
        "7,9"
    ]

    towns = [
        "0,2,???"
        "0,4,???"
        "1,8,???"
        "3,2,???"
        "5,6,???"
    ]

    typeMappers = [
        { coords: mountains, type: HexData.TYPE_MOUNTAIN }
        { coords: blanks, type: HexData.TYPE_BLANK }
    ]

    for tm in typeMappers
      coords = tm.coords  
      for coord in coords
        rowCol = coord.split(",")
        @board.setHexType(parseInt(rowCol[0]), parseInt(rowCol[1]), tm.type)

    for townData in towns
      data = townData.split(",")
      @board.setHexTown(parseInt(data[0]), parseInt(data[1]), data[2])

    color = "yellow"
    @board.setHexCity(0, 0, "North Point", color, 1)
    @board.setHexCity(4, 4, "???", color, 2)
    @board.setHexCity(6, 5, "???", color, 3)
    @board.setHexCity(0, 7, "???", color, 4)
    @board.setHexCity(4, 9, "???", color, 5)
    @board.setHexCity(7, 7, "???", color, 6)
    ###

    @board.debugBoard()
    console.log "done!"
    ###
