util = require 'util'

HACK = require '../../node_modules/cli-table/lib/cli-table/utils'
HACK.strlen_old = HACK.strlen
HACK.strlen = (str) -> HACK.strlen_old((str + '').replace(/\u001b\[(?:\d*;){0,2}\d*m/g, ''))

Table = require 'cli-table'

table = (columns, headers, style) ->

  columns = [columns] unless Array.isArray columns
  header = head: header if header
  style = columns[0] unless style
  
  table = new Table header

  data = columns.reduce (t, c, i) ->
    Object.keys(c).reduce (r, k) ->
      r[k] = t[k] || Array i
      r[k].push format c[k]
      r
    , {}
  , {}

  rows = []
  for key, opts of style
    name = if opts.color then key[opts.color].replace(
      /(\u001b\[)(\d+m)/, '$11;$2'
    ) + '\x1B[m' else key
    rows.push [name].concat data[key]

  for row in rows
    table.push row

  table.toString()

format = (value) ->
  switch typeof value
    when 'object'
      util.inspect(value)
        .replace(/[\{\}'\[\]]/g, '')
        .replace(/,\s+/g, '\n')
        .trim()
    else
      value

module.exports = {
  table: table
}
