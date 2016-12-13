Loki = require 'lokijs'
RSVP = require 'rsvp'

db = new Loki 'orders.json'

orders = db.addCollection 'orders'

insert = (data)->
  new RSVP.Promise (resolve, reject)->
    reject 0 if data.message

    order = orders.insert data

    resolve order

findOne = (query)->
  orders.findOne(query)
  # # console.log 'query', query
  # new RSVP.Promise (resolve, reject)->
  #   reject 0 if data.message
  #   order = orders.findOne(query).data()

  #   resolve order
markOrder = (id, result)->
  order = orders.findOne(id: id)
  order.result = result
  orders.update(order)

module.exports =
  insert: insert
  findOne: findOne
  mark: markOrder
