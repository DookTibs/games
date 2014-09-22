class window.TileBank
  constructor: (@controller) ->
    $("#tileChooserDialog").dialog({
      title: "Pick a tile"
      autoOpen: true
      width: 380
      height: 150
      modal: false
    })

    $("#tileChooserLauncher").click(() ->
      $("#tileChooserDialog").dialog("open")

    )

  initUi: (tileSize) ->
    pickerData = [
      {id: "straightPicker", nubs: [
          { a: 1, b: 4 }
        ]}
      {id: "gentlePicker", nubs: [
          { a: 1, b: 3 }
        ]}
      {id: "sharpPicker", nubs: [
          { a: 1, b: 2 }
        ]}
      {id: "crossPicker", nubs: [
          { a: 5, b: 3 }
          { a: 1, b: 4 }
        ]}
    ]

    for pd in pickerData
      hgb = new HexGameBoard(@controller, pd.id)
      hgb.setHexSize(tileSize)
      hgb.SIDE_PADDING = 0
      hgb.renderHexAt(0, 0, {type: HexData.TYPE_NORMAL})
      for nub in pd.nubs
        hgb.drawTrackNub(0, 0, nub.a, nub.b)
      $("#" + pd.id).draggable({ containment: "#gameboard", appendTo: "body", helper: "clone", start: (() ->
        console.log "start drag!"
        $("#tileChooserDialog").dialog("close")
      ), stop: (() ->
        $("#tileChooserDialog").dialog("open")
      ), drag: ((evt) ->
        console.log("dragging...")
        svgOffset = $("#gameboard").offset()
        svgX = evt.pageX - svgOffset.left
        svgY = evt.pageY - svgOffset.top
        console.log(svgX + "," + svgY)
      )})

      $("#" + pd.id).height(hgb.hexHeight)
      $("#" + pd.id).width(hgb.hexWidth)
