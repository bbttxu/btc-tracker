# trip.coffee
moment = require 'moment'
acct = require 'accounting'
R = require 'ramda'

module.exports = ( ws, sms, percentage, time, span )->
	lastNotification = moment()
	trades = []

	console.log "Set trip at #{percentage}% in #{time} #{span}, starting #{lastNotification.format()}"

	old = (a)->
		moment.unix(a.ms).isBefore moment().subtract( time, span )

	getPrice = R.pluck 'price'
	getTimes = R.pluck 'ms'

	ws.on 'message', (data, flags) ->
		json = JSON.parse data

		if json.type is 'match'
			trade =
				price: ( parseInt json.price ) * 100
				ms: moment(json.time).valueOf()

			trades.push trade if trades.length is 0

			trades = R.reject old, trades

			prices = getPrice trades
			times = getTimes trades

			earliest = Math.min.apply null, times
			min = Math.min.apply null, prices
			max = Math.max.apply null, prices

			trades.push trade unless trades.length is 0

			pct = ( ( trade.price - max ) / max )

			# if trade.price <= min

			if trade.price <= min and pct <= percentage

				if lastNotification.isBefore( moment().subtract( time, span ) )
					lastNotification = moment()
					trades = []

					sms
						To: process.env.PHONENUMBER
						Content: [ trade.price, pct + '%', time + ' ' + span ].join ', '
