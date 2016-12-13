require('dotenv').config( silent: true )

config = require './config'

INTERVAL = 300

R = require 'ramda'
RSVP = require 'rsvp'
mongo = require('mongodb').MongoClient
moment = require 'moment'
regression = require 'regression'

pricing = require './pricing'

currencies = R.keys config.currencies

sides = [
  'sell',
  'buy',
]

intervals = [
  150,
  300,
  900,
  3600
]

INTERVAL = Math.max.apply this, intervals

letsDoCurrencies = ( currency )->
  addSide = (side)->
    foo =
      product_id: currency
      side: side
      time:
        $gte: moment().subtract( INTERVAL, 's' ).format()
      # interval: INTERVAL

  R.map addSide, sides


docsToCartesian = (doc)->
  # console.log doc
  # doc
  x = moment( doc.time ).unix()
  y = parseFloat doc.price
  coords =
  doc
  [ x, y ]


makeStats = (docs)->
  equation = ( regression( 'linear', R.map docsToCartesian, docs ).equation )
  slope = equation[0]
  intercept = equation[1]

  stats = {}
    # slope: equation[0]
    # intercept: equation[1]

  latest = R.last docs

  if latest
    latestPrice = parseFloat latest.price
    now = moment().add( INTERVAL, 'seconds' ).unix()
    # stats.projection = latestPrice
    # stats.last = pricing.btc latestPrice

    x = moment().valueOf() + INTERVAL
    ymxb = pricing.usd ( slope * now ) + intercept
    stats.projection = ymxb
    stats.n = docs.length

  stats


makeIntervalStats = (docs)->
  ( interval )->

    backTo = moment().utc().subtract( interval, 'seconds' )

    beforeBackTo = ( data )->
      moment( data.time ).isBefore backTo

    pastInterval = R.reject beforeBackTo, docs

    # console.log interval, pastInterval.length

    obj = {}
    obj[ interval ] = makeStats pastInterval
    obj


asdf = (search)->
  new RSVP.Promise (resolve, reject)->
    mongo.connect process.env.MONGO_URL, (err, db)->
      reject err if err

      collection = db.collection 'matches'

      foo = collection.find( search ).sort( time: 1).toArray (err, docs)->
        db.close()

        currencyStats = makeIntervalStats docs

        resolve R.mergeAll R.map currencyStats, intervals

makeKeys = ( data )->
  obj = {}
  key = [ data.product_id, data.side ].join( '-' ).toUpperCase()
  obj[key] = asdf data
  obj

lookups = R.flatten R.map letsDoCurrencies, currencies

keyed = R.mergeAll R.map makeKeys, lookups

catchProblem = (problem)->
  console.log 'problem'
  console.log problem


getResult = ( results )->
  console.log moment().format()
  showObjects = (a, b)->
    console.log b, a.value

  R.mapObjIndexed showObjects, results

  # console.log results


asdf = ->
  RSVP.hashSettled( keyed ).then( getResult ).catch( catchProblem )

asdf()
setInterval asdf, 60000
