# General Helper
# ===========================================================


# Node Modules
# -----------------------------------------------------------
fs = require 'fs'


# Exported Methods
# -----------------------------------------------------------

# Get the user ID from the user's name.
#
# @param {String} user login name of the user
# @param {function(Error, Integer)} cb callback if some `Error` occured or with
# the retrieved ID
exports.userToUid = (user, cb) ->
  return cb null, user unless user and not isNaN user
  fs.readFile '/etc/passwd', {encoding: 'utf-8'}, (err, data) ->
    return cb err if err
    for line in data.split /\n/
      cols = line.split /:/
      return cb null, cols[2] if cols[0] is user
    fs.stat '/Users/'+user, (err, stats) ->
      return cb user if err
      cb null, stats.uid

# Get the user ID from the user's name.
#
# @param {String} user login name of the user
# @return {Integer} the retrieved ID
# @throw {Error} if something went wrong
exports.userToUidSync = (user) ->
  return user unless user and not isNaN user
  data = fs.readFileSync '/etc/passwd', {encoding: 'utf-8'}
  for line in data.split /\n/
    cols = line.split /:/
    return cols[2] if cols[0] is user
  try
    stats = fs.statSync '/Users/'+user
  return stats.uid

# Get the group ID from the group's name.
#
# @param {String} group login name of the group
# @param {function(Error, Integer)} cb callback if some `Error` occured or with
# the retrieved ID
exports.groupToGid = (group, cb) ->
  return cb null, group unless group and not isNaN group
  fs.readFile '/etc/group', {encoding: 'utf-8'}, (err, data) ->
    return cb err if err
    for line in data.split /\n/
      cols = line.split /:/
      return cb null, cols[2] if cols[0] is group
    cb()

# Get the group ID from the group's name.
#
# @param {String} group login name of the group
# @return {Integer} the retrieved ID
# @throw {Error} if something went wrong
exports.groupToGidSync = (group) ->
  return group unless group and not isNaN group
  data = fs.readFileSync '/etc/group', {encoding: 'utf-8'}
  for line in data.split /\n/
    cols = line.split /:/
    return cols[2] if cols[0] is group
  return group
