program = require 'commander'
program.data = require '../util/data'
display = require '../util/display'

semver = require 'semver'

program
  .command('add <product>')
  .option('-n, --quantity <K>', 'add K items of product to stock (default: 1)', parseInt)
  .action (product, ctx) ->

    # sanitise quantity
    ctx.quantity ?= 1

    # validate product
    catalog = program.data.catalog
    unless product of catalog
      throw "Unrecognised product: #{product}"

    # update stock
    stock = program.data.stock
    stock.alter product, catalog[product].quantity * ctx.quantity

    # save
    console.log display.table stock
    stock.save()


program
  .command('check')
  .option('-i, --itemised', 'show stock for each item')
  .action (ctx) ->

    # load data
    recipe = program.data.recipe.latest
    stock = program.data.stock

    # initialise vars
    days = {}
    minimum = Infinity

    # calculate stock
    for k, v of recipe
      days[k] = Math.floor stock[k] / v
      minimum = Math.min minimum, days[k]

    # prepare output
    out = unless ctx.itemised
      'days left': minimum
    else
      days

    # print
    console.log display.table out

program
  .command('use')
  .option('-n, --days <K>', 'deduct quantities for K days (default: 1)', parseInt)
  .option('-r, --recipe <V>', "use recipe version V (default: #{program.data.recipe.latest._name})", semver.valid)
  .action (ctx) ->
    
    # sanitise input
    ctx.days ?= 1
    ctx.recipe ?= program.data.recipe.latest._name

    # load data
    recipe = program.data.recipe[ctx.recipe]
    stock = program.data.stock

    # update stock
    for k, v of recipe
      stock.alter k, -v * ctx.days

    # save
    console.log display.table stock
    stock.save()

program
  .parse process.argv
