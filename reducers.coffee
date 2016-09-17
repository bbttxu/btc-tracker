
initialState =
  prices: {}

todoApp = (state, action) ->

  if action.type is 'ORDER_MATCHED'
    order = action.match

    state.prices[order.product_id] = {} unless state.prices[order.product_id]
    state.prices[order.product_id][order.side] = order.price

  if action.type is 'REQUEST_STATS'
    console.log action

  if action.type is 'UPDATE_STATS'
    console.log action

  if typeof state == 'undefined'
    return initialState

  # console.log state
  state

module.exports = todoApp
