R = require 'ramda'
RSVP = require 'rsvp'
acct = require 'accounting'
moment = require 'moment'
mongo = require('mongodb').MongoClient

client = require './lib/coinbase-client'
describe = require './lib/describeTrades'
logger = require './lib/logger'
notify = require './notification'

authed = undefined
log = console.log

findOrCreateFill = (db, fill)->
  new RSVP.Promise (resolve, reject)->
    collection = db.collection 'fills'

    collection.findOne {trade_id: fill.trade_id}, (err, gee)->
      reject err if err

      # TODO This should probably be a new function/RSVP.Promise
      if gee is null
        collection.insertOne fill, (err, whiz)->
          reject err if err
          resolve fill

      else
        resolve true

saveFill = (fill)->
  new RSVP.Promise (resolve, reject)->
    mongo.connect process.env.MONGO_URL, (err, db)->
      reject err if err

      onThen = (data)->
        resolve data

      onCatch = (data)->
        reject data

      closeDB = ->
        db.close()

      findOrCreateFill(db, fill).then(onThen).catch(onCatch).finally(closeDB)


impact = ( fill )->
  usd = fill.size * fill.price
  usd = usd * -1.0 if fill.side is 'buy'
  usd - fill.fee


isBuy = ( fill )->
  fill.side is 'buy'


isTrue = (result)->
  true is result


notifyOfUpdates = (updates)->
  details = describe updates

  # console.log details
  #notify details
  details

onDone = (data)->
  newUns = R.reject isTrue, data
  details = 'no updates'
  details = notifyOfUpdates(newUns) if newUns.length > 0
  log 'notify:', details

onError = (err)->
  log 'error', err


logNewFills = ( data )->
  log 'logNewFills', R.uniq R.pluck 'product_id', data
  checks = R.map saveFill, data

  RSVP.all(checks).then(onDone).catch(onError)


runScheduled = ->
  authed.getFills().then(logNewFills)


module.exports = (product, hours)->
  log = logger product
  log "Update Fills every #{hours} hours"
  authed = client product
  setInterval runScheduled, 1000 * 60 * 60 * hours
  runScheduled()
