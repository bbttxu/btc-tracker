R = require 'ramda'
debounce = require 'throttle-debounce/debounce'
regression = require 'regression'
moment = require 'moment'
Lokijs = require 'lokijs'

db = new Lokijs 'gdax.csv'
trades = db.addCollection 'orderbook'

Stream = require './lib/stream'

valueStreams = [
  'BTC-USD'
  'ETH-USD'
  # 'eth-btc'
]

timeframes = [
  5,
  60,
  (60 * 24)
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
  time = moment(point.time).unix()
  price = parseFloat point.price
  # console.log time
  [time, price]

regress = (data)->
  # console.log 'regress1', data
  xy = R.map formTimeSeries, R.sort sortByTime, data
  # console.log 'regress2', xy
  result = regression 'linear', xy
  result.equation[0]

regressProductSide = (product)->
  # console.log 'product', product
  byTimeframe = (data)->
    regress R.map mapTimeSeries, R.filter filterSell, data


  R.map byTimeframe, product


rejectOld = (data)->
  console.log data
  tradeTime = moment data.time
  limit = moment().subtract 15, 'minutes'


regressProduct = (value, key, obj)->



  asdf = trades.find({'product_id': value})
  # console.log asdf


  doRegression = (timeframe)->
    rejectTooOld = (data)->
      tradeTime = moment data.time
      limit = moment().subtract 15, 'minutes'
      tradeTime.isBefore limit


    gated = R.reject rejectTooOld, asdf

    # timeframe
    value = regress gated

    # console.log timeframe, value, gated
    # 1
    # payload =
    #   "#{timeframe}": regress(gated)
    regress(gated)


  result =
    "#{value}": R.map doRegression, timeframes


# rejectOld = (data)->
#   tradeTime = moment data.time
#   limit = moment().subtract 15, 'minutes'
#   # console.log tradeTime.format(), limit.format(), limit.isAfter tradeTime
#   # false




update = debounce 1000, ->
  data = trades.find({})
  # data = R.reject rejectOld, data
  grouped = R.groupBy byProduct, data
  foo = R.map regressProduct, valueStreams

  # foo['USD-USD'] = 0.00

  console.log foo


handleMessage = (product)->
  (json)->
    if json.type is 'match'
      foo = trades.insert json
      # console.log foo
      match = R.pick ['price', 'product_id', 'time', 'side'], json
      data.push match
      update()


createStream = (product)->
  stream = Stream product
  handleProduct = handleMessage product
  stream.on 'message', handleProduct

R.forEach createStream, valueStreams

