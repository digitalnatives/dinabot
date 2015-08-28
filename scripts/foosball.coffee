# Description
#   Add users to a foosball match.
#   https://github.com/thorsteinsson/hubot-foos
#
# Commands:
#   csocso?       - Add a player.
#   csocso me     - Add a player.
#   csocso +1     - Add a player.
#   csocso @nick  - Add @nick as a player.
#   csocso remove - Remove a player.
#   csocso clear  - Remove everyone.
#   csocso show   - Show players.
#   csocso table  - Show a picture of the foosball table.
#
# Dependencies:
#   lodash
#
# Configuration:
#   HUBOT_FOOS_TABLE
#
# Author:
#   thorsteinsson

_ = require('lodash')

module.exports = (robot) ->
  maxLength = 4
  robot.brain.data.foos ?= {}

  getRoom = (msg) ->
    msg.message.user.room ? 'general'

  init = (msg) ->
    room = getRoom msg
    if !robot.brain.data.foos[room]
      robot.brain.data.foos[room] = []

  showLineup = (msg) ->
    room = getRoom(msg)
    players = robot.brain.data.foos[room]
    if players.length == 0
      msg.send 'No csocso players.'
    else if players.length == 1
      msg.send "#{players[0]} started a new csocso. Join with `csocso +1`!"
    else
      msg.send 'Csocso players: ' + players.join(', ')

  addPlayer = (msg, nick) ->
    init msg
    players = robot.brain.data.foos[getRoom(msg)]
    players.push(nick) if nick not in players
    showLineup msg
    if players.length == maxLength - 1
      msg.send 'One more player needed!'
    else if players.length == maxLength
      msg.send 'Go go go!'
      robot.brain.data.foos[getRoom(msg)] = []

  robot.hear /^csocso(\?|(\s?(me|\+1)))/i, (msg) ->
    addPlayer(msg, '@' + msg.message.user.name)

  robot.hear /^csocso\s(@.*)/i, (msg) ->
    addPlayer(msg, msg.match[1])

  robot.hear /^csocso\sremove/i, (msg) ->
    init msg
    room = getRoom(msg)
    player = '@' + msg.message.user.name
    robot.brain.data.foos[room] = _.without(robot.brain.data.foos[room], player)
    showLineup msg

  robot.hear /^csocso\sclear/i, (msg) ->
    robot.brain.data.foos[getRoom(msg)] = []
    showLineup msg

  robot.hear /^csocso\sshow/i, (msg) ->
    init msg
    showLineup msg

  robot.hear /^csocso\stable/i, (msg) ->
    msg.send process.env.HUBOT_FOOS_TABLE
