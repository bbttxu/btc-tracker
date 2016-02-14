cleanSlate = require './cleanSlate'
cleanSlate.clear()

clearStale = cleanSlate.stale
setInterval clearStale, (1000 * 60 * 1)

LongHaul = require './LongHaul'
LongHaul 1.0015, 0.015
