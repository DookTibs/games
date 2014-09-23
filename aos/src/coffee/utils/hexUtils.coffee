class window.HexUtils
  @getGentleCurveAngles: (sideA, sideB) ->
    sidesApart = Math.abs(sideA - sideB)
    # console.log "get gentle curves for [" + sideA + "]->[" + sideB + "] (" + sidesApart + " sides apart)"

    frontHalfOnly = true

    ###
    if frontHalfOnly
      frontHalfOnlyAdjustment = 30
    else
    ###
    frontHalfOnlyAdjustment = 0

    if sidesApart == 2
      if (sideA < sideB)
        base = (sideA * 60) + 120
        rv = [base - frontHalfOnlyAdjustment, base-60]
      else
        base = (sideB * 60) + 120
        rv = [base-60, base - frontHalfOnlyAdjustment]
    else if sidesApart == 4
      if (sideA < sideB)
        base = (sideA - 1) * 60
        rv = [base, base+60 - frontHalfOnlyAdjustment]
      else
        base = (sideB - 1) * 60
        rv = [base+60 - frontHalfOnlyAdjustment, base]
    
    return rv

  @getSharpCurveAngles: (sideA, sideB) ->
    sidesApart = Math.abs(sideA - sideB)
    # console.log "get sharp curves for [" + sideA + "]->[" + sideB + "] (" + sidesApart + " sides apart)"

    if sidesApart == 1
      if (sideA < sideB)
        base = sideA * 60
        rv = [base+120, base]
      else
        base = sideB * 60
        rv = [base, base+120]
    else if sidesApart == 5
      if (sideA < sideB)
        rv = [0, 120]
      else
        rv = [120, 0]

    # console.log "going from [" + rv[0] + "] -> [" + rv[1] + "]"
    return rv

  @getSharedSidePoint: (sideAPoints, sideBPoints) ->
    if (sideAPoints[0].x == sideBPoints[1].x and sideAPoints[0].y == sideBPoints[1].y)
      return sideAPoints[0]
    else
      return sideAPoints[1]

