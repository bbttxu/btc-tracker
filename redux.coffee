{ createStore, applyMiddleware } = require 'redux'

thunk = require 'redux-thunk'

{ORDER_MATCHED, fetchStats} = require './actions'

reducers = require './reducers'

store = createStore reducers, applyMiddleware({thunkMiddleware: thunk})

store.subscribe (foo)->
  console.log store.getState()



Stream = require './lib/stream'

stream = Stream 'BTC-USD'

stream.on 'message', (foo)->
  if foo.type is 'match'
    store.dispatch
      type: ORDER_MATCHED
      match: foo


store.dispatch fetchStats 'BTC-USD'
    # console.log ORDER_MATCHED, foo
