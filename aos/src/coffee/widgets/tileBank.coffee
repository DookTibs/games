class window.TileBank
  constructor: (@controller) ->
    $("#tileChooserDialog").dialog({
      title: "Pick a tile"
      autoOpen: false
      width: 380
      height: 150
      modal: false
    })

    $("#tileChooserLauncher").click(() ->
      $("#tileChooserDialog").dialog("open")
    )

    $("#tileRotater #leftRot").click(() => @controller.handleTileBankPreviewRotation(-1))
    $("#tileRotater #rightRot").click(() => @controller.handleTileBankPreviewRotation(1))
    $("#tileRotater #okTile").click(() => @controller.handleTileBankOk())
    $("#tileRotater #cancelTile").click(() => @controller.handleTileBankCancel())

  hideRotationUi: () ->
    $("#tileRotater").css("display", "none")

  showRotationUi: (coords, size) ->
    rotateUi = $("#tileRotater")
    rotateUi.width(size).height(size)
    rotateUi.css({ display: "block", left: coords.x - rotateUi.width()/2.2, top: coords.y - rotateUi.height()/2.2})


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
      tempRenderer = new BoardRenderer(@controller, pd.id)
      tempRenderer.setHexSize(tileSize)
      tempRenderer.SIDE_PADDING = 0
      tempRenderer.renderHexAt(0, 0, {type: HexData.TYPE_NORMAL})
      for nub in pd.nubs
        tempRenderer.drawTrackNub(0, 0, nub.a, nub.b)

      $("#" + pd.id).attr("nubData", JSON.stringify(pd.nubs))

      ctrl = @controller
      $("#" + pd.id).draggable({ containment: "#gameboard", appendTo: "body", helper: "clone", start: (() ->
        console.log "start drag!"
        $("#tileChooserDialog").dialog("close")
      ), stop: ((evt) ->
        svgOffset = $("#gameboard").offset()
        svgX = evt.pageX - svgOffset.left
        svgY = evt.pageY - svgOffset.top
        console.log "stop!"
        console.log $(this).attr("nubData")
        ctrl.handleTileBankHexDrop(svgX, svgY, JSON.parse($(this).attr("nubData")))
        # $("#tileChooserDialog").dialog("open")
      ), drag: ((evt) =>
        svgOffset = $("#gameboard").offset()
        svgX = evt.pageX - svgOffset.left
        svgY = evt.pageY - svgOffset.top
        @controller.findCoords(svgX, svgY)
      )})

      $("#" + pd.id).height(tempRenderer.hexHeight)
      $("#" + pd.id).width(tempRenderer.hexWidth)
