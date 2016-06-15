R = require 'ramda'
debounce = require 'throttle-debounce/debounce'
regression = require 'regression'
moment = require 'moment'
Stream = require './lib/stream'

valueStreams = [
  'btc-usd'
  'eth-usd'
  # 'eth-btc'
]

data = []

byProduct = (match)->
  match.product_id

filterSide = (side)->
  (data)->
    data.side is side

filterSell = filterSide 'sell'
filterBuy = filterSide 'buy'


mapTimeSeries = (data)->
  series = R.pick ['price', 'time'], data
  series['time'] = moment(series['time']).unix()
  series.price = parseFloat(series.price)
  series

sortByTime = (a, b)->
  a.time - b.time

formTimeSeries = (point)->
  # console.log point
  [point.time, point.price]

regress = (data)->
  # console.log 'regress'
  xy = R.map formTimeSeries, R.sort sortByTime, data
  results = regression 'linear', xy
  results.equation[0]

regressProductSide = (data)->
  regress R.map mapTimeSeries, R.filter filterSell, data

regressProduct = (value, key, obj)->
  regressProductSide value

update = debounce 6000, ->
  grouped = R.groupBy byProduct, data
  foo = R.mapObjIndexed regressProduct, grouped
  foo['USD-USD'] = 0.00

  console.log foo

handleMessage = (product)->
  (json)->
    if json.type is 'match'
      match = R.pick ['price', 'product_id', 'time', 'side'], json
      data.push match
      update match


createStream = (product)->
  stream = Stream product
  handleProduct = handleMessage product
  stream.on 'message', handleProduct

R.forEach createStream, valueStreams

