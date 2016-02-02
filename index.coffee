cleanSlate = require './cleanSlate'
cleanSlate.clear()

clearStale = cleanSlate.stale
setInterval clearStale, (1000 * 60 * 15)


LongHaul = require './LongHaul'
# LongHaul 1.00375, 0.02
LongHaul 1.002, 0.01
