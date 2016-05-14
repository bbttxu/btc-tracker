R = require 'ramda'
RSVP = require 'rsvp'
acct = require 'accounting'
moment = require 'moment'
mongo = require('mongodb').MongoClient

client = require './lib/coinbase-client.coffee'

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
  earliest = ( R.take 1, (R.pluck 'created_at', updates).sort() )[0]

  impacts = R.map impact, updates
  total = R.sum impacts
  buys = R.sum R.map impact, R.filter isBuy, updates
  sells = R.sum R.map impact, R.reject isBuy, updates

  details = "#{acct.formatMoney(total)}; (#{acct.formatMoney(buys)}), #{acct.formatMoney(sells)}, since #{moment.utc(earliest).format('YYYY MMMM, DD')}"

  console.log details


onDone = (data)->
  newUns = R.reject isTrue, data
  notifyOfUpdates(newUns) if newUns.length > 0

onError = (err)->
  console.log 'error', err


logNewFills = ( data )->
  checks = R.map saveFill, data

  RSVP.all(checks).then(onDone).catch(onError)


runScheduled = ->
  client.getFills().then(logNewFills)


runScheduled()
