# hubot massage bot
#
# Commands:
# massage start            -Start over the massage queue
# massage next             -Call the next person
# massage swap             -Ask and accept swapping with someone in the queue
# massage me               -Add me next in queue
# massage @user            -Add user next in queue
# massage clear            -Clear the massage queue
# massage show             -Show the current queue

_ = require('lodash')

module.exports = (robot) ->
  robot.brain.data.massage_queue ?= []
  robot.brain.data.swap_tuple ?= []


  robot.on "massage:start", ->

    robot.brain.data.massage_queue['massage'] = []
    robot.brain.data.swap_tuple['massage'] = []
    robot.messageRoom "massage", "Massage queue is empty now, Add yourself to the queue using `massage me`"

  getRoom = (msg) ->
    msg.message.user.room ? 'general'

  init = (msg) ->
    room = getRoom msg
    robot.brain.data.massage_queue[room] ?= []
    robot.brain.data.swap_tuple[room] ?= []

  show_queue = (msg) ->
    room = getRoom(msg)
    queue = robot.brain.data.massage_queue[room]
    if queue.length == 0
      msg.send "Massage queue is empty now, Add yourself to the queue using `massage me`"
    else
      msg.send 'Massage queue: ' + queue.join(', ')

  add_to_queue = (msg, user='@' + msg.message.user.name) ->
    init msg
    massage_queue = robot.brain.data.massage_queue[getRoom(msg)]
    if user in massage_queue
      msg.send "You are already in the queue"
    else
      massage_queue.push(user)
    show_queue msg

  swap_me = (msg) ->  
    user = '@' + msg.message.user.name
    massage_queue = robot.brain.data.massage_queue[getRoom(msg)]
    msg.send massage_queue
    msg.send robot.brain.data.swap_tuple[getRoom(msg)]
    if user in massage_queue
      switch robot.brain.data.swap_tuple[getRoom(msg)].length
        when 0 then call_for_swappers(msg, user)
        when 1 then perform_swap(msg, user)
    else
      msg.send "Sorry " + user + " you can't swap unless you are a member of the queue already." 
    
  call_for_swappers = (msg, user) ->
    robot.brain.data.swap_tuple[getRoom(msg)].push(user)
    msg.send user + " is looking for someone to swap with him, type `massage swap` if you want to accept the swap"

  perform_swap = (msg, user) ->
    swap_caller = robot.brain.data.swap_tuple[getRoom(msg)][0]
    source_index = robot.brain.data.massage_queue[getRoom(msg)].indexOf(swap_caller)
    target_index = robot.brain.data.massage_queue[getRoom(msg)].indexOf(user)
    robot.brain.data.massage_queue[getRoom(msg)][source_index] = user
    robot.brain.data.massage_queue[getRoom(msg)][target_index] = swap_caller
    show_queue msg
    robot.brain.data.swap_tuple[getRoom(msg)] = []

  next = (msg) ->
    done_user = robot.brain.data.massage_queue[getRoom(msg)].shift()
    if robot.brain.data.massage_queue[getRoom(msg)].length == 0
      show_queue msg
    else
      msg.send done_user + " finished go " + robot.brain.data.massage_queue[getRoom(msg)][0] + " it's your turn!!"
  clear_massage = (msg) ->
    name = msg.message.user.name
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
    next msg

  robot.hear /^massage(\?|\sswap|\s\+1)/i, (msg) ->
    swap_me msg

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
    clear_massage(msg)

  robot.hear /^massage\sshow/i, (msg) ->
    init msg
    show_queue msg
