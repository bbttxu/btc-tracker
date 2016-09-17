{ createStore, applyMiddleware } = require 'redux'

thunk = require 'redux-thunk'

R = require 'ramda'


{ORDER_MATCHED, fetchStats} = require './actions'

reducers = require './reducers'

store = createStore reducers, applyMiddleware(thunk.default)

store.subscribe (foo)->
  console.log store.getState()

Stream = require './lib/stream'



currencies = ['BTC-USD', 'LTC-USD', 'ETH-USD', 'BTC-ETH']

currencyStream = (product)->
  stream = Stream product

  stream.on 'message', (foo)->
    if foo.type is 'match'
      store.dispatch
        type: ORDER_MATCHED
        match: foo


R.map currencyStream, currencies

# store.dispatch fetchStats 'BTC-USD'
    # console.log ORDER_MATCHED, foo
