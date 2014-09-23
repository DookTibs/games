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
  
  setTown: (d) ->
    @town = d # name
    @type = HexData.TYPE_TOWN

  setCity: (d) ->
    @city = d # name/color
    @type = HexData.TYPE_CITY

  addNub: (nub) ->
    @nubs.push(nub)

  addPreviewNub: (nub) ->
    @previewNubs.push(nub)

  clearPreviewNubs: () ->
    @previewNubs = []

  lockInPreviewNubs: () ->
    @nubs = @previewNubs
    @previewNubs = []

  rotatePreviewNubs: (dir) ->
    for nub in @previewNubs
      nub.rotate(dir)
