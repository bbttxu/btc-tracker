moment = require 'moment'

recoup = require './recoup'

logger = (data, level='info')->
  console.log moment().format(), level, data

  # TODO probably not the best place to do this,
  # but maybe it is?
  recoup()

module.exports = logger

