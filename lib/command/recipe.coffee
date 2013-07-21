program = require 'commander'
program.data = require '../util/data'
math = require '../util/math'

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
      list[k] = math.round v * ctx.days

    # display
    console.log list

program
  .parse process.argv
