cleanSlate = require './cleanSlate'
cleanSlate.clear()

clearStale = cleanSlate.stale
setInterval clearStale, (1000 * 60 * 15)

LongHaul = require './LongHaul'
LongHaul 1.001, 0.01
LongHaul 1.0025, 0.02
