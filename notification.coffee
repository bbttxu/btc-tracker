clockwork = require('clockwork')(key: process.env.CLOCKWORK)

module.exports = (msg)->
  clockwork.sendSms msg, (error, resp) ->
    if error
      console.log 'Something went wrong', error
    else
      console.log 'Message sent', resp
