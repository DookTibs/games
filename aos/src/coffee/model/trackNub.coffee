class window.TrackNub
  constructor: (@sideA, @sideB) ->

  equals: (otherNub) ->
    if @sideA == otherNub.sideA and @sideB == otherNub.sideB
      return true
    else if @sideB == otherNub.sideA and @sideA == otherNub.sideB
      return true
    else
      return false
