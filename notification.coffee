# notification.coffee

asdf =
	key: 'df9abfe35d700e49179aa093a5c386aff1a81cf1'

clockwork = require('clockwork')(asdf)

module.exports = (msg)->
	clockwork.sendSms msg, (error, resp) ->
	  if error
	    console.log 'Something went wrong', error
	  else
	    console.log 'Message sent', resp
	  return
