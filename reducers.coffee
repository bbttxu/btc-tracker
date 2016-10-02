R = require 'ramda'

regression = require 'regression'

initialState =
  prices: {}
  stats:
    'USD-USD':
      open: 1
      high: 1
      low: 1
      last: 1
      volume: 1
      volume_30day: 1

todoApp = (state, action) ->

  if action.type is 'ORDER_MATCHED'
    order = action.match

    state.prices[order.product_id] = {} unless state.prices[order.product_id]
    state.prices[order.product_id][order.side] = order.price

  if action.type is 'REQUEST_STATS'
    console.log action.stats

  if action.type is 'UPDATE_STATS'
    state.stats = R.mergeAll [ state.stats, action.stats ]

  if action.type is 'UPDATE_ACCOUNTS'
    # state.stats = R.mergeAll [ state.stats, action.stats ]
    # console.log 'UPDATE_ACCOUNTS', action.accounts

    foo = (bar)->
      gee = {}
      gee[bar.currency] = R.omit 'currency', bar
      gee

    state.accounts = R.mergeAll R.map foo, action.accounts


  if typeof state == 'undefined'
    return initialState


  foo = ( value, key )->
    regress = regression 'linear', [ [ 0, parseFloat( value.open ) ], [ ( 1 ), parseFloat( value.last ) ] ]

    equation =
      m: regress.equation[0]
      # c: regress.equation[1]

  state.trends = R.mapObjIndexed foo, state.stats

  values = R.values state.trends

  normalizeTrend = ( trends )->
    slopes = R.values R.pluck 'm', trends
    min = Math.min.apply null, slopes
    max = Math.max.apply null, slopes

    normalizeSlope = ( trend )->
      trend.normalizedM = ( ( trend.m - min ) / ( max - min ) - 0.5 ) * 2
      trend

    R.mapObjIndexed normalizeSlope, trends

  normalizeTrend state.trends

  up = ( value, key )->
    return true if value.normalizedM > 0

  state.sells = R.pickBy up, state.trends

  state.buys = R.omit R.keys(state.sells), state.trends

  asdf = (value, key)->
    parts = key.split '-'
    value.sell = parts[0]
    value.buy = parts[1]
    value



  foo = R.values R.mapObjIndexed asdf, state.sells

  # console.log foo

  reduceFoo = (foo)->
    sorted = R.reverse R.sortBy R.prop('normalizedM'), foo

    doNotBuy = []

    filterStuff = (z)->
      zzz = doNotBuy

      doNotBuy = R.uniq doNotBuy.concat z.sell

      return ! R.contains z.buy, zzz

    c = R.filter filterStuff, sorted

    c

  # console.log "\n***\n"

  # console.log foo
  highs = reduceFoo foo
  console.log 'highs', highs

  reduceBar = (foo)->
    sorted = R.sortBy R.prop('normalizedM'), foo

    doNotBuy = []

    filterStuff = (z)->
      zzz = doNotBuy

      doNotBuy = R.uniq doNotBuy.concat z.sell

      return ! R.contains z.buy, zzz

    c = R.filter filterStuff, sorted

    c



  # console.log "\n***\n"

  bar = R.values R.mapObjIndexed asdf, state.buys

  # console.log bar
  lows = reduceBar bar
  console.log 'lows', lows

  # console.log R.values R.mapObjIndexed asdf, state.buys

  state

module.exports = todoApp
