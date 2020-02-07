//Description:
//  Try me as the new home for your nem command
//
//Dependencies:
//  None
//
//Configuration:
//  None
//
//Commands:
//  hubot try me - Receive something back

const fetch = require('node-fetch')

module.exports = robot => {
  robot.respond(/try me/i, msg => {
    fetch('https://google.com')
      .then(res => res.text())
      .then(() => {
        msg.send('try me with fetch works')
      })
  })
}
