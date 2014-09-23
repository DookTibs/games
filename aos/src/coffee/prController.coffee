class window.PuertoRicoAosController extends window.AosController

  constructor: () ->
    super(5, 13)

  buildBoard: () ->
    @board = new AosBoard(@ROWS, @COLS)

    mountains = [
        "1,3"
        "2,2"
        "2,3"
        "3,0"
        "3,1"
        "3,2"
        "4,1"
        "4,3"
        "5,0"
        "5,1"
        "5,2"
        "6,2"
        "6,3"
        "7,2"
        "7,3"
        "8,2"
        "9,2"
        "10,2"
    ]

    blanks = [
        "0,0"
        "1,4"
        "3,4"
        "5,4"
        "6,4"
        "7,4"
        "9,4"
        "10,4"
        "11,3"
        "11,4"
        "12,2"
        "12,3"
        "12,4"
    ]

    towns = [
        "0,2,Mayaguez"
        "0,4,Cabo Rojo"
        "1,0,Aguadilla"
        "4,0,Arecibo"
        "4,2,Utuado"
        "5,3,Ponce"
        "8,1,Bayamon"
        "8,3,Cayey"
        "9,1,Caguas"
        "11,2,Humacao"
        "12,0,Luquillo"
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

    @board.setHexCity(9, 0, "San Juan", "red")

    @board.debugBoard()
    console.log "done!"
