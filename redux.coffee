{ createStore, applyMiddleware } = require 'redux'

thunk = require 'redux-thunk'

R = require 'ramda'

gdax = require './lib/gdax-client'

{ORDER_MATCHED, UPDATE_STATS, UPDATE_ACCOUNTS} = require './actions'

reducers = require './reducers'

store = createStore reducers, applyMiddleware(thunk.default)

store.subscribe (foo)->
  keys = [ 'prices', 'rates' ]
  keys = [ 'rates', 'bids' ]
  keys = [ 'bids' ]

  # console.log new Date(), R.keys store.getState()
  console.log new Date(), R.pick keys, store.getState()

Stream = require './lib/stream'


currencies = [
  'BTC-USD',
  'ETH-USD',
  'ETH-BTC',
  'LTC-USD',
  'LTC-BTC',
]

currencyStream = (product)->
  stream = Stream product

  stream.on 'error', (foo)->

    console.log 'error'
    console.log foo


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


updateAccounts = ->
  onSuccess = ( data )->
    store.dispatch
      type: UPDATE_ACCOUNTS
      accounts: data


  onError = ( error )->
    console.log 'onError', error

  gdax.getAccounts().then( onSuccess ).catch( onError )

updateAccounts()
setInterval updateAccounts, 60 * 60 * 1000


# store.dispatch fetchStats 'BTC-USD'
    # console.log ORDER_MATCHED, foo
