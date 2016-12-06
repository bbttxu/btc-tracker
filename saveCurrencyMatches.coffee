R = require 'ramda'

recordMatches = require './recordMatches'

module.exports = ( currencies )->
  R.map recordMatches, currencies

