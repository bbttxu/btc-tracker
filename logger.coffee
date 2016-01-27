# require('dotenv').load()
# winston = require 'winston'
# require 'winston-loggly'
moment = require 'moment'

recoup = require './recoup'

# winston.add winston.transports.Loggly,
#   token: process.env.WINSTON_TOKEN
#   subdomain: process.env.WINSTON_DOMAIN
#   tags: [ 'Winston-NodeJS' ]
#   json: true

logger = (data, level='info')->
  console.log moment().format(), level, data
  # winston.log level, data
  recoup()

module.exports = logger

