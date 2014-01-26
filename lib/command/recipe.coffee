program = require 'commander'
program.data = require '../util/data'
display = require '../util/display'

semver = require 'semver'

program
  .command('show')
  .option('-n, --days <K>', 'show quantities for K days (default: 1)', parseInt)
  .option('-r, --recipe <V>', "use recipe version V (default: #{program.data.recipe.latest._name})", semver.valid)
  .action (ctx) ->

    # sanitise input
    ctx.days ?= 1
    ctx.recipe ?= program.data.recipe.latest._name

    # load data
    catalog = program.data.catalog
    recipe = program.data.recipe[ctx.recipe]

    # build list
    list = {}
    for k, v of recipe
      list[k] = v * ctx.days

    # display
    console.log display.table list,
      metadata: catalog

program
  .parse process.argv
