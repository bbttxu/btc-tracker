require('dotenv').config( silent: true )

mongo = require('mongodb').MongoClient
R = require 'ramda'
RSVP = require 'rsvp'
moment = require 'moment'

pricing = require './pricing'

smallPotatoes = (doc)->
  doc.volume is 0 or doc.delta is 0


module.exports = ( product, side, interval = 60 )->
  search =
    product_id: product
    side: side

  timeSeries = (doc)->
    interval = interval

    time = moment( doc.time ).unix()

    Math.ceil( time / interval )

  stats = (docs)->
    obj = {}

    prices = R.pluck 'price', docs

    high = Math.max.apply this, prices
    low = Math.min.apply this, prices

    obj.volume = parseFloat pricing.btc R.sum R.pluck 'size', docs
    obj.delta = pricing.btc( high - low )
    obj.high = high
    obj.low = low
    obj.n = docs.length

    obj

  new RSVP.Promise (resolve, reject)->
    mongo.connect process.env.MONGO_URL, (err, db)->
      reject err if err

      collection = db.collection 'matches'

      foo = collection.find( search ).toArray (err, docs)->
        db.close()
        resolve R.reject smallPotatoes, R.map stats, R.groupBy timeSeries, docs
