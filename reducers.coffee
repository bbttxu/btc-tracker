R = require 'ramda'

regression = require 'regression'

initialState =
  prices: {}
  stats: {}

todoApp = (state, action) ->

  if action.type is 'ORDER_MATCHED'
    order = action.match

    state.prices[order.product_id] = {} unless state.prices[order.product_id]
    state.prices[order.product_id][order.side] = order.price

  if action.type is 'REQUEST_STATS'
    console.log action.stats

  if action.type is 'UPDATE_STATS'
    state.stats = R.mergeAll [ state.stats, action.stats ]

  if typeof state == 'undefined'
    return initialState


  foo = ( value, key )->
    regress = regression 'linear', [ [ 0, parseFloat(value.open) ], [ ( 24 * 60 * 60 ), parseFloat( value.last ) ] ]
    regress.equation[0]

  state.trends = R.mapObjIndexed foo, state.stats

  state

module.exports = todoApp
