require('dotenv').load()

R = require 'ramda'
RSVP = require 'rsvp'
moment = require 'moment'
acct = require 'accounting'
mongo = require('mongodb').MongoClient

notify = require './notification'


impact = ( fill )->
  usd = fill.size * fill.price
  usd = usd * -1.0 if fill.side is 'buy'
  usd - fill.fee


productValue = (product, days)->
  new RSVP.Promise (resolve, reject)->
    mongo.connect process.env.MONGO_URL, (err, db)->
      reject err if err

      collection = db.collection 'fills'

      now = moment()
      ago = now.subtract(days, 'days').format()

      collection.find({product_id: product, created_at:{ $gt: ago}}).toArray().then (data)->
        result = acct.formatMoney R.sum R.map impact, data
        db.close()
        resolve result


productValueOverTime = (product)->
  timeframes = [1, 7, 28]

  new RSVP.Promise (resolve, reject)->
    productOverTime = (days)->
      productValue product, days

    queries = RSVP.all( R.map productOverTime, timeframes).then (jk)->
      resolve "#{product}: #{jk.join(' / ')}"


showProgress = ->
  RSVP.all( R.map productValueOverTime, ['BTC-USD', 'ETH-USD', 'LTC-USD'] ).then (lol)->
    message = lol.join("\n")
    notify message
    console.log message

module.exports = ->
  # showProgress()
  setTimeout showProgress, 1000 * 60 * 5
  setInterval showProgress, 1000 * 60 * 60 * 23


