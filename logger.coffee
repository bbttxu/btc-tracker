require('dotenv').load()
winston = require 'winston'
require 'winston-loggly'

recoup = require './recoup'

winston.add winston.transports.Loggly,
  token: process.env.WINSTON_TOKEN
  subdomain: process.env.WINSTON_DOMAIN
  tags: [ 'Winston-NodeJS' ]
  json: true

logger = (data, level='info')->
  winston.log level, data
  recoup()

module.exports = logger

