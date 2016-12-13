R = require 'ramda'
moment = require 'moment'

initialState =
  matched: []
  lines: {}


INTERVAL = 60
INTERVAL_FORMAT = 'X'

quantizeTime = ( data )->
  Math.floor moment( data.time ).format( INTERVAL_FORMAT ) / INTERVAL

todoApp = (state, action) ->

  if typeof state == 'undefined'
    return initialState


  if action.type is 'ORDER_MATCHED'
    order = action.match

    values = [ 'side', 'size', 'price', 'product_id', 'time' ]

    console.log order, R.pick values, order

    state.matched.push R.pick values, order


  foo = (asdf)->
    [ asdf.product_id, asdf.side ].join( '-' ).toUpperCase()

  state.lines = R.groupBy foo, state.matched





  asdf = (foo)->

    hits = R.groupBy quantizeTime, foo

    values = R.keys hits

    min = Math.min.apply this, values

    now = Math.floor moment().format( INTERVAL_FORMAT ) / INTERVAL

    timeseries = R.range( min, now )


    quantizeLine = ( tick )->
      if hits[tick] isnt undefined then 1 else 0

    R.takeLast 20, R.map quantizeLine, timeseries


  state.lines = R.mapObjIndexed asdf, state.lines


  state


module.exports = todoApp
