# hubot massage bot
#
# Commands:
# massage start            -Start over the massage queue
# massage next             -Add me next in queue
# massage me               -Add me next in queue
# massage @user            -Add user next in queue
# massage clear            -Clear the massage queue
# massage show             -Show the current queue

_ = require('lodash')

module.exports = (robot) ->
  robot.brain.data.massage_queue ?= {}


  robot.on "massage:start", ->

    robot.brain.data.massage_queue['massage'] = []
    robot.messageRoom "massage", "Massage queue is empty now, Add yourself to the queue using `massage me` or `massage next`"

  getRoom = (msg) ->
    msg.message.user.room ? 'general'

  init = (msg) ->
    room = getRoom msg
    if !robot.brain.data.massage_queue[room]
      robot.brain.data.massage_queue[room] = []

  show_queue = (msg) ->
    room = getRoom(msg)
    queue = robot.brain.data.massage_queue[room]
    if queue.length == 0
      msg.send "Massage queue is empty now, Add yourself to the queue using `massage me` or `massage next`"
    else
      msg.send 'Massage queue: ' + queue.join(', ')

  add_to_queue = (msg, user='@' + msg.message.user.name) ->
    init msg
    players = robot.brain.data.massage_queue[getRoom(msg)]
    if user in players
      msg.send "You are already in the queue"
    else
      players.push(user)
    show_queue msg

  clear_massage = (msg, name) ->
    if name == 'ritacica'
      robot.brain.data.massage_queue[getRoom(msg)] = []
      show_queue msg
    else
      msg.send "Sorry @"+name+", only @ritacica can clear the queue or the bot will automatically do it on wednesday at 12:00"

  robot.hear /^massage(\?|\sstart|\s\+1)/i, (msg) ->
    name = msg.message.user.name
    clear_massage(msg, name)
    
  robot.hear /^massage(\?|\sme|\s\+1)/i, (msg) ->
    add_to_queue msg

  robot.hear /^massage(\?|\snext|\s\+1)/i, (msg) ->
    add_to_queue msg

  robot.hear /^massage((?:\s@[^\s]+){1,4})/i, (msg) ->
    players = msg.match[1].trim().split(' ')
    add_to_queue(msg, player) for player in players

  robot.hear /^massage\sremove/i, (msg) ->
    init msg
    room = getRoom(msg)
    player = '@' + msg.message.user.name
    robot.brain.data.massage_queue[room] = _.without(robot.brain.data.massage_queue[room], player)
    show_queue msg

  robot.hear /^massage\sclear/i, (msg) ->
    name = msg.message.user.name
    clear_massage(msg, name)

  robot.hear /^massage\sshow/i, (msg) ->
    init msg
    show_queue msg
