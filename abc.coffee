require('dotenv').config( silent: true )

R = require 'ramda'

recordMatches = require './recordMatches'

currencies = [
  'BTC-USD',
  'ETH-USD',
  'ETH-BTC',
  'LTC-USD',
  'LTC-BTC',
]

sides = [ 'sell', 'buy']

R.map recordMatches, currencies


showStats = require './ml'

setInterval showStats, 60 * 1000
showStats()
