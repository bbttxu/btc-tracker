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

R.map recordMatches, currencies
