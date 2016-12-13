R = require 'ramda'
Lokijs = require 'lokijs'


db = new Lokijs 'predictions.json'
orders = db.addCollection 'orders', autosave: true


normalizeData = (data)->
  max = Math.max.apply null, R.map parseFloat, R.values data
  min = Math.min.apply null, R.map parseFloat, R.values data

  foo = (value, key)->
    value / max

  R.values R.mapObjIndexed foo, data



assembleData = (foo)->
  console.log foo
  doit =
    output: R.flatten normalizeData foo
  # output: R.map assembleData, foo
  # console.log foo

teach = ->
  console.log 'teach'

  query =
    product_id: 'BTC-USD'
    side: 'sell'

  data = orders.find query

  byResult = (order)->
    order.result

  grouped = R.groupBy byResult, data
  console.log grouped


  # console.log data
  # raw = R.map R.pick(['open', 'high', 'low', 'price']), data
  # console.log 'raw', raw

  # console.log 'normalized', R.map assembleData, raw


  # console.log data.length


prep = (data)->
  order = orders.insert data
  teach()


annotate = (annotation)->
  (id)->
    order = orders.findOne id: id
    if order
      order.result = annotation
      orders.update order
      # console.log annotation, order


module.exports =
  prep: prep
  cancel: annotate 'canceled'
  fill: annotate 'filled'
