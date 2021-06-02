const puppeteer = require('puppeteer')
const config = require('./config')

async function getHolidaysData() {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox'],
  })

  const page = await browser.newPage()
  await page.goto(config.freebees.loginUrl)

  console.log('FreeBess login page loaded')

  await page.focus('#email-input')
  await page.keyboard.type(config.freebees.email)
  await page.focus('#password-input')
  await page.keyboard.type(config.freebees.password)
  await page.$eval('#submit-button', btn => btn.click())
  await page.waitFor(20000)
  const result = await page.evaluate(evaluate)

  await browser.close()

  return result
}

const evaluate = () => {
  const entries = {
    vacations: extractInfoFromThePage('VACATION'),
    sickLeaves: extractInfoFromThePage('SICK_LEAVE'),
  }
  return entries

  function extractInfoFromThePage(type) {
    return [...document.querySelectorAll(`[type=${type}]`)]
      .map(element => {
        const start = window.getComputedStyle(element).gridColumnStart - 1
        const end = window.getComputedStyle(element).gridColumnEnd - 1

        const today = new Date().getDate()
        const isToday = today >= start && today < end

        const row = window.getComputedStyle(element).gridRowStart
        const nameSelector = `.scrollbar-container [style*='grid-column-start: 1; grid-row-start: ${row}']`
        const name = document.querySelectorAll(nameSelector)[0].innerText

        const dateRange = element.title

        return {
          name,
          dateRange,
          isToday,
        }
      })
      .filter(holiday => holiday.isToday)
      .map(({ name, dateRange }) => ({ name, dateRange }))
  }
}

module.exports = { getHolidaysData }
