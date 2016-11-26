R = require 'ramda'
moment = require 'moment'
uuid = require 'uuid'

regression = require 'regression'



def = require './def'
ghi = require './ghi'

pricing = require './pricing'


INTERVAL = 900

initialState =
  filled: []
  prices: {}
  rates: {}
  bids: []
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

    values = [ 'side', 'price', 'product_id', 'time' ]

    order = R.pick values, order
    order.time = moment( order.time ).valueOf()

    state.filled.push order

    asdf = def order.product_id, order.side, INTERVAL, state.filled

    if asdf
      # it might not exist
      state.rates[order.product_id] = {} unless state.rates[order.product_id]

      # update with new slope
      x = moment().valueOf() + INTERVAL
      ymxb = ( asdf[0] * x ) + asdf[1]

      projectedPrice = pricing.btc ymxb
      projectedPriceChange = pricing.usd ( ymxb - state.prices[order.product_id][order.side] )

      state.rates[order.product_id][order.side] = projectedPrice
      state.rates[order.product_id][order.side + 'Diff'] = projectedPriceChange

      value = parseFloat projectedPriceChange

      if value <= 0 and order.side is 'sell'
        delete state.rates[order.product_id][order.side]
        delete state.rates[order.product_id][order.side + 'Diff']

      if value >= 0 and order.side is 'buy'
        delete state.rates[order.product_id][order.side]
        delete state.rates[order.product_id][order.side + 'Diff']


    state.filled = ghi INTERVAL, state.filled

    # console.log state.filled.length, 'length'



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

  foo = (asdf, currency)->
    createBid = ( sell, side )->
      data =
        side: side
        price: sell
        product_id: currency
        client_oid: uuid.v4()

      # console.log 'data', data
      data

    sides = R.pick ['sell', 'buy'], asdf

    R.map createBid, sides

    akdfjk = R.values R.mapObjIndexed createBid, sides
    akdfjk




  bids = R.flatten R.values R.mapObjIndexed foo, state.rates

  # console.log 'bids', bids

  state.bids = bids

  state

module.exports = todoApp
