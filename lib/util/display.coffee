util = require 'util'

Table = require 'cli-table'
si = require 'si-prefix'

table = (columns, options = {}) ->

  columns = [columns] unless Array.isArray columns
  metadata = options.metadata || {}
  delete options.metadata
  
  table = new Table options

  data = columns.reduce (t, c, i) ->
    Object.keys(c).reduce (r, k) ->
      r[k] = t[k] || Array(i).map -> 0
      r[k].push humanise c[k], (metadata[k] ||= {}).unit
      r
    , {}
  , {}

  rows = []
  for key, opts of metadata
    rows.push [colourise(key, opts.color)].concat data[key] || 0

  for row in rows
    table.push row

  table.toString()

colourise = (value, color) ->
  return value unless value[color]
  value[color].replace(/(\u001b\[)(\d+m)/, '$11;$2') + '\x1B[m'

humanise = (value, unit) ->
  switch typeof value
    when 'number'
      return round(value, 3) unless si[unit]
      [vector, suffix] = si[unit].convert value / 1000
      round(vector, 3) + ' ' + suffix
    when 'object'
      dupe = {}
      for k, v of value
        dupe[k] = humanise(v, unit)
      util.inspect(dupe)
        .replace(/[\{\}'\[\]]/g, '')
        .replace(/,\s+/g, '\n')
        .trim()
    else
      value

round = (n, l = 12) ->
  parseFloat n.toFixed l

module.exports = {
  table: table
}
