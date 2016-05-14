clockwork = require('clockwork')(key: process.env.CLOCKWORK)
phoneNumber = process.env.PHONENUMBER

module.exports = (msg)->
  payload =
    To: phoneNumber
    Content: msg

  clockwork.sendSms payload, (error, resp) ->
    if error
      console.log 'Something went wrong', error
    else
      console.log 'Message sent', resp
