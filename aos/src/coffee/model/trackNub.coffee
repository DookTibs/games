class window.TrackNub
  constructor: (@sideA, @sideB) ->

  equals: (otherNub) ->
    if @sideA == otherNub.sideA and @sideB == otherNub.sideB
      return true
    else if @sideB == otherNub.sideA and @sideA == otherNub.sideB
      return true
    else
      return false
  
  stayInBounds: (x) ->
    if x > 6
      return x % 6
    else if x < 1
      return 6 - (x % 6)
    else
      return x

  rotate: (dir) ->
    # console.log "rotate the nub [" + dir + "] (" + @sideA + " <-> " + @sideB + ")"
    @sideA += dir
    @sideB += dir

    @sideA = @stayInBounds(@sideA)
    @sideB = @stayInBounds(@sideB)
    # console.log "after rot, (" + @sideA + " <-> " + @sideB + ")"
