require('dotenv').config( silent: true )

R = require 'ramda'
RSVP = require 'rsvp'
mongo = require('mongodb').MongoClient
moment = require 'moment'

Stream = require './lib/stream'


log = ( data )->
  console.log moment().format(), data


logSave = ( data )->
  log [ 'saved', JSON.stringify(data) ].join ' '
  data


saveMatch = ( match, done )->
  new RSVP.Promise (resolve, reject)->
    mongo.connect process.env.MONGO_URL, (err, db)->
      reject err if err
      console.log 'saveMatch', err if err

      collection = db.collection 'matches'

      collection.insertOne match, (err, whiz)->
        reject err if err

        db.close()

        resolve match


module.exports = ( product, values = [ 'side', 'size', 'price', 'product_id', 'time', 'trade_id' ] )->
  stream = Stream product

  stream.on 'error', (foo)->
    console.log 'error'
    console.log foo

  stream.on 'message', (foo)->
    if foo.type is 'match'
      order = R.pick values, foo

      log [ 'save', order.trade_id ].join ' '

      saveMatch( order ).then( logSave ).catch ( err )->
        console.log err



