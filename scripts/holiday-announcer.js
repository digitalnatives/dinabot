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
const { getHolidaysData } = require('./freebees')
const config = require('./config')

module.exports = robot => {
  robot.respond(/holidays today/i, () => {
    getHolidaysData()
      .then(response => {
        console.log(JSON.stringify(response))
        sendFormattedMessage(response)
      })
  })
  robot.on('send-daily-holiday-report', () => {
    getHolidaysData()
      .then(response => {
        sendFormattedMessage(response)
      })
  })
}

function sendFormattedMessage(response) {
  const blocks = []
  const noHolidays = {
    type: 'section',
    text: {
      type: 'mrkdwn',
      text: ':moneybag:  *Noone is on holiday today*  :yen:',
    },
  }
  const onHolidayHeader = {
    type: 'section',
    text: {
      type: 'mrkdwn',
      text: ':desert_island:  *On holiday today*  :desert_island:',
    },
  }
  const noSickLeaves = {
    type: 'section',
    text: {
      type: 'mrkdwn',
      text: ':mask:  *Noone is on (pre-reported) sick leave today*  :mask:',
    },
  }
  const onSickLeaveHeader = {
    type: 'section',
    text: {
      type: 'mrkdwn',
      text:
        ':face_with_thermometer:  *On sickleave today*  :face_with_thermometer:',
    },
  }

  if (response.vacations.length === 0) {
    blocks.push(noHolidays)
  } else {
    blocks.push(onHolidayHeader)
    blocks.push(...getEntriesAsMessageBlock(response.vacations))
  }

  blocks.push({
    type: 'divider',
  })

  if (response.sickLeaves.length === 0) {
    blocks.push(noSickLeaves)
  } else {
    blocks.push(onSickLeaveHeader)
    blocks.push(...getEntriesAsMessageBlock(response.sickLeaves))
  }

  sendSlackMessage(blocks)
}

function getEntriesAsMessageBlock(holidayEntries) {
  return holidayEntries.map(item => ({
    type: 'section',
    fields: [
      {
        type: 'mrkdwn',
        text: `*${item.name}*`,
      },
      {
        type: 'plain_text',
        text: item.dateRange,
      },
    ],
  }))
}

function sendSlackMessage(blocks) {
  fetch(config.freebees.slackHookUrl, {
    method: 'POST',
    body: JSON.stringify({
      username: 'freebees',
      blocks,
      icon_url: 'https://freebees.io/assets/img/favicon.png',
      channel: config.freebees.slackChannel,
    }),
  })
}
