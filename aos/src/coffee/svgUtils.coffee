class window.SvgUtils
  @generateHexPoints: (center, size) ->
    rv = []
    for i in [0..5]
      angle = 2 * Math.PI/6 * i
      loopX = center.x + size*Math.cos(angle)
      loopY = center.y + size*Math.sin(angle)
      rv.push({x: loopX, y: loopY})
    rv
  
  @createPathFromPoints: (pts, closePath = true) ->
    if closePath
      pts.push(pts[0])
      
    rv = ""
    for pt, i in pts
      rv += if (i == 0) then "M" else "L" 
      rv += pt.x + " " + pt.y
    rv

  @drawCircle: (canvas, center, radius, attrs) ->
    console.log "DRAWING CIRCLE!"
    c = canvas.circle(center.x, center.y, radius)
    # c.attr({ class: className })
    c.attr(attrs)
    return c

  @drawText: (canvas, midpoint, text, attrs) ->
    t = canvas.text(midpoint.x, midpoint.y, text)
    t.attr(attrs)
    return t

  @drawRectangle: (canvas, origin, width, height, attrs) ->
    console.log "drawing rect #{origin.x}, #{origin.y}, #{width}, #{height}"
    r = canvas.rect(origin.x, origin.y, width, height)
    r.attr(attrs)
    return r

  @drawCenteredRectangle: (canvas, origin, width, height, attrs) ->
    console.log "drawing centered rect #{origin.x}, #{origin.y}, #{width}, #{height}"
    r = canvas.rect(origin.x - width/2, origin.y - height/2, width, height)
    r.attr(attrs)
    return r

  # draws a hex at center.x, center.y. distance from center to vertex is size. size is also length of a side (think of
  # the hex as being made of 6 equilateral triangles with length size
  # this draws hexes with flat side on top
  @drawHex: (canvas, center, size, attrs) ->
    pts = SvgUtils.generateHexPoints(center, size)
    path = SvgUtils.createPathFromPoints(pts)
    hex = canvas.path(path)

    hex.attr(attrs)
    return hex

  @getMidPoint: (pointA, pointB) ->
    return { x: (pointA.x + pointB.x) / 2, y: (pointA.y + pointB.y) / 2 }

  @getCoordsOfCircleAngle: (center, radius, angle) ->
    angleInRads = Snap.rad(angle)
    x = center.x + radius * Math.cos(angleInRads)
    y = center.y + radius * Math.sin(angleInRads)
    return { x: x, y: y}

  @createArcPath: (center, radius, startAngle, endAngle) ->
    startCoords = SvgUtils.getCoordsOfCircleAngle(center, radius, startAngle);
    endCoords = SvgUtils.getCoordsOfCircleAngle(center, radius, endAngle);

    xAxisRot = 0
    largeArcFlag = 0
    sweepFlag = 1

    if (endAngle < startAngle)
      # console.log "reversing sweep flag..."
      sweepFlag = 0

    arcPath = "M" + startCoords.x + "," + startCoords.y   # move to one point of arc
    arcPath += " A" + radius + "," + radius + " " + xAxisRot + " " + largeArcFlag + "," + sweepFlag   # arc
    arcPath += " " + endCoords.x + "," + endCoords.y      # to this point
    # arcPath += "z"                                        # do NOT close path

    # return SvgUtils.createPathFromPoints([startCoords, endCoords])
    # return SvgUtils.createPathFromPoints([center, {x: center.x + 300, y: center.y + 50}])
    return arcPath

  @mergePaths: (paths) ->
    rv = ""
    for p in paths
      rv += p
    return rv

  @animateAlongPath: (canvas, item, paths) ->
    mergedPaths = SvgUtils.mergePaths(paths)
    console.log "merged: [" + mergedPaths + "]"

    comboPath = canvas.path(mergedPaths)
    comboPath.attr({ fill: "none", stroke: "none" })

    easeFxn = mina.easeinout
    bbox = item.getBBox()
    initialPos = { x: bbox.x, y: bbox.y }
    Snap.animate(0, comboPath.getTotalLength(), ( (value) =>
      # console.log "value is [" + value + "]"
      movePoint = comboPath.getPointAtLength(value)
      # item.transform("t" + parseInt(movePoint.x) + "," + parseInt(movePoint.y))
      item.transform("t" + parseInt(movePoint.x - initialPos.x - bbox.width/2) + "," + parseInt(movePoint.y - initialPos.y - bbox.height/2))
      # item.x = movePoint.x
    ), 2000, easeFxn, ( () =>
      console.log "finished animation"
    ))
