{pricing} = require '../defaults'

R = require 'ramda'

spreadPrice = require './spreadPrice'

required =
  side: 'sell'

sellStructure = (options)->
  settings = R.mergeAll [ pricing, options, required ]

  # Ensure USD offset and interval are negative
  settings.usdOffset = ( -1.0 * settings.usdOffset ) if settings.usdOffset < 0
  settings.usdInterval = ( -1.0 * settings.usdInterval ) if settings.usdInterval < 0

  # Create pricing structure
  spreadPrice settings

module.exports = sellStructure
