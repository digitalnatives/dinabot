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

class FoosballTeam
  @@TEAM_REGEX = /(\d?) ?(@?[\w-\.\d]+ @?[\w-\.\d]+) ?(\d)?/

  constructor: (team_msg) ->
    groups = @@TEAM_REGEX.exec(team_msg)
    @score = groups[1] || groups[3]
    @players = groups[2]

  valid: () ->
    @score && @players && true

class FoosballMatch
  constructor: (msg) ->
    @teams = msg.split(/\sx\s/i).map (team_msg, i)->
      new FoosballTeam(team_msg)

  valid: () ->
    teams[0].valid() && teams[1].valid()

  as_json: () ->
    JSON.stringfify(
      score_a: teams[0].score
      score_b: teams[1].score
      team_a_player_names: teams[0].players
      team_b_player_names: teams[1].players
    )

  submit: (robot) ->
    robot.http("http://leaguelo.proglabs.co/matches")
      .post(@as_json) (err, res, body) ->
        #TODO handle response

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

  addMatch = (msg) ->
    match = new FoosballMatch(msg)
    match.submit(robot) if match.valid()

  robot.hear /csocso(\?|(\s?(me|\+1)))/i, (msg) ->
    addPlayer(msg, '@' + msg.message.user.name)

  robot.hear /csocso\s(@.*)/i, (msg) ->
    addPlayer(msg, msg.match[1])

  robot.hear /csocso\sremove/i, (msg) ->
    init msg
    room = getRoom(msg)
    player = '@' + msg.message.user.name
    robot.brain.data.foos[room] = _.without(robot.brain.data.foos[room], player)
    showLineup msg

  robot.hear /csocso\sclear/i, (msg) ->
    robot.brain.data.foos[getRoom(msg)] = []
    showLineup msg

  robot.hear /csocso\sshow/i, (msg) ->
    init msg
    showLineup msg

  robot.hear /csocso\stable/i, (msg) ->
    msg.send process.env.HUBOT_FOOS_TABLE

  robot.hear /csocso\smatch/i, (msg) ->
    addMatch msg
