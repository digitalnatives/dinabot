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
const puppeteer = require('puppeteer')

module.exports = robot => {
  robot.respond(/try me/i, msg => {
    fetch('https://google.com')
      .then(res => res.text())
      .then(() => {
        msg.send('try me with fetch works')
      })
  })

  robot.respond(/try some/i, msg => {
    puppeteer.launch({ headless: true })
      .then(browser => browser.newPage())
      .then(page => page.goto('https://freebees.io/'))
      .then(response => {
        msg.send('try me with puppeteer works: ' + String(response.status))
      })
      .catch(error => {
        msg.send('try me with puppeteer failed: ' + String(error))
      })
  })
}
