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
    @previewNubs = []
    @cubes = []
  
  setTown: (d) ->
    @town = d # name
    @type = HexData.TYPE_TOWN

  setCity: (d) ->
    @city = d # name/color
    @type = HexData.TYPE_CITY

  addNub: (nub) ->
    if (@town == null and @city == null)
      @nubs.push(nub)
    else if (@town != null)
      if nub.sideA == 0 or nub.sideB == 0
        @nubs.push(nub)
      else
        @nubs.push(new TrackNub(0, nub.sideA))
        @nubs.push(new TrackNub(0, nub.sideB))

  addPreviewNub: (nub) ->
    @previewNubs.push(nub)

  clearPreviewNubs: () ->
    @previewNubs = []

  lockInPreviewNubs: () ->
    @nubs = @previewNubs
    @previewNubs = []

  addCube: (cube) ->
    @cubes.push(cube)

  # return ALL nub exits
  getNubEnds: () ->
    rv = []
    for nub in @nubs
      if nub.sideA != 0 then rv.push(nub.sideA)
      if nub.sideB != 0 then rv.push(nub.sideB)
    return rv

  getNubEnd: (nubStart) ->
    for nub in @nubs
      if (nub.sideA == nubStart)
        return nub.sideB
      else if (nub.sideB == nubStart)
        return nub.sideA
    return null

  # removes the first cube of a given color from the hex
  removeCube: (cube) ->
    for c, idx in @cubes
      if c.color == cube.color
        @cubes.splice(idx, 1)
        break

  rotatePreviewNubs: (dir) ->
    for nub in @previewNubs
      nub.rotate(dir)
