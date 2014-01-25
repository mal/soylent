program = require 'commander'
program.data = require '../util/data'
display = require '../util/display'

semver = require 'semver'

program
  .command('recipe')
  .option('-r, --recipe <V>', "use recipe version V (default: #{program.data.recipe.latest._name})", semver.valid)
  .action (ctx) ->

    # sanitise input
    ctx.recipe ?= program.data.recipe.latest._name

    # load data
    catalog = program.data.catalog
    recipe = program.data.recipe[ctx.recipe]

    # initialise vars
    values = {}
    makeup = {}

    # calculate makeup
    for k, v of recipe
      [divisor, content] = catalog[k].nutrition
      for nutrient, mass of content
        (makeup[nutrient] ?= {})[k] = mass / divisor * v

    # calculate totals
    for nutrient, content of makeup
      values[nutrient] = Object.keys(content).map((k) ->
        content[k]).reduce (a, b) -> a + b

    # print
    console.log display.table(
      [values, makeup],
      null,
      program.data.nutrients
    )

program
  .parse process.argv
