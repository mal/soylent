# dependencies

path = require 'path'
math = require './math'


# lazy dependencies

fs = null
glob = null
semver = null


# constants

HOME = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE
SOYLENT = path.join HOME, '.soylent'


# functions

# add cache to an object
cache = (obj) -> Object.defineProperty obj, '_cache', value: {}

# load data file with magic methods
acquire = cache (source) ->
  source = require.resolve "#{SOYLENT}/#{source}"
  unless source of acquire._cache
    try
      file = require source
    catch e
      file = {}
    file.__proto__ = File
    Object.defineProperty file, '_source', value: source
    Object.defineProperty file, '_name', get: -> path.basename source, '.json'
    acquire._cache[source] = file
  acquire._cache[source]


# objects

# main lazy object
Data = cache {}

# configure lazy loading of basic data files
['catalog', 'stock'].forEach (file) ->
  Object.defineProperty Data, file, get: -> @_cache[file] ||= acquire file

# configure nested lazy load of recipes
Object.defineProperty Data, 'recipe',
  get: ->
    unless @_cache.recipe?
      # lazy load libraries
      glob = require 'glob' unless glob
      semver = require 'semver' unless semver
      # get all recipes
      book = glob.sync "#{SOYLENT}/recipe/*.json"
      book = book.map (file) ->
        path.basename file, '.json'
      # check validity and sort
      book = book.filter(semver.valid).sort(semver.compare).reverse()
      latest = book[0]
      # initialise lazy object and matching cache
      recipe = @_cache.recipe = cache {}
      # configure lazy load of each version
      book.forEach (ver) ->
        Object.defineProperty recipe, ver,
          enumerable: true
          get: -> @_cache[ver] ?= acquire "recipe/#{ver}"
      # add alias to latest
      Object.defineProperty recipe, 'latest',
        get: -> @_cache[latest] ?= acquire "recipe/#{latest}"
    @_cache.recipe


# basic data file
File = {}

# add method for easy value updating
Object.defineProperty File, 'alter',
  value: (key, delta) ->
    @[key] ?= 0
    @[key] += parseFloat delta
    @[key] = math.round @[key]

# add method for saving data file
Object.defineProperty File, 'save',
  value: ->
    fs = require 'fs' unless fs
    fs.writeFileSync @_source, JSON.stringify this, null, '  '


# exports

data = module.exports = Data
