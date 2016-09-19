{ createStore, applyMiddleware } = require 'redux'

thunk = require 'redux-thunk'

R = require 'ramda'

gdax = require './lib/gdax-client'

{ORDER_MATCHED, UPDATE_STATS} = require './actions'

reducers = require './reducers'

store = createStore reducers, applyMiddleware(thunk.default)

store.subscribe (foo)->
  console.log store.getState()

Stream = require './lib/stream'


currencies = ['BTC-USD', 'ETH-USD', 'ETH-BTC']

currencyStream = (product)->
  stream = Stream product

  stream.on 'message', (foo)->
    if foo.type is 'match'
      store.dispatch
        type: ORDER_MATCHED
        match: foo


R.map currencyStream, currencies

onThen = (data)->
  dispatchStats = (stats)->
    store.dispatch
      type: UPDATE_STATS
      stats: stats

  R.map dispatchStats, data

onError = (data)->
  console.log 'onError', data

updateStats = ->
  gdax.stats( currencies ).then( onThen ).catch( onError )

updateStats()
setInterval updateStats, 60 * 1000

# store.dispatch fetchStats 'BTC-USD'
    # console.log ORDER_MATCHED, foo
