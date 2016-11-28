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




quantizeData = require './jkl'



quantizeData( 'ETH-USD', 'buy', 600 ).then (data)->
  console.log data
