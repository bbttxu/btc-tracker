moment = require 'moment'

module.exports = (product)->
  ()->
    meta = [ "#{moment().format()}", product ]
    args = Array.prototype.slice.call(arguments)
    console.log meta.concat(args).join "\t"
