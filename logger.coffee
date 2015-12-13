require('dotenv').load()
winston = require 'winston'
require 'winston-loggly'

winston.add winston.transports.Loggly,
  token: process.env.WINSTON_TOKEN
  subdomain: process.env.WINSTON_DOMAIN
  tags: [ 'Winston-NodeJS' ]
  json: true

logger = (data, level='info')->
  winston.log level, data

module.exports = logger

