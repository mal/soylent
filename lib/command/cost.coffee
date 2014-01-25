program = require 'commander'
program.data = require '../util/data'
display = require '../util/display'

semver = require 'semver'

program
  .command('check')
  .option('-i, --itemised', 'show cost for each item')
  .option('-n, --days <K>', 'show cost for K days (default: 1)', parseInt)
  .action (ctx) ->

    # sanitise input
    ctx.days ?= 1

    # load data
    catalog = program.data.catalog
    recipe = program.data.recipe.latest

    # initialise vars
    cheque = {}
    total = 0

    # calculate stock
    for k, v of recipe
      product = catalog[k]
      cheque[k] = product.cost / product.quantity * v * ctx.days
      total += cheque[k]

    # prepare output
    out = unless ctx.itemised
      'total': total
    else
      cheque

    # print
    console.log display.table out

program
  .parse process.argv
