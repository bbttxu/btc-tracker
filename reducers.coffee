
initialState =
  market: {}

todoApp = (state, action) ->

  if action.type is 'ORDER_MATCHED'
    state.market = {} unless state.market
    state.market[action.match.side] = action.match.price

  if action.type is 'REQUEST_STATS'
    console.log action

  if action.type is 'UPDATE_STATS'
    console.log action

  if typeof state == 'undefined'
    return initialState

  # console.log state
  state

module.exports = todoApp
